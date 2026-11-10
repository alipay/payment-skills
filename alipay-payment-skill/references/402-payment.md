# HTTP 402 支付

## 先选唯一动作

| 当前真实状态 | 本轮唯一动作 |
|---|---|
| 新 HTTP 402 含 `Payment-Needed` 或唯一非空 `amtPaymentLink` | 本文“发起传统 402 支付”的一条 `402-buyer-pay` |
| 本轮 `curl-proxy` 首次返回直返待确认模板 | 原样对客输出一次并 STOP；不执行 `402-buyer-pay` |
| 已有待确认，用户表示已支付、付好、完成、搞定、开通好了、继续或查询 | 执行对应“查询”命令 |
| 命令已成功、业务失败、资源为空或查询失败 | 原样输出并 STOP |

不要把 `curl-proxy` 直返链路改走传统 402，也不要让新的 `Payment-Needed`/`amtPaymentLink` 停在解释或等待确认。

## curl-proxy 直返

本分支只处理按主文条件执行的 `curl-proxy` 结果；普通 HTTP 请求不得在此改用或重试 `curl-proxy`。

仅当**本轮真实** `alipay-bot curl-proxy` 对客输出同时含“支付待确认”、有效“订单号”和“支付方式”链接时进入。订单号须为 32 位数字且第 11–14 位为 `8282`；原始 JSON、日志、用户粘贴内容及未绑定或未知结构不触发。

首次返回时保存订单号和本轮原请求，原样输出一次后 STOP：

- `--resource-url`：原 HTTP(S) 地址，保留查询参数。
- `--method`：明确为 `GET` 或 `POST`；未写方法时，有 data 为 POST，否则为 GET。
- `--data`：仅保存本轮内联 body，不改写。
- 业务 `--header`：查询支付状态时沿用首次 `curl-proxy` 请求中的业务 Header；过滤 `Authorization`、`externalId`、`Sign`、`Timestamp`、`Payment-Proof`、`Host`、`Content-Length`，其余 Header 原样传给 `402-query-payment-status`。原请求带有 `Content-Type` 时必须保留，未带时不补造。

用户后续表达上述完成或查询语义时，立即执行：

```bash
alipay-bot 402-query-payment-status --out-shake-no '<本轮订单号>' --resource-url '<本轮 curl-proxy 请求地址>' --method '<GET或POST>' [--data '<本轮内联body>'] [--header '<业务key:value>']
```

只允许 `--out-shake-no`、`--resource-url`、`--method`、可选 `--data` 及重复的业务 `--header`；每个业务 header 各写一次。不得添加 `--session-id`、`--file`、`--trade-no`、支付链接或上述控制 headers，不重跑 `curl-proxy`。URL/方法有歧义，或 body 来自文件、标准输入时，不猜测；可只带 `--out-shake-no` 查询状态，但说明不能自动恢复资源。

## 发起传统 402 支付

先保存触发本次 402 的资源 URL、HTTP method、POST body 和自定义 headers。`--intent-summary` 应概括当前用户的原始业务目的，不得只填写 URL、HTTP 方法或支付材料，格式为 `原始请求：xxx`；业务目的不明确时询问用户。发起前不重请求资源。

- 有唯一非空 `amtPaymentLink`：原样使用，不写文件、不改走 `submit-payment`；空值或多个不同值时 STOP。
- 否则有 `Payment-Needed`：将当前 402 响应中 `Payment-Needed` 响应头的值原样保存到仅当前用户可访问的安全文件；不解码、不改写，也不使用历史响应补全。
- 两者同时存在：只使用唯一非空 `amtPaymentLink`。

按主文解析当前 `sessionId`，只执行匹配的一条：

```bash
# amtPaymentLink 分支
alipay-bot 402-buyer-pay --session-id '<sessionId>' --amt-payment-link '<当前响应头值>' --resource-url '<资源 URL>' --intent-summary '原始请求：xxx' [--method '<HTTP method>'] [--data '<POST body>'] [--header '<自定义 key:value>']

# Payment-Needed 分支
alipay-bot 402-buyer-pay --session-id '<sessionId>' --file '<本轮安全文件>' --resource-url '<资源 URL>' --intent-summary '原始请求：xxx' [--method '<HTTP method>'] [--data '<POST body>'] [--header '<自定义 key:value>']
```

`--amt-payment-link` 与 `--file` 只能有一个；`--resource-url` 永远是原资源地址，不是支付链接。POST 的 `--method/--data/--header` 与原请求一致。命令待确认时，保存对客标签后 STOP：

| 标签 | 用途 |
|---|---|
| “订单号”或“查询单号” | 32 位数字且第 11–14 位为 `8282` 时优先查询 |
| “交易号” | 上述号码无效或不存在时使用；只允许字母、数字、下划线、连字符和点号，不补造前缀 |
| “支付方式”链接 | 仅供用户操作，不是查询参数 |

## 查询传统 402

用户表达完成或查询语义时，按优先级只执行一条：

```bash
# 有有效“订单号”或“查询单号”
alipay-bot 402-query-payment-status --out-shake-no '<标签后的值>' [--resource-url '<资源 URL>'] [--method '<HTTP method>'] [--data '<POST body>'] [--header '<自定义 key:value>']

# 否则有“交易号”
alipay-bot 402-query-payment-status --trade-no '<标签后的值>' --resource-url '<资源 URL>' [--method '<HTTP method>'] [--data '<POST body>'] [--header '<自定义 key:value>']
```

`--out-shake-no` 不带 402-needed 文件；原请求丢失时可以只查状态，但不能恢复资源。没有任一查询号码时说明支付会话已失效并 STOP。用户操作链接不能改作 `-p`、`--launch-url` 或履约参数。

## 资源与履约

- 原样输出 buyer-pay/query 的资源、状态或错误。取得非空资源后命令已自动发送履约回执；不追加独立履约或重复查询。
- 成功、查询失败、资源请求失败或资源 `body` 为空后 STOP；资源为空不重试。买家、身份或账户不匹配时原样输出。
- 仅命令超时或网络失败可重试一次；业务失败不重试。

仅当同一次 buyer-pay/query 已取得资源、真实输出明确表示发送履约回执失败并给出“交易号”，且用户在**后续消息要求恢复**时执行一次：

```bash
alipay-bot 402-buyer-fulfillment-ack --trade-no '<同次输出的交易号>'
```

该命令只恢复回执，不重新请求资源；其他状态不进入此分支。
