# 流式响应修复记录

## 初步发现

- 问题入口位于 `src/api/controllers/chat.ts` 的 `createTransStream`。
- 上游接口返回的是 SSE，单个 Node `data` 事件不保证对应完整的 SSE 事件，也不保证 UTF-8 字符边界完整。
- 当前代码已对 SSE 使用 `eventsource-parser`，并在流式转换路径使用 `TextDecoder`，但仍假定上游 `parts` 的更新方式固定为按 `logic_id` 合并。
- 上游 `parts` 是按逻辑段返回的当前快照：同一个 `logic_id` 的 `think` 或 `text` 内容会逐次替换，而不是完整历史内容，也不是可以简单累加的独立片段。

## 基线复现

- 使用本地独立端口启动服务，并请求至少 1500 字的中文长文本。
- 请求成功返回约 20 KB SSE，但正文的第一个块从中段开始，前置正文没有发送；推理块正常出现。
- 原流式路径按 `logic_id` 合并快照，并重新拼接所有缓存段；这会把当前增量快照与旧内容混合，随后基于字符串长度切片时跳过开头或产生错位。

## 修复方案

- 恢复原有按 `partStatus`、思考状态、代码状态和已发送偏移量计算增量的算法，使快照替换不会破坏首段内容。
- 在上游流关闭时刷新 `TextDecoder`，确保最后一个不完整 UTF-8 序列不会丢失。

## 修复后验证

- `pnpm build` 通过。
- 使用提供的 refresh token 通过独立端口 `18000` 启动服务并完成多次长文本 SSE 请求。
- 修复前正文首块出现于长篇推理之后，且开头内容明显缺失；修复后首块从上游实际首字符开始，连续收到后续增量，并正常发送 `data: [DONE]`。
- 未发现破坏性 API 变更；仅调整流式响应内部解析策略。
- 多轮复测覆盖普通模型、推理模型和不同长文本主题，均正常完成 SSE 并发送 `[DONE]`；推理模型的一次请求从指定首句开始输出。
- Dockerfile 已切换为使用 pnpm lockfile 构建，并直接启动已构建的 `dist/index.js`。
- Docker smoke test 发现原 Alpine 运行阶段无法加载构建阶段安装的 glibc 版 `sharp`；运行阶段已改为与构建阶段一致的 Debian Node 镜像，避免跨 libc 复制原生依赖。
- 镜像 `akashrajpuroh1t/glm-free-api-fix:1.0.3` 和 `latest` 已本地构建，容器 `/ping` smoke test 通过；推送 Docker Hub 时 registry 连接被当前网络重置，尚未能确认远端发布成功。
- 本轮新增目标：恢复 `reasoning_content` 和搜索信息，同时保证 think 结束后最终正文独立从首字符增量输出，避免复用 reasoning 长度造成正文截断。
- 本轮提供的 refresh token 在复测时已被上游判定为过期，因此无法继续进行新的真实联网回归；已避免在刷新日志中记录 token 明文。
- 代码级检查：流式缓存现在从 `cachedParts` 重建，而不是只处理当前事件；think、tool/search、正文分别累计并分别输出，最终正文不再使用 think 的长度或偏移量。
- 代码级风险边界：若上游在已发送正文后重新改写更早内容，服务端不会回溯已发送 SSE；正常的累积快照会保持前缀并只发送新增后缀。
- 新 token 的第一组真实联网请求成功：`reasoning_content` 中包含完整思考过程和多组 `> 检索 ...` 搜索结果；最终正文首段从 `行业` 开始，但上游随后很快发送 finish，正文只剩两小段，暴露出正文片段在混合快照/增量格式下被过早截断的风险。
- 已增加同一逻辑段字段合并：较长前缀快照覆盖较短值，非前缀值追加，较短回退值忽略；第二组请求按要求等待超过 30 秒后发送，但 token 再次被上游判定过期，未能完成对照回归。
- 延迟 60 秒的两组真实请求均通过：第一组客户端重建得到正文 4015 字符、reasoning 1984 字符；第二组正文 4930 字符、reasoning 4727 字符；两组均有正确指定首句、`finish_reason: stop` 和 `[DONE]`。
- Docker 1.0.4 构建排查：pnpm 9 需要 workspace `packages` 字段，已补充；构建阶段固定 pnpm 9.15.4 并使用 frozen lockfile。当前环境 Docker 默认网络 DNS 偶发 `EAI_AGAIN`，使用 `docker build --network=host` 构建成功，容器 `/ping` smoke test 通过。

已完成修复后的真实长文本回归验证；后续如需扩大覆盖范围，可补充固定上游 SSE fixture 的自动化测试。

## 过程记录

后续记录实际复现结果、修复方案、验证命令和是否存在破坏性变更。令牌不会写入此文件。
