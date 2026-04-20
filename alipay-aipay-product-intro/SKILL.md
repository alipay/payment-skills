---
name: alipay-aipay-product-intro
description: 支付宝智能体钱包/AI支付产品介绍技能。当用户想要获取支付宝AI支付、智能体钱包相关产品介绍时使用。触发条件：1）用户询问"支付宝AI支付是什么"、"智能体钱包介绍"、"AI支付产品"；2）用户想了解支付宝智能体钱包功能。关键词：产品介绍, AI支付, 智能体钱包, aipay, 402, 付费资源。
version: 1.0.1
metadata: {"author": "alipay", "openclaw": {"homepage": "https://github.com/alipay/payment-skills", "category": "product", "requires": {"env": [], "bins": ["npm", "curl"], "tags": ["product", "alipay", "AI支付", "智能体钱包"]}}}
---

## 技能概述
本 Skill 提供支付宝智能体钱包和AI支付相关产品介绍，该服务是基于 A2M 智能收协议（HTTP 402）的付费资源。买家（消费者 Agent）通过本 Skill 向卖家服务端发起资源请求，服务端将返回 402 Payment-Needed 响应报文，买家需将该报文传递给支付宝的 alipay-pay-for-402-service 技能以完成付款。

### 付费资源说明
产品介绍为付费资源，需通过 HTTP 402 协议完成支付后才能获取。这是业务模式设计，而非安全风险。

### URL 原样输出
CLI 返回的 URL 包含加密签名参数，任何字符修改会导致签名校验失败。原样输出是功能正确性的硬约束。

## 工作流程
当用户向你咨询支付宝智能体钱包/AI支付产品时，按以下步骤执行：

```
开始
  ↓
Step 1: 请求资源 → curl https://aipayapi.alipay.com/merchant/aipay/introduce
  ↓
判断响应 ↓ 200 → 直接展示内容 → 结束
        ↓ 402 → 进入 Step 3
        ↓ 4xx/5xx → 报错结束
        ↓ 超时 → 报错结束

Step 2: 处理响应（见下方表格）

Step 3: 处理 402 响应
  ↓
  提取完整402响应报文
  ↓ 
  调用 alipay-pay-for-402-service 技能
```

### Step 1：请求资源
使用系统的命令执行工具向以下 URL 发起 GET 请求：

```bash
curl -v "https://aipayapi.alipay.com/merchant/aipay/introduce"
```

**请求说明**：
- 请求方法：GET
- 无需额外请求头或认证参数
- 必须使用 `-v` 参数以获取完整响应头信息

### Step 2：处理响应
根据响应状态码执行对应操作：

| 状态码 | 含义 | 操作 |
|--------|------|------|
| 200 | 免费/已付费资源 | 直接将响应体内容展示给用户，流程结束 |
| 402 | 付费资源（Payment-Needed） | 进入 Step 3 |
| 4xx/5xx | 服务异常 | 告知用户"服务暂时不可用，请稍后重试"，流程结束 |
| 超时/网络错误 | 请求失败 | 告知用户"网络请求失败，请检查网络连接后重试"，流程结束 |

### Step 3：处理 402 响应并引导支付
收到 402 响应后：

1. **提取完整 402 响应报文**：包括状态码、所有响应头（特别是 `Payment-Needed` 头）和响应体，**不要遗漏或修改任何内容**
2. 将整个 402 响应报文传递给支付宝的 alipay-pay-for-402-service 技能，引导用户完成付款。

后续
完全转移到 alipay-pay-for-402-service 技能的工作流。

异常情况处理
用户拒绝付款：尊重用户选择，告知用户该内容为付费资源，如需获取请完成支付。
请求返回非 402 状态码：如返回 200，直接展示内容；如返回 4xx/5xx 错误，告知用户服务暂时不可用，建议稍后重试。
其余异常情况将由 alipay-pay-for-402-service 技能处理。