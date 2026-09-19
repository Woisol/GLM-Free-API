# GLM AI Free 服务

## 项目说明

<span>[ 中文 | <a href="README_EN.md">English</a> ]</span>

支持GLM-4-Plus高速流式输出、支持多轮对话、支持智能体对话、支持沉思模型、支持Zero思考推理模型、支持视频生成、支持AI绘图、支持联网搜索、支持长文档解读、支持图像解析，零配置部署，多路token支持，自动清理会话痕迹。

本项目由 [xiaoY233/GLM-Free-API](https://github.com/xiaoY233/GLM-Free-API) 继续修改而来，其上游为 [LLM-Red-Team/glm-free-api](https://github.com/LLM-Red-Team/glm-free-api)，感谢各位大佬的贡献!
重要提示：原项目由于供应链攻击，提交的代码内包含恶意代码，强烈建议不再继续使用。

修改原因：
1. 原项目作者账号被封，无法更新了
2. 已去除原项目中包含的恶意代码，欢迎对本项目源码进行审查

## 更新说明

1. 更新 models.ts 模型列表，支持 glm-4.7、glm-4.6v、glm-4.6 等最新模型
2. 修复流式响应长文本首段丢失、思考过程与搜索结果分段丢失等输出问题
3. 已修复源码中恶意代码问题，原项目包含混淆代码在 `src/api/chat.js` 文件末尾处
4. 重新打包新版本的 Docker 镜像，`woisol/glm-free-api-fix:latest`
5. 新增 GitHub Actions 工作流，push 时自动构建并发布镜像到 Docker Hub

> PS：模型名称实际上并没啥用，只是方便和好看，实际上线上Chat调用是啥模型，就用的啥模型，模型名称随便填都可以。

### 版本说明

- v1.0.5 (2026-09-19)
    - 同步与流式输出统一移除正文中的内部搜索标识 `【turn数字search数字】`，保留搜索结果摘要和普通方括号文本
    - 新增 GitHub Actions 工作流，push 时自动构建并发布镜像到 Docker Hub

- v1.0.4 (2026-09-16)
    - 修复 `reasoning_content` 思考过程与搜索结果分段的流式输出
    - 安全合并混合快照/增量格式的同一逻辑段，避免正文被过早截断
    - Docker 构建可复现：补充 pnpm workspace `packages` 字段，固定 pnpm 9.15.4 并使用 frozen lockfile

- v1.0.3 (2026-09-16)
    - 修复长文本流式响应首段丢失，恢复按 `partStatus` 与已发送偏移量计算增量的输出逻辑
    - 上游流关闭时刷新 `TextDecoder`，避免最后一个不完整 UTF-8 序列丢失
    - Docker 构建改用 pnpm lockfile，运行阶段改用 Debian Node 镜像以兼容 glibc 版 `sharp`

- v1.0.2 (2025-02-05)
    - 更新模型列表，添加 GLM-4.7、GLM-4.6v、GLM-4.6
    - 移除 GLM-4.5 系列模型（已弃用）
    - 合并 PR #2 并修复安全问题
    - 支持从环境变量配置 SIGN_SECRET，添加格式验证
    - 添加 User-Agent 池并随机化，降低风控风险
    - 添加 reasoning_content 字段支持推理过程
    - 优化流式响应处理，使用 TextDecoder 防止多字节字符截断
    - 改进搜索结果缓存机制，避免重复内容

- v1.0.1 (2025-12-02)
    - 重构默认首页样式和内容，修复部分描述
    - 新增Gemini和Claude适配器

- v1.0.0-fix (2025-11-24)
    - 修改默认首页样式，添加接入方式和示例代码
    - 去除原项目中包含的恶意代码

## 免责声明

**逆向API是不稳定的，建议前往智谱AI官方 https://open.bigmodel.cn/ 付费使用API，避免封禁的风险。**

**本组织和个人不接受任何资金捐助和交易，此项目是纯粹研究交流学习性质！**

**仅限自用，禁止对外提供服务或商用，避免对官方造成服务压力，否则风险自担！**

**仅限自用，禁止对外提供服务或商用，避免对官方造成服务压力，否则风险自担！**

**仅限自用，禁止对外提供服务或商用，避免对官方造成服务压力，否则风险自担！**

## 效果示例

### 服务默认首页

服务启动后，默认首页添加了接入指南和接口说明，方便快速接入，不用来回切换找文档。

![index.html](./doc/index.png)

### Gemini-cli接入

版本添加了gemini-cli适配器，可以直接在gemini-cli中调用API。

![gemini-cli](./doc/gemini-cli.png)

### Claude-code接入

版本添加了Claude-code适配器，可以直接在Claude-code中调用API。

![claude-code](./doc/claude-code.png)

### 验明正身Demo

![验明正身](./doc/example-1.png)

### 智能体对话Demo

对应智能体链接：[网抑云评论生成器](https://chatglm.cn/main/gdetail/65c046a531d3fcb034918abe)

![智能体对话](./doc/example-9.png)

### 结合Dify工作流Demo

体验地址：https://udify.app/chat/m46YgeVLNzFh4zRs

<img width="390" alt="image" src="https://github.com/LLM-Red-Team/glm-free-api/assets/20235341/4773b9f6-b1ca-460c-b3a7-c56bdb1f0659">

### 多轮对话Demo

![多轮对话](./doc/example-6.png)


## 接入准备

从 [智谱清言](https://chatglm.cn/) 获取refresh_token

进入智谱清言随便发起一个对话，然后F12打开开发者工具，从Application > Cookies中找到`chatglm_refresh_token`的值，这将作为Authorization的Bearer Token值：`Authorization: Bearer TOKEN`

![example0](./doc/example-0.png)

### 智能体接入

打开智能体的聊天界面，地址栏的一串ID就是智能体的ID，复制下来备用，这个值将用作调用时的 `model` 参数值。

![example11](./doc/example-11.png)

### 多账号接入

目前似乎限制同个账号同时只能有*一路*输出，你可以通过提供多个账号的chatglm_refresh_token并使用`,`拼接提供：

`Authorization: Bearer TOKEN1,TOKEN2,TOKEN3`

每次请求服务会从中挑选一个。

## Docker部署

请准备一台具有公网IP的服务器并将8000端口开放。

拉取镜像并启动服务

```shell
docker run -it -d --init --name glm-free-api -p 8000:8000 -e TZ=Asia/Shanghai woisol/glm-free-api-fix
```

查看服务实时日志

```shell
docker logs -f glm-free-api
```

重启服务

```shell
docker restart glm-free-api
```

停止服务

```shell
docker stop glm-free-api
```

### Docker-compose部署

```yaml
version: '3'

services:
  glm-free-api:
    container_name: glm-free-api
    image: woisol/glm-free-api-fix:latest
    restart: always
    ports:
      - "8000:8000"
    environment:
      - TZ=Asia/Shanghai
```

## 接口列表

目前支持：

1. 与OpenAI兼容的 `/v1/chat/completions` 接口
2. 与Google Gemini兼容的 `/v1beta/models/:model:generateContent` 接口
3. 与Anthropic Claude兼容的 `/v1/messages` 接口

可自行使用与openai、gemini-cli、claude-code或其他兼容的客户端接入接口，或者使用 [dify](https://dify.ai/) 等线上服务接入使用。

### 对话补全

对话补全接口，与openai的 [chat-completions-api](https://platform.openai.com/docs/guides/text-generation/chat-completions-api) 兼容。

**POST /v1/chat/completions**

header 需要设置 Authorization 头部：

```
Authorization: Bearer [refresh_token]
```

请求数据：
```json
{
    // 默认模型：glm-4-plus
    // zero思考推理模型：glm-4-zero / glm-4-think
    // 沉思模型：glm-4-deepresearch
    // 如果使用智能体请填写智能体ID到此处
    "model": "glm-4-plus",
    // 目前多轮对话基于消息合并实现，某些场景可能导致能力下降且受单轮最大token数限制
    // 如果您想获得原生的多轮对话体验，可以传入首轮消息获得的id，来接续上下文
    // "conversation_id": "65f6c28546bae1f0fbb532de",
    "messages": [
        {
            "role": "user",
            "content": "你叫什么？"
        }
    ],
    // 如果使用SSE流请设置为true，默认false
    "stream": false
}
```

响应数据：
```json
{
    // 如果想获得原生多轮对话体验，此id，你可以传入到下一轮对话的conversation_id来接续上下文
    "id": "65f6c28546bae1f0fbb532de",
    "model": "glm-4",
    "object": "chat.completion",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "我叫智谱清言，是基于智谱 AI 公司于 2023 年训练的 ChatGLM 开发的。我的任务是针对用户的问题和要求提供适当的答复和支持。"
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 1,
        "completion_tokens": 1,
        "total_tokens": 2
    },
    "created": 1710152062
}
```
