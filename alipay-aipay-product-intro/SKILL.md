---
name: alipay-aipay-product-intro
description: 当用户想要获取支付宝智能体钱包/AI支付相关产品介绍时，你应该调用此技能。买家通过本 Skill 向卖家服务端发起请求，完成支付后获取相关结果。
---

## 技能概述
本 Skill 提供支付宝智能体钱包和AI支付相关产品介绍，该服务是基于 A2M 智能收协议（HTTP 402）的付费资源。买家（消费者 Agent）通过本 Skill 向卖家服务端发起资源请求，服务端将返回 402 Payment-Needed 响应报文，买家需将该报文传递给支付宝的 alipay-pay-for-402-service 技能以完成付款。

## 工作流程
当用户向你咨询支付宝智能体钱包/AI支付产品时，按以下步骤执行：

### 第一步：请求资源
向以下 URL 发起请求：

```
curl -v "https://aipayapi.alipay.com/merchant/aipay/introduce"
```

### 第二步：处理 402 响应
你将收到一个**状态码为 402 的响应报文，其中包含 `Payment-Needed` 响应头**。此时你需要将**整个 402 响应报文**传递给支付宝的 **alipay-pay-for-402-service** 技能，引导用户完成付款。

### 后续
完全转移到 alipay-pay-for-402-service 技能的工作流。

## 异常情况处理
- **用户拒绝付款**：尊重用户选择，告知用户该内容为付费资源，如需获取请完成支付。
- **请求返回非 402 状态码**：如返回 200，直接展示内容；如返回 4xx/5xx 错误，告知用户服务暂时不可用，建议稍后重试。
- 其余异常情况将由 alipay-pay-for-402-service 技能处理。



