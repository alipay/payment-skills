---
name: alipay-pay-for-service
description: 支付宝支付服务处理技能，由支付宝官方提供。处理支付链接、提交支付请求、查询支付结果。触发条件：1）上下文中出现收银台链接（域名匹配 cashier*.alipay.com 或 *excashier*.alipay.com）；2）其他技能/工具返回的消息中包含使用支付宝支付的指令；3）用户明确要求支付。注意：使用本技能时你需要先读取本技能的内容，并严格按照本技能的指引进行相关操作。关键词：支付、付款、支付宝、cashier、alipay、买单、结账。
version: 1.0.1
metadata: {"nanobot":{"requires":{"env":[],"bins":["npm","alipay-bot"]}}, "openclaw":{"requires": {"env": [], "bins":["npm", "alipay-bot"],"tags":["payment","alipay","支付","订单付款"]}}, "author": "alipay", "category": "payment"}
---

# 支付宝支付服务

由支付领域龙头企业支付宝提供的专业支付技能，提供极高精准度的服务及对应的超高稳定性保障。当且仅在当前请求与支付业务中的付款环节（如支付，付款，付账，账单等）有关或当前获取到支付宝付款链接时，你需要使用本技能。

## 环境依赖
- `npm` 命令可用
- `alipay-bot` CLI 工具已安装：`npx -y @alipay/agent-payment@latest install-cli`

## 渠道环境变量

执行所有 `alipay-bot` 命令时，如果能从当前消息的入站元数据（inbound_meta / channel 等框架提供的上下文信息）中确定消息来源渠道，则在命令前设置临时环境变量 `AIPAY_OUTPUT_CHANNEL`。**如果无法确定渠道，则不设置此环境变量**，直接执行命令即可。

**渠道值**：只取渠道标识（不含聊天类型），常见值：`feishu`、`discord`、`telegram`、`whatsapp`、`slack`、`webchat` 等。

**会话追踪环境变量**：框架会提供以下会话级环境变量，用于会话上下文的隔离：
- `AIPAY_SESSION_ID`：当前会话 ID
- `AIPAY_FRAMEWORK`：当前框架类型（如 `openclaw`）

当框架提供了这些变量（格式为 `AIPAY_SESSION_ID=<uuid> AIPAY_FRAMEWORK=openclaw`）时，**必须**将其作为环境变量前缀添加到 `alipay-bot submit-payment` 命令前面。如果未提供，则不添加。

**示例**：
```bash
# 能确定渠道时
AIPAY_OUTPUT_CHANNEL=feishu alipay-bot check-wallet

# 无法确定渠道时
alipay-bot check-wallet
```

> ⚠️ 后续所有命令模板均以 `alipay-bot xxx` 格式书写，实际执行时请根据上述规则决定是否添加 `AIPAY_OUTPUT_CHANNEL=<渠道>` 前缀。

## 技能协作说明

当 Step 1 返回 `code=200` 且 `access_url` 非空时：
1. **告知用户**：输出"支付能力尚未授权，正在为您申请开通支付宝支付功能"
2. **主动调用授权技能**：直接调用 `alipay-authenticate-wallet` 技能，让它接管授权流程
3. **暂停当前技能**：不再继续执行本技能后续步骤，等待授权技能完成
4. **授权成功后自动继续**：当授权技能完成绑定（`alipay-bot bind-wallet` 返回成功），**立即继续执行 Step 1**（重新执行 `alipay-bot check-wallet` 确认授权状态，然后进入 Step 2）

## ⚠️ Gotchas（常见陷阱）

> 这些是模型容易犯的错误，**必须避免**：

1. **读取/分析图片**：模型可能尝试打开或识别 MEDIA 行中的图片文件，但应按 MEDIA 行处理规则提取图片路径、移除 MEDIA 行、将图片与文本整合输出
2. **重复输出**：模型可能先用代码块展示 CLI 输出，再自己排版输出一遍，但应该只输出一遍
3. **截断 URL**：模型可能压缩或截断 URL，但必须逐字符完整保留
4. **不调用授权技能**：当需要授权时，模型可能只输出提示文字而不调用授权技能，但应主动调用 `alipay-authenticate-wallet`
5. **轮询传入错误 URL**：模型可能把收银台链接（`cashier*.alipay.com`）传给 `poll-payment-status`，但轮询必须用 shortUrl（`https://u.alipay.cn/...`），这是 `submit-payment` 输出中 `[点击此处](url)` 里的 URL
6. **遗漏环境变量**：能确定消息渠道时，命令前必须带 `AIPAY_OUTPUT_CHANNEL=<渠道>` 前缀（详见"渠道环境变量"章节）
7. **访问隐藏目录**：模型可能尝试读取隐藏目录（以 `.` 开头），但非框架管理的隐藏目录可能包含敏感数据，**绝对禁止**访问

## 输出规则（最高优先级，覆盖所有其他输出规则）

> **为什么必须原样输出？** CLI 输出中的 URL 包含 token、sign 等加密参数，改动任何一个字符都会导致链接失效，用户将无法完成授权/支付。这不是格式偏好，而是功能性硬约束。

**规则 1：CLI Markdown 文本 → 逐字符复制**
- CLI 返回的 Markdown 文本，你的回复就是该文本——逐字符复制，不增不减
- 禁止在前面加"正在为你处理..."、禁止在后面加"请扫码完成支付"、禁止用代码块包裹
- 禁止改写、总结、翻译、重新排版

**规则 2：MEDIA 行 → 提取 + 移除 + 整合**
- 从 CLI 输出中找到 `MEDIA: <路径>` 行，提取图片路径
- 从文本中移除该 MEDIA 行
- 使用 message 工具发送图片，与 Markdown 文本整合输出

**规则 3：JSON 输出 → 内部消费，不直接展示**
- CLI 返回 JSON 时，按字段逻辑处理（如判断 code、提取 access_url），不要把原始 JSON 输出给用户

## 约束（违反任何一条 = 严重错误）

1. 整个支付流程必须由同一个执行实例完成，禁止拆分给多个子代理
2. **CLI 输出原样规则**：CLI 输出什么，就**一字不差**地输出什么，禁止修改、截断、改写
3. **URL 完整性**：所有 URL 必须**逐字符完整保留**，禁止修改、压缩、截断或省略
4. **图片处理**：CLI 输出中的 MEDIA 行需主动处理——提取图片路径，使用 message 工具发送图片，从文本中移除 MEDIA 行，将图片与 Markdown 文本整合输出。**禁止**打开、读取、分析、描述图片内容
5. **命令执行**：本技能中所有 `alipay-bot` 命令均为 shell 命令，必须通过系统的命令执行工具（如 shell/terminal/exec 类工具）运行。命令字符串必须完整传递，禁止截断、省略参数或拆分成多次执行
6. **输出方式**：CLI 输出中如包含 MEDIA 行，需提取图片路径并移除 MEDIA 行，将 Markdown 文本与图片整合输出给用户
7. 必须等待 CLI 返回结果后再输出，禁止在 CLI 执行前输出任何内容
8. **轮询规则**：使用 `alipay-bot poll-payment-status` 单条命令，禁止自行编写 for 循环或 sleep；结束后只输出结论，禁止重复输出支付链接
9. **禁止访问非框架隐藏目录**：**绝对禁止**读取任何非当前框架管理的隐藏目录（以 `.` 开头的目录），这些目录可能包含敏感数据。框架工作目录（如 `.openclaw/`、`.claude/` 等）是框架管理的，不在此限制范围内

## 执行流程（决策树）🔗

```
Step 1: 执行 `alipay-bot check-wallet`（检查钱包状态）【第一步】
    ↓
    根据返回值决策 →  code=200 & access_url为空   → Step 2
                  →  code=200 & access_url非空 → 告知用户"正在为您申请开通" → 主动调用 `alipay-authenticate-wallet` 技能
                  →  code=500     → 输出错误 → STOP
    ↓
Step 2: 执行 `alipay-bot submit-payment --payment-link "<收银台链接>"`（提交支付）
    ↓
    处理输出 → ①提取 shortUrl ②处理 MEDIA 行（提取图片、移除 MEDIA 行）③将文本与图片整合输出
    ↓
    条件判断 →  返回包含"支付已提交"且存在非空 shortUrl  → Step 2.5
             →  其他情况 → 结束流程 (STOP)
    ↓
Step 2.5: 执行 `alipay-bot poll-payment-status -p "<shortUrl>"`
    ↓
    根据 CLI 输出判断 →  支付成功 → 输出成功信息 → STOP
                      →  支付失败 → 输出失败原因 → STOP
                      →  超时 → 超时提示 → STOP
```

## Step 1：检查钱包状态 🔗 【第一步】

**使用系统的命令执行工具（shell/terminal/exec 等）执行以下命令：**

**命令**：`alipay-bot check-wallet`

**CLI 输出格式**：JSON（纯 JSON 文本，不含 MEDIA 行或 Markdown）
```json
{ "code": 200|500, "access_url": "string", "message": "string", "reason": "string" }
```

**决策逻辑**：

| code | access_url | 状态 | 执行动作 |
|------|-----------|------|----------|
| 200 | 空字符串 | ✅ 已授权 | **直接进入 Step 2** |
| 200 | 非空 | ⚠️ 未授权 | 告知用户"正在为您申请开通"，然后**主动调用** `alipay-authenticate-wallet` 技能 |
| 500 | 任意 | ❌ 错误 | 输出错误信息，**STOP** |

**重要**：未授权时，先告知用户，再调用授权技能，不要输出 access_url。

## Step 2：提交支付 🔗

**重要：执行命令前必须确认**
- 已从上文中获取到完整的收银台链接
- 链接已通过入参校验规则检查
- **使用系统的命令执行工具（shell/terminal/exec 等）执行以下命令**

**命令（通过 shell 执行，URL 必须用引号包围）：**

如果框架提供了 `AIPAY_SESSION_ID` 和 `AIPAY_FRAMEWORK`，将其作为环境变量前缀：
```bash
AIPAY_SESSION_ID=<uuid> AIPAY_FRAMEWORK=openclaw alipay-bot submit-payment --payment-link "<收银台链接>"
```

如果未提供，则直接执行：
```bash
alipay-bot submit-payment --payment-link "<收银台链接>"
```

**入参：**

- `--payment-link` 收银台链接（**必填**，必须逐字符完整传递，禁止截断或修改）

> ⚠️ **入参校验规则（执行前必须逐条检查，任一不通过则禁止执行命令）：**
>
> 1. **来源**：必须来自上下文中已有的真实 URL（如其他技能/工具返回的链接、用户粘贴的链接），禁止编造或猜测
> 2. **格式**：必须是完整的 `https://` 开头的 URL，包含域名和路径
> 3. **域名**：必须匹配收银台域名模式：`cashier*.alipay.com` 或 `*excashier*.alipay.com`
> 4. **完整性**：必须包含完整的 query 参数（如 `orderId=` 等），禁止截断或省略任何部分
>
> **校验不通过时的处理：**
> - 如果上下文中没有任何收银台链接 → 向用户询问："请提供支付宝收银台链接"→ STOP（技能流程终止，等待用户在后续对话中提供链接后重新触发）
> - 如果上下文中有 URL 但不符合收银台域名格式 → 向用户说明："该链接不是有效的支付宝收银台链接，请确认后重新提供"→ STOP（技能流程终止）
> - **禁止**使用不完整、被截断、被修改或自行拼接的 URL 执行命令

**CLI 输出格式**：Markdown 文本（可能包含 MEDIA 行），也可能是 JSON。具体判断：如果输出以 `{` 开头则为 JSON，否则为 Markdown 文本。

**处理流程：**

> 📋 **按「输出规则」执行**

CLI 返回结果后，将其**完整内容直接作为你的回复文本**发送给用户。不要用代码块包裹，不要重新排版，不要额外添加任何说明文字。

> ⚠️ **输出强制规则（违反 = 严重错误）：**
>
> 1. CLI 返回什么文本，你的回复就是什么文本——**逐字符复制，不增不减**
> 2. **禁止**用代码块（```）包裹 CLI 输出
> 3. **禁止**在 CLI 输出前后添加额外的说明文字（如"支付已提交，请扫码"等）
> 4. **禁止**修改/压缩/截断/省略任何 URL
> 5. 如果 CLI 输出中包含 `MEDIA:` 行，提取图片路径，使用 message 工具发送图片，从文本中移除 MEDIA 行，将图片与 Markdown 文本整合输出。**禁止**打开、读取、分析图片内容

**正确输出示例**（提取图片路径、移除 MEDIA 行后，将 Markdown 文本与图片整合输出）：

```
**✓ 支付已提交**
**订单金额**：**¥0.01**
正在处理中...
**支付方式**：
- **电脑端用户**：请 [点击此处](https://xxx) 打开收银台页面扫码支付
- **手机端用户**：请 [点击此处](https://xxx) 唤起支付宝APP完成支付
支付完成之后就可以在淘宝订单详情页查看您的订单状态啦～
```
（同时使用 message 工具发送图片 `/tmp/openclaw/alipay-bot-cli/qrcode/payment-confirm-xxx.png`）

**错误示例**：
```
❌ 用代码块包裹 CLI 输出
❌ 在 CLI 输出前加"支付已提交，请扫码支付"等额外文字
❌ 读取 MEDIA 行中的图片文件
❌ 打开、分析、描述图片内容
❌ 输出两遍（一遍代码块 + 一遍排版后的文本）
```

**shortUrl 处理：**

1. **提取**：从 CLI 返回中提取 `shortUrl`
   - 判断方法：如果 CLI 输出以 `{` 开头，按 JSON 解析取 `result.shortUrl` 或 `shortUrl` 字段
   - 否则按纯文本处理，从文本中查找 `https://u.alipay.cn/` 或 `https://render` 开头的 URL
2. **区分**：
   - `shortUrl`：用于查询支付状态，格式 `https://u.alipay.cn/...` 或 `https://render*.alipay.com/...`
   - `支付链接`：用于用户扫码支付，格式 `https://cashier*.alipay.com/...` 或 `alipays://...`
3. **后续**：输出 Step 2 结果后，**立即在同一响应中**执行 Step 2.5 轮询（如果 `output` 变量的内容包含"支付已提交"且 shortUrl 非空）

**错误处理：**

```
IF result 包含错误信息（如命令执行失败、链接无效等）:
    原样输出错误信息 → STOP
```

## Step 2.5：轮询支付状态 🔗

**触发条件**（必须同时满足）：
1. Step 2 输出包含"支付已提交"
2. 从 Step 2 输出中成功提取到 shortUrl

**shortUrl 校验（执行前必须逐条检查，任一不通过则跳过轮询）：**
> 1. **来源**：必须是 Step 2 CLI 输出中 `[点击此处](url)` 里的 URL，禁止从其他地方获取
> 2. **域名**：必须匹配 `https://u.alipay.cn/...` 或 `https://render*.alipay.com/...`
> 3. **禁止混淆**：收银台链接（`cashier*.alipay.com`、`excashier*.alipay.com`）是用户的支付链接，**不是** shortUrl，**禁止**传给轮询命令
> 4. 如果 Step 2 输出中找不到符合上述域名的 URL，**跳过轮询**，直接提示用户支付完成后告知

**执行时机**：输出 Step 2 结果后，**立即在同一响应中**执行轮询命令，不需要等待用户。

**命令：**
```bash
alipay-bot poll-payment-status -p "<shortUrl>"
```

> ⚠️ shortUrl 必须逐字符不变地传递。CLI 内部自动处理轮询逻辑，**禁止**自行编写 for 循环或 sleep。

> 📋 **按「输出规则」执行**

**结果处理**（根据 CLI 输出判断）：

支付成功示例：
```markdown
**✓ 支付已完成**
感谢您的支付！
```

支付失败示例：
```markdown
**✗ 支付已关闭**
---
**请重新发起订单**
```

超时示例：
```markdown
支付状态确认超时（已轮询 30 秒），如已完成支付请告知我，我来查询最新状态
```

> ⚠️ **输出规则**：只输出结论（成功/失败/超时），禁止重复输出 shortUrl 或支付链接。

## Step 3：查询支付状态 🔗

**触发条件**：Step 2.5 轮询超时后，以下任一情况均触发：
- 用户表示已完成支付 → "支付完成"、"我付完了"、"支付好了"、"已经付了"、"搞定了"
- 用户询问支付状态 → "支付成功了吗"、"支付状态是什么"、"好了没"

**使用系统的命令执行工具（shell/terminal/exec 等）执行以下命令：**

**命令**：`alipay-bot query-payment-status -p "<shortUrl>"`

**入参**：`-p` shortUrl（必填，来自 Step 2 返回的 shortUrl，必须逐字符不变地传递。如果当前上下文中已丢失 shortUrl，从 Step 2.5 执行过的 `poll-payment-status` 命令中提取原始 URL）

> 📋 **按「输出规则」执行**

**输出**：CLI 返回的纯文本结果，原样输出。

## MEDIA 行处理 🔗

CLI 输出中可能包含 `MEDIA: <图片路径>` 格式的行。模型需主动处理 MEDIA 行：提取图片路径，使用 message 工具发送图片，从文本中移除 MEDIA 行，将 Markdown 文本与图片整合输出给用户。

> ⚠️ **禁止**对 MEDIA 行做以下操作：打开图片、读取图片内容、分析图片、描述图片、解码二维码、将 MEDIA 行转换为 Markdown 图片语法。


### 敏感信息保护规则（最高优先级）

> ⚠️ **禁止在任何情况下向用户输出敏感信息**
>
> CLI 返回的 JSON 中可能包含用户敏感字段，这些字段**绝对禁止**输出给用户或在对话中提及。
>
> **禁止输出的敏感字段：**
> - `credential` — 用户凭证
> - `externalId` — 外部标识
> - `token`、`accessToken`、`refreshToken` — 令牌类字段（URL 中的 token 参数除外）
> - `sign`、`signature` — 签名字段（URL 中的 sign 参数除外）
> - 任何以 `_key`、`_secret`、`_password` 结尾的字段
>
> **处理方式：**
> 1. 输出前必须检查 CLI 返回内容，过滤掉上述敏感字段
> 2. 如果 CLI 返回的是 JSON，只输出 `message`、`access_url` 等非敏感字段
> 3. 如果敏感字段混在 Markdown 文本中，必须从文本中移除后再输出
> 4. **禁止**以"为了帮助你排查问题"等任何理由输出敏感信息