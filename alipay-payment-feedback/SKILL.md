---
name: alipay-payment-feedback
description: 支付宝技能问题反馈。仅在用户使用 alipay-authenticate-wallet、 alipay-pay-for-service 或 alipay-pay-for-402-service 技能过程中遇到无法解决的问题时使用。触发条件：1）支付流程反复失败且无法自行修复；2）支付功能开通/授权流程异常且重试无效；3）CLI 命令返回未知错误码；4）用户明确表示要反馈问题。关键词：反馈, 问题, 报错, bug, 异常, feedback。
version: 1.0.0
metadata: {"openclaw":{"requires": {"env": [], "bins":["npm"],"tags":["feedback","alipay","问题反馈"]}}}
---

# 支付宝支付技能问题反馈

## 功能描述

将用户在使用支付宝支付技能过程中遇到的无法解决的问题反馈给支付宝团队，包括：
- 开通支付宝支付功能
- 授权支付功能  
- 支付流程
- 支付结果查验


## 适用场景（必须同时满足）

1. 用户正在使用 alipay-authenticate-wallet、 alipay-pay-for-service 或 alipay-pay-for-402-service 技能
2. 遇到了无法通过重试或常规手段解决的问题
3. 例如：
   - 支付反复失败，错误原因不明
   - 钱包开通/授权流程卡住，重试无效
   - CLI 返回未知错误码或异常输出
   - 用户主动要求反馈问题

## 不适用场景（禁止使用）

- 用户未使用过任何 alipay 技能
- 问题可以通过重试解决
- 用户只是普通咨询（如"怎么支付"、"你付好了么"、"你搞定了么"）
- 与支付宝无关的问题

## 环境依赖

- `alipay-bot` CLI 工具已安装：`nnpx -y @alipay/agent-payment@latest install-cli`

## 执行流程

### Step 1：收集问题信息

在调用命令前，先整理问题描述。问题描述应包含：
- 用户遇到了什么问题
- 在哪个环节出的问题（开通钱包 / 授权 / 支付 / 查询状态）
- 具体的错误信息（如有）

### Step 2：提交反馈

**命令：**

```bash
alipay-bot problem-feedback --reason "<问题描述>"
```

**入参：**

| 参数 | 短参数 | 类型 | 必填 | 说明 |
|------|--------|------|------|------|
| --reason | -r | string | 是 | 问题描述 |

**入参规则：**
- `--reason` 的值必须用双引号包裹
- 内容应简洁清晰地描述问题，包含关键错误信息
- 禁止编造问题，必须基于用户实际遇到的情况

**出参格式：** Markdown 文本

**输出处理：** 原样输出 CLI 返回的内容

## 输出规范

- CLI 命令返回什么，就**逐字符原样输出**什么
- 禁止编造、修改、删减、截断或改写
- 必须等待 CLI 返回结果后再输出


### 敏感信息保护规则（最高优先级）

> ⚠️ **禁止在任何情况下向用户输出敏感信息**
>
> CLI 返回的 JSON 中可能包含用户敏感字段，这些字段**绝对禁止**输出给用户或在对话中提及。
>
> **禁止输出的敏感字段：**
> - `credential` — 用户凭证
> - `externalId` — 外部标识
> - `token`、`accessToken`、`refreshToken` — 令牌类字段
> - `sign`、`signature` — 签名字段（URL 中的 sign 参数除外，但不得单独展示）
> - 任何以 `_key`、`_secret`、`_password` 结尾的字段
>
> **处理方式：**
> 1. 输出前必须检查 CLI 返回内容，过滤掉上述敏感字段
> 2. 如果 CLI 返回的是 JSON，只输出 `message`、`access_url` 等非敏感字段
> 3. 如果敏感字段混在 Markdown 文本中，必须从文本中移除后再输出
> 4. **禁止**以"为了帮助你排查问题"等任何理由输出敏感信息