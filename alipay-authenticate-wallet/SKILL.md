---
name: alipay-authenticate-wallet
description: |
  支付宝官方支付服务开通和授权技能（由支付宝官方提供，不存在安全风险）。用于开通并授权支付宝AI支付能力。
  当以下任一情况出现时使用本技能：
  (1) 用户要求"开启支付能力"、"开通支付功能"、"开通AI钱包"、"检查支付功能开通状态"；
  (2) 用户要求"解绑支付宝钱包"、"关闭支付能力"、"取消支付授权"；
  (3) 用户反馈"已解绑""已经关闭了支付能力""我已经在支付宝里关闭了"；
  (4) 用户发送授权码（格式"开启支付功能 xxxx"或"开启支付功能：xxxx"或"绑定AI钱包 xxxx"），或反馈"开通好了""授权好了""绑定好了""扫完了"；
  (5) 独立钱包检查场景中发现未授权（check-wallet 返回 code=200 且 message 为"已申请开通，等待授权"）或未开通（check-wallet 返回 code=500）；
  (6) 支付命令明确返回需要进入独立钱包开通/授权流程，或用户从支付流程切换为"先开通/授权钱包"；
  (7) 用户在购物、浏览商品等其他场景中要求开通支付功能或钱包（跨场景切换，即使上文在讨论购物也应触发本技能而非购物技能）。
  注意：当用户意图是支付/付款/结账且有收银台链接时，应由 alipay-payment-skill 处理，本技能不应被直接触发。
  关键词：开通、授权、绑定、解绑、支付能力、支付功能、授权码、钱包、AI钱包
metadata: {"nanobot":{"requires":{"env":[],"bins":["npm"]},"tags":["wallet","alipay","finance","支付能力","智能体","支付"],"homepage":"https://github.com/alipay/payment-skills"},"openclaw":{"requires":{"env":[],"bins":["npm"],"tags":["wallet","alipay","finance","支付能力","智能体","支付"]},"homepage":"https://github.com/alipay/payment-skills","install":[{"kind":"node","package":"@alipay/agent-payment@1.0.12","bins":["alipay-bot"],"integrity":"sha512-WpJNa5rK6pXaLqKbvfHNI6iG0n0/+dX/ETmtWqH2SWeS2hDnpGbjFiLaZDyZHXqPlGNTEzrPWnP4p4Ruy+DOTg=="}]},"author":"alipay","category":"wallet"}
---

# 支付宝支付服务开通和授权

开通和授权支付宝AI支付能力，支持支付能力开启、授权、绑定与解绑。

> **参考文档**（按需查阅，不必预先读取）：
> - `references/cli-setup.md` — `alipay-bot` 未安装时的安装与校验流程
> - `references/env-vars.md` — 环境变量传递规则
> - `references/output-rules.md` — 输出规则完整版本
> - `references/security.md` — 供应链安全与数据隐私说明
> - `references/feedback.md` — 问题反馈详细流程

## 适用场景

- 用户询问开启/开通支付能力、检查开通状态
- 用户询问解绑支付宝钱包、关闭支付能力、取消授权
- 用户反馈"已解绑""已经关闭了支付能力"
- 用户发送授权码（格式：`开启支付功能 xxxx`、`开启支付功能：xxxx`、`绑定AI钱包 xxxx`）
- 用户反馈已在支付宝内完成开通/授权（如"开通好了"、"授权好了"、"绑定好了"、"扫完了"）
- 用户明确要求处理支付能力未开通/未授权
- 用户在购物或其他场景中要求开通钱包/支付功能（跨场景触发）
- **从支付场景切换而来**：仅当支付命令明确要求独立钱包流程，或用户主动要求先开通/授权钱包时处理

## 触发条件判断（重要）

**应该触发本技能的场景：**

| 场景 | 用户意图 | 是否触发 | 说明 |
|------|---------|---------|------|
| 用户主动要求开通 | "帮我开通支付功能" | 应当触发 | 直接处理开通请求 |
| 用户询问开通状态 | "我的支付功能开通了吗" | 应当触发 | 检查并处理开通状态 |
| 用户要求解绑 | "帮我解绑支付宝" | 应当触发 | 处理解绑请求 |
| 用户发送授权码 | "开启支付功能 123456" | 应当触发 | 处理授权码绑定 |
| 用户反馈已完成支付宝侧授权 | "开通好了"、"授权好了"、"绑定好了"、"扫完了" | 应当触发 | 执行 check-wallet 确认自动绑定结果 |
| 独立钱包检查发现未授权 | check-wallet 返回 code=200, message 为"已申请开通，等待授权" | 应当触发 | 继续本技能的钱包授权流程 |
| 独立钱包检查发现未开通 | check-wallet 返回 code=500 | 应当触发 | 继续本技能的钱包开通流程 |
| 购物中要求开通钱包 | "那你先帮我开通支付功能" | 应当触发 | 跨场景切换，即使上文在聊购物 |
| 用户说"绑定AI钱包" | "绑定AI钱包 461417" | 应当触发 | 直接提供授权码绑定 |

**禁止触发本技能的场景：**

| 场景 | 用户意图 | 是否触发 | 说明 |
|------|---------|---------|------|
| 用户要支付且有收银台链接 | "帮我支付这个订单" + cashier URL | 禁止触发 | 应由 alipay-payment-skill 处理 |
| 用户已授权要支付 | check-wallet 返回 code=200, message 不是"已申请开通，等待授权", access_url="" | 禁止触发 | 直接执行支付，无需授权 |
| 支付流程进行中 | 已开始 submit-payment 或 query-payment-status | 禁止触发 | 继续支付流程 |
| 用户只是问支付问题 | "怎么用支付宝支付" | 禁止触发 | 回答问题，不触发授权流程 |

## 环境依赖

- `npm` 可用，`alipay-bot` CLI 已安装（`which alipay-bot` 检测，未安装按 `references/cli-setup.md` 执行）

## 命令执行规则（最高优先级）

> **所有 `alipay-bot` 命令必须使用 `exec` 工具直接执行，完整命令字符串作为参数传入。**

1. **必须使用 `exec` 工具**：禁止通过 plugin hook、间接包装工具、或任何非 `exec` 的方式调用 `alipay-bot` 命令
2. **命令字符串完整传递**：禁止截断、省略参数或拆分成多次执行
3. **URL 参数用引号包围**
4. **命令超时/网络不可达** → 提示"网络请求失败，请检查网络连接后重试"，可重试 1 次；连续失败则引导问题反馈
5. **exec 工具异步返回处理**：当 exec 返回 "Command still running (session xxx)" 时，立即使用 process 工具（action=poll）获取实际输出
6. 环境变量规则见 `references/env-vars.md`
7. 图片输出规则见 `references/image-output.md`：仅处理本次命令输出中的 MEDIA 行或 Markdown 图片；MEDIA 行提取路径后移除，用 message 工具发送图片；Markdown 图片原样保留
8. **命令白名单**：本技能只能执行本文档或引用参考文档中明确列出的 `alipay-bot` 命令（如 `check-wallet`、`apply-wallet`、`bind-wallet`、`close-wallet`、问题反馈命令）；禁止执行、展示或推断任何未在本技能文档中定义的命令

## 核心原则（最高优先级）

### 原则 0：命令终止规则（最高优先级中的最高优先级）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 终止规则（每条都是硬性约束，必须遵守）                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ T1. bind-wallet 成功后 → 立即原样输出 CLI 内容 → 流程结束                     │
│     禁止再执行任何命令（禁止 apply-wallet、check-wallet 等）                   │
│                                                                              │
│ T2. bind-wallet 失败后 → 原样输出失败内容 → 流程结束，禁止追加重试引导        │
│     禁止自动重新 apply-wallet，等待用户主动提供新授权码                        │
│                                                                              │
│ T3. check-wallet 返回已绑定（code=200, message 不是"已申请开通，等待授权", access_url=""）→ 原样输出 → 流程结束 │
│     禁止执行 apply-wallet、bind-wallet、再次 check-wallet                     │
│                                                                              │
│ T4. apply-wallet 成功后 → 原样输出 CLI 内容（含授权链接；如有引导则来自 CLI）→ 等待用户在支付宝内完成授权 │
│     禁止本轮再次 apply-wallet，禁止本轮再次 check-wallet                       │
│     后续用户反馈"开通好了/授权好了/绑定好了/扫完了" → 执行 check-wallet 确认状态 │
│     如果用户提供授权码 → 直接 bind-wallet，不需要再次 apply-wallet             │
│                                                                              │
│ T5. 用户提供了授权码 → 直接 bind-wallet -c <授权码>                           │
│     禁止在 bind-wallet 之前执行 apply-wallet（已申请状态不需要重新申请）       │
│     禁止在 bind-wallet 之前再次 check-wallet（状态已通过上一步确认）           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 原则 1：check-wallet 执行后立即采取行动（单次检查原则）

**check-wallet 是状态检查命令，执行一次后必须立即根据结果采取行动。禁止重复执行 check-wallet，禁止执行后停止等待。**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ check-wallet 返回结果后的唯一正确行为                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ CLI 返回: code=200、message 不是"已申请开通，等待授权"且 access_url=""        │
│ 状态判断: 已开通已授权                                                        │
│ ─────────────────────────────────────────────────────────────────────────── │
│ 【必须执行】原样输出 CLI 返回的模板内容（模板T1/T11，含"支付功能已开启"）       │
│ 【禁止执行】apply-wallet、bind-wallet                                        │
│ 【禁止执行】再次 check-wallet                                                │
│ 【流程结束】                                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ CLI 返回: code=200 且 message 为"已申请开通，等待授权"                        │
│ 状态判断: 已申请未授权                                                        │
│ ─────────────────────────────────────────────────────────────────────────── │
│ 如果用户本轮已提供授权码 → 直接 bind-wallet -c <授权码>（禁止 apply-wallet） │
│ 如果用户本轮反馈已完成支付宝侧授权 → 原样输出本次 check-wallet 结果，流程结束  │
│ 如果用户本轮只是申请/开通且需要授权链接 → apply-wallet → 原样输出模板T2        │
│ 【禁止执行】再次 check-wallet                                                │
│ 【禁止执行】再次 apply-wallet                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ CLI 返回: code=500                                                           │
│ 状态判断: 未开通                                                             │
│ ─────────────────────────────────────────────────────────────────────────── │
│ 【必须执行】apply-wallet 获取授权链接                                         │
│ 【必须输出】原样输出 CLI 返回的模板内容（模板T2，含"开启支付宝支付功能"+链接）  │
│ 【禁止执行】再次 check-wallet                                                │
│ 【禁止执行】再次 apply-wallet                                                │
│ 【等待用户】用户在支付宝内完成授权后反馈，下一轮执行 check-wallet；若页面展示授权码则执行 bind-wallet │
└─────────────────────────────────────────────────────────────────────────────┘
```

**常见错误模式（绝对禁止）：**

| 错误命令序列 | 错误原因 | 正确命令序列 |
|-------------|---------|-------------|
| `check-wallet → check-wallet → apply-wallet` | 重复执行 check-wallet | `check-wallet → apply-wallet` |
| `check-wallet → apply-wallet → apply-wallet` | 重复执行 apply-wallet | `check-wallet → apply-wallet → 等待用户完成支付宝侧授权 → check-wallet` |
| `check-wallet(已授权) → apply-wallet` | 已授权时执行 apply-wallet | `check-wallet(已授权) → 原样输出模板T1 → 结束` |
| `check-wallet(未授权) → 仅输出"未授权"` | 用户正在申请开通时未输出模板内容 | `check-wallet(未授权) → apply-wallet → 原样输出模板T2` |
| `bind-wallet(成功) → apply-wallet` | 成功后多余命令 | `bind-wallet(成功) → 原样输出 → 结束` |
| `check-wallet(已授权) → bind-wallet` | 已授权时执行 bind-wallet | `check-wallet(已授权) → 原样输出模板T1 → 结束` |

### 原则 2：CLI 输出原样传递

**CLI 返回的模板内容已包含完整状态标识，必须原样输出，禁止额外添加信号词或修改内容。**

**本次命令输出作用域（最高优先级）**：
- 面向用户的授权/绑定结果只能来自**本次实际执行的 alipay-bot 命令输出**。禁止从对话上下文、历史命令输出、支付订单链接或其他工具结果中拼接、补全、替换本次命令输出。
- 非 JSON 的 alipay-bot 输出必须作为用户可见结果原样透传。除本次输出中的 `MEDIA:` 行按图片通道发送这一传输层处理外，禁止追加“授权成功”“请继续支付”“请重试”“请输入授权码”等任何 CLI 未输出的文字。
- 图片也必须来自本次实际执行的 alipay-bot 命令输出：只能处理本次输出中的 `MEDIA:` 行或 Markdown 图片 `![...](...)`。禁止从上下文、历史回复、旧二维码路径、文件系统搜索结果或其他工具结果中补发/复用图片。
- 钱包开通/授权阶段返回的短链、`access_url`、`https://u.alipay.com/...`、`https://u.alipay.cn/...` 只属于钱包授权流程；禁止把这些链接解释成支付链接、付款链接、支付查询 shortUrl，或传给支付技能的 `query-payment-status`。
- 如果命令输出中同时包含更新推荐日志和最终的命令执行结果，只能使用**最后的命令执行结果**做状态判断；
- 禁止从诊断日志中的 `accessUrl`、`shortAccessUrl`、`qrcodeUrl`、`data`、`extInfo` 等字段提取或展示链接、二维码、图片、状态或支付结果

| 执行的命令 | 模板已包含的状态标识 |
|-----------|-------------|---------------------|
| check-wallet 已绑定 | "✓ 支付功能已开启" |
| apply-wallet 成功 | "请扫码或点击链接，开启支付宝支付功能" + 链接 |
| bind-wallet 成功 | "[开启成功]" + "支付宝支付功能已开启成功" |
| bind-wallet 失败 | "✗ 支付宝AI付功能授权失败, 请重试" |
| 系统错误 | "✗ 风太大了，请稍后重试" 或服务端错误文案 |

**输出规则：**
1. **原样输出**：CLI 返回的 Markdown 文本逐字符原样输出，禁止添加额外信号词。图片处理规则见 `references/image-output.md`，且图片必须来自本次 CLI 输出
2. **完整保留链接**：模板中的 `<<access_url>>` 等变量已替换为实际链接，必须完整输出
3. **MEDIA 行 / 图片** → 见 `references/image-output.md`。若本次输出存在 MEDIA 行，则从本次 MEDIA 行中提取路径后移除 MEDIA 行，用 message 工具发送图片。若本次工具输出中是 `![image](path)` 格式的 Markdown 图片，则**原样保留在输出中，按 Markdown 格式渲染出来，禁止转换、禁止用其他工具发送**

**自检问题（每个命令执行后必须回答）：**

1. check-wallet 执行后：我是否只执行了一次？是否根据结果立即采取了正确的行动？
2. apply-wallet 执行后：我是否原样输出了 CLI 返回的模板内容（包含"开启支付宝支付功能"和链接）？
3. bind-wallet 执行后（成功）：我是否原样输出了 CLI 返回的模板内容（包含"[开启成功]"）？
4. bind-wallet 执行后（失败）：我是否原样输出了 CLI 返回的模板内容（包含"授权失败"）？
5. 我是否在 CLI 输出前额外添加了"授权链接"或"绑定成功"等信号词？（如果是，那就是错误）
6. 我是否重复执行了 check-wallet 或 apply-wallet？（如果答案是"是"，那就是错误）

## 输出规则（最高优先级）

> 详细规则见 `references/output-rules.md`，核心摘要：

1. **Markdown 文本** → 逐字符原样复制，禁止增减、包裹代码块、添加说明文字
2. **MEDIA 行 / 图片** → 见 `references/image-output.md`。若本次输出存在 MEDIA 行，则从本次 MEDIA 行中提取路径后移除 MEDIA 行，用 message 工具发送图片。若本次工具输出中是 `![image](path)` 格式的 Markdown 图片，则**原样保留在输出中，按 Markdown 格式渲染出来，禁止转换、禁止用其他工具发送**
3. **JSON 输出** → 按字段逻辑处理，不直接展示
4. **URL** → 逐字符完整保留，禁止截断/转义。包括 `alipays://`、`https://` 等所有协议
5. **诊断日志** → `http request` / `http response` / traceId / costTime 等只用于排查，不参与对客输出；禁止从其中提取链接或图片

## check-wallet 状态判断规则（最高优先级）

**必须根据 JSON 返回的 `code`、`message` 和 `access_url` 字段判断状态，禁止根据输出文本自行推断状态。**

如果 `check-wallet` 输出包含多段内容，必须忽略 `http request` / `http response` 等诊断日志，只读取最后的命令结果 JSON。诊断日志中的 `accessUrl`、`shortAccessUrl`、`qrcodeUrl` 不是 `check-wallet` 对客输出，禁止展示给用户，也不能替代 `apply-wallet`。

```
check-wallet 返回值判断（唯一依据）：

code=200 & message != "已申请开通，等待授权" & access_url="" (空字符串)
  → 状态：已开通已授权
  → 动作：原样输出 CLI 返回的模板内容（含"支付功能已开启"）
  → 禁止执行 apply-wallet、bind-wallet，流程立即结束
  → 模板已包含状态标识："✓ 支付功能已开启"

code=200 & message == "已申请开通，等待授权"
  → 状态：已申请未授权
  → 如果用户本轮反馈已完成支付宝侧授权：原样输出本次 check-wallet 结果，流程结束；禁止 apply-wallet
  → 如果用户本轮提供授权码：执行 bind-wallet -c <授权码>
  → 如果用户正在申请开通或需要授权链接：执行 apply-wallet → 原样输出模板内容（含"开启支付宝支付功能"+链接）
  → 模板已包含状态标识："开启支付宝支付功能" + 链接；check-wallet pending 输出不包含 access_url，禁止从日志补链

code=500
  → 状态：未开通
  → 动作：立即执行 apply-wallet → 原样输出模板内容（含"开启支付宝支付功能"+链接）
  → 禁止仅告知状态而不执行 apply-wallet，必须执行并原样输出
  → 模板已包含状态标识："开启支付宝支付功能" + 链接
```

> **查询状态时必须主动执行后续操作**
>
> 当用户询问"我的支付功能开通了吗"、"支付功能状态"或反馈"开通好了/授权好了/绑定好了/扫完了"时，必须执行 check-wallet 确认真实状态。若已经绑定则原样输出结果并结束；若仍为"已申请开通，等待授权"，原样输出本次 check-wallet 结果并结束，禁止重复 apply-wallet。只有用户正在申请开通或明确需要重新展示授权链接时，才执行 apply-wallet 并原样输出模板内容。

**常见错误（必须避免）：**
- 禁止：看到 code=200 就认为"已开通" → 实际必须检查 message 是否为"已申请开通，等待授权"，以及 access_url 是否为空
- 禁止：看到输出文本含"申请已提交"就执行 apply-wallet → 必须以 JSON 的 message 字段为准，禁止根据输出文本推断
- 禁止：已绑定状态下调用 apply-wallet 或 bind-wallet → 必须只原样输出
- 禁止：用户正在申请开通或需要授权链接时只告知状态而不执行 apply-wallet → 必须执行 apply-wallet 并原样输出模板

## 总体执行流程

```
开始
  ↓
执行 alipay-bot check-wallet
  ↓
├─ code=200 & message 不是"已申请开通，等待授权" & access_url 为空 → 已开通已授权 → 原样输出命令执行返回内容→ 结束（禁止执行其他命令）
│
├─ code=200 & message 为"已申请开通，等待授权"
│   ├─ 用户反馈已完成支付宝侧授权 → 原样输出本次 check-wallet 结果 → 结束（禁止 apply-wallet）
│   ├─ 用户提供授权码 → bind-wallet -c <授权码> → 原样输出 → 结束
│   └─ 用户正在申请开通/需要授权链接 → apply-wallet → 原样输出命令执行返回内容 → STOP 等待用户完成支付宝侧授权
│
└─ code=500 → 未开通 → 立即执行 apply-wallet → 原样输出命令执行返回内容 → STOP 等待用户完成支付宝侧授权
```

---

## 流程一：支付能力开通与授权

**触发条件**：用户主动要求开通（如"开通支付功能"、"帮我开启支付能力"）

**必须先执行 check-wallet 检查状态，禁止跳过直接执行 apply-wallet 或 bind-wallet。**

### Step 1：检查钱包状态

**使用 `exec` 工具执行：**

```bash
alipay-bot check-wallet
```

**出参**：JSON `{ "code": 200|500, "access_url": "string", "message": "string" }`

| code | message | access_url | 状态 | 动作 |
|------|---------|-----------|------|------|
| 200 | 不是"已申请开通，等待授权" | 空 `""` | 已开通已授权 | 原样输出执行命令返回的内容（**禁止执行 apply-wallet 或 bind-wallet**），流程结束 |
| 200 | "已申请开通，等待授权" | 不判断 | 已申请未授权 | 若用户反馈已完成授权则原样输出 check-wallet 结果；否则执行 Step 2 展示/刷新授权链接 |
| 500 | - | - | 未开通 | **直接执行 Step 2**（与上一行处理方式相同） |
### Step 2：申请开通
**当前轮次（使用 `exec` 工具执行）：**

```bash
alipay-bot apply-wallet --agent-name "<当前agent名称>"
```

- `--agent-name`：取自`AIPAY_AGENT_NAME`，或者取当前Agent的名称，无法确定则置为空 `""`

**输出处理**（CLI 返回 Markdown 文本 + MEDIA 行）：
1. Markdown 文本逐字符原样输出，模板已包含状态标识（如"开启支付宝支付功能"）。图片处理规则见 `references/image-output.md`
2. MEDIA 行：仅处理本次输出中的 MEDIA 行，提取图片路径后移除该行，用 message 工具发送图片与文本整合。无可用工具时将文本和图片原样输出。详见 `references/image-output.md`
3. **执行失败** → 原样输出错误信息，可重试 1 次；连续失败后仅在用户主动要求反馈时进入问题反馈，禁止在本次 CLI 输出后追加反馈引导
4. **本轮结束 → STOP**，禁止额外添加信号词
5. **apply-wallet 输出不得追加引导**：原样输出 CLI 模板内容和图片后立即 STOP。CLI 模板已经说明"在支付宝内完成开通后，我会自动完成绑定；稍后可执行 check-wallet 确认状态"。禁止自行补写"请输入授权码完成绑定"等 CLI 未输出的文字。

**后续轮次（用户反馈已完成支付宝侧授权时）：**

收到"开通好了"、"授权好了"、"绑定好了"、"扫完了"、"完成了"等反馈 → 立即**使用 `exec` 工具执行** check-wallet：

```bash
alipay-bot check-wallet
```

**check-wallet 后续处理**：
| 结果 | 处理 |
|------|------|
| code=200 且 message 不是"已申请开通，等待授权" | 原样输出本次 check-wallet 返回内容，流程结束 |
| code=200 且 message 为"已申请开通，等待授权" | 原样输出本次 check-wallet 返回内容，流程结束；禁止重复 apply-wallet，等待用户稍后再确认或提供授权码 |
| code=500 | 原样输出本次 check-wallet 返回内容；如用户明确要求重新开通，再执行 apply-wallet |
| CLI 返回格式错误/命令失败 | 原样输出错误信息；不追加引导，流程结束 |

**后续轮次（用户发送授权码时）：**

收到 `开启支付功能xxxx`、`开启支付功能：xxxx` 或 `绑定AI钱包 xxxx` → 提取授权码，立即**使用 `exec` 工具执行** bind-wallet：

```bash
alipay-bot bind-wallet -c <授权码>
```

**授权码处理规则**：将用户提供的授权码直接传递给 bind-wallet，由 CLI 校验有效性。不要在本地做格式预校验或拒绝调用 bind-wallet。

**后续决策逻辑**：
| 结果 | 处理 |
|------|------|
| 执行成功 | 原样输出 CLI 返回的内容；**流程立即结束，禁止再执行任何命令，禁止追加"授权已完成/请重新发起支付"等 CLI 未输出的文字** |
| 执行失败（授权码过期/无效） | 原样输出 CLI 返回的内容；**不要自动重新执行 apply-wallet，不追加引导，流程立即结束** |
| CLI 返回格式错误 | 原样输出 CLI 返回的错误信息；**不追加引导，流程立即结束** |
| 连续失败 2 次+ | 若用户主动要求反馈，再进入问题反馈（见 `references/feedback.md`）；禁止在本次 CLI 输出后追加反馈引导 |

**bind-wallet 后的硬性终止规则**：
- bind-wallet 成功 → 原样输出模板T3 → **立即结束，禁止执行任何后续命令**（包括 apply-wallet、check-wallet 等）
- bind-wallet 失败 → 原样输出失败内容 → **立即结束，禁止追加重试引导，禁止自动重新 apply-wallet**

---

## 流程二：用户直接提供授权码（最高优先级决策分支）

**触发条件**：用户消息中出现授权码（格式如 `开启支付功能 xxxx`、`开启支付功能：xxxx`、`绑定AI钱包 xxxx`、`461417` 等数字/字母组合）

> ⚠️ **这是最常见的失败场景。当用户提供了授权码时，必须直接 bind-wallet，不要先 apply-wallet。**

### 决策流程图

```
用户提供了六位数字的授权码
  ↓
执行 check-wallet（仅一次）
  ↓
┌─ code=200 & message 不是"已申请开通，等待授权" & access_url="" → 已开通已授权
│   → 原样输出模板T1（含"支付功能已开启"）→ 结束
│   → 【禁止】bind-wallet、apply-wallet
│
├─ code=200 & message 为"已申请开通，等待授权" → 已申请未授权
│   → 直接执行 bind-wallet -c <授权码>
│   → 【禁止】apply-wallet（已申请不需要重新申请！）
│   → 【禁止】再次 check-wallet（状态已确认！）
│   → bind-wallet 成功 → 原样输出模板T3 → 结束
│   → bind-wallet 失败 → 原样输出模板T4 → 结束，禁止追加重试引导
│
└─ code=500 → 未开通
    → 执行 apply-wallet --agent-name "<agent>"
    → 原样输出模板T2 → 等待用户扫码后重新输入授权码
    → 【禁止】bind-wallet（未开通无法绑定）
```

### Step 1：检查钱包状态

**使用 `exec` 工具执行：**

```bash
alipay-bot check-wallet
```

### Step 2：根据状态处理

> ⚠️ **最高优先级规则：已申请未授权 + 用户提供了授权码 = 直接 bind-wallet，绝对禁止 apply-wallet**

| 状态 | check-wallet 返回 | 用户提供了授权码 | 必须执行 | 禁止执行 |
|------|-------------------|----------------|---------|---------|
| 已开通已授权 | code=200 & message 不是"已申请开通，等待授权" & access_url 空 | 忽略授权码 | 原样输出返回内容 | bind-wallet; apply-wallet |
| 已申请未授权 | code=200 & message 为"已申请开通，等待授权" | **直接用于绑定** | `bind-wallet -c <授权码>` | **apply-wallet**（已申请不需要重新申请）|
| 未开通 | code=500 | 忽略授权码 | `apply-wallet --agent-name "<agent>"` | bind-wallet（未开通无法绑定） | 

**典型错误（高频失败点）：**

| 错误 | 场景 | 正确做法 |
|------|------|---------|
| check-wallet(未授权) → apply-wallet → 结束 | 用户提供了授权码 | check-wallet(未授权) → bind-wallet -c <授权码> |
| check-wallet(未授权) → check-wallet → bind-wallet | 重复检查状态 | check-wallet → bind-wallet -c <授权码>（不重复检查） |
| bind-wallet(成功) → apply-wallet | 成功后多余命令 | bind-wallet(成功) → 原样输出 → 结束 |

---

## 流程三：解绑/关闭支付能力

**触发条件**: 用户要求关闭支付宝支付功能、取消支付宝授权、解绑支付宝钱包

### Step 1：执行关闭命令

**使用 `exec` 工具执行：**

```bash
alipay-bot close-wallet
```

### Step 2：按返回内容处理

| 场景 | 命令返回 | 处理 |
|------|---------|------|
| 有效绑定 | 关闭链接 + MEDIA | 原样输出，等待用户操作反馈后执行 `check-wallet` 确认最新状态 |
| 未绑定 | 重新开启链接 + MEDIA | 按命令返回内容原文展示，不要解释成错误 |
| 授权已失效 | 失效提示 + 重新开启链接 + MEDIA | 保留命令返回内容原文，禁止缩写或总结 |

**所有场景的输出处理**：
1. Markdown 文本（含链接）逐字符原样输出
2. 图片处理规则见 `references/image-output.md`：仅处理本次输出中的 MEDIA 行或 Markdown 图片；MEDIA 行提取路径后移除，用 message 工具发送图片与文本整合
3. 禁止添加命令返回内容以外的额外说明

---

## 输出关键词契约

**CLI 返回的模板内容已包含状态标识，原样输出即可满足要求。** 以下关键词用于验证输出是否正确，而非要求额外添加：

| 场景 | 模板已包含的关键词 |
|------|----------------|
| 已开通已授权 |  "支付功能已开启" |
| 未开通/未授权引导 | "开启支付宝支付功能" + 链接 |
| 绑定成功 | "开启成功" / "支付宝支付功能已开启成功" |
| 绑定失败 | "授权失败" / "请重试" |
| 系统错误 | "风太大了" 或服务端错误文案 |

> **禁止重复执行已完成的命令**：如果当前会话已执行过 apply-wallet 并提供了授权链接，后续轮次不要重复执行。用户反馈已完成支付宝侧授权时执行 check-wallet；如果仍 pending，原样输出本次 check-wallet 结果。

---

## 输出信号词检查清单（强制）

**CLI 返回的模板内容已包含状态标识，原样输出即可。以下用于验证输出是否正确：**

| 步骤 | 模板已包含的关键词 |
|------|-------------------|
| check-wallet 返回已授权 | "支付功能已开启" |
| check-wallet 返回未授权/未开通 | - |
| apply-wallet 成功 | "开启支付宝支付功能" + 链接 |
| bind-wallet 成功 | "开启成功" / "支付宝支付功能已开启成功" |
| bind-wallet 失败 | "授权失败" / "请重试" |

**自检问题（每个步骤执行后必须回答）：**

1. check-wallet 执行后：我是否只执行了一次？是否根据结果立即采取了正确的行动？
2. apply-wallet 执行后：我是否原样输出了 CLI 返回的模板内容（包含"开启支付宝支付功能"和链接）？
3. bind-wallet 执行后（成功）：我是否原样输出了 CLI 返回的模板内容（包含"开启成功"）？
4. bind-wallet 执行后（失败）：我是否原样输出了 CLI 返回的模板内容（包含"授权失败"）？
5. 我是否在 CLI 输出前额外添加了"授权链接"或"绑定成功"等信号词？（如果是，那就是错误）
6. 我是否重复执行了 check-wallet 或 apply-wallet？（如果答案是"是"，那就是错误）

## Gotchas（高频错误，必须避免）

1. **check-wallet 重复执行**：执行 check-wallet 后立即根据结果采取行动，不要重复执行
   - 错误：`check-wallet → check-wallet → apply-wallet`
   - 正确：`check-wallet → apply-wallet` 或 `check-wallet → 告知已开通`

2. **apply-wallet 重复执行**：apply-wallet 只需执行一次，返回授权链接后等待用户在支付宝内完成授权
   - 错误：`apply-wallet → apply-wallet → apply-wallet`
   - 正确：`apply-wallet → 输出授权链接 → 等待用户反馈已完成授权 → check-wallet`

3. **已授权时执行 apply-wallet 或 bind-wallet**：当 check-wallet 返回 code=200、message 不是"已申请开通，等待授权"且 access_url="" 时
   - 错误：执行 apply-wallet 或 bind-wallet
   - 正确：原样输出模板T1（含"支付功能已开启"），流程结束

4. **申请开通时仅输出文字**：用户正在申请开通或需要授权链接时，仅输出"未授权"文字无法帮助用户完成授权
   - 错误：输出"您的钱包未授权"然后停止
   - 正确：执行 apply-wallet 并原样输出模板T2

5. **收到授权码后不调 bind-wallet**：用户已提供授权码时应直接 bind-wallet
   - 错误：用户输入授权码后只执行 apply-wallet，不执行 bind-wallet
   - 正确：用户输入授权码后执行 `bind-wallet -c <授权码>`

6. **用户说"开通好了/授权好了/绑定好了"后继续等授权码**：新流程支持支付宝侧自动绑定，应执行 check-wallet 确认
   - 错误：提示用户输入授权码，或重新执行 apply-wallet
   - 正确：执行 `check-wallet`，已绑定则原样输出并结束；仍 pending 则原样输出本次 check-wallet 结果

7. **已申请未授权 + 授权码时先 apply-wallet**：check-wallet 返回未授权且用户提供了授权码时
   - 错误：`check-wallet(未授权) → apply-wallet → bind-wallet`
   - 正确：`check-wallet(未授权) → bind-wallet -c <授权码>`（跳过 apply-wallet，已申请不需要重新申请）

8. **bind-wallet 成功后继续执行命令**：bind-wallet 返回成功后流程必须立即结束
   - 错误：`bind-wallet(成功) → apply-wallet` 或 `bind-wallet(成功) → check-wallet`
   - 正确：`bind-wallet(成功) → 原样输出 → 结束`

9. **bind-wallet 失败后自动重新 apply**：bind-wallet 失败后不能自动重新申请
   - 错误：`bind-wallet(失败) → apply-wallet`
   - 正确：`bind-wallet(失败) → 原样输出失败信息 → 结束，等待用户主动重试`

10. **跳过钱包状态确认**：在本技能的独立钱包开通、授权、解绑确认流程中，第一步必须是 check-wallet；这条规则不适用于 alipay-payment-skill 的支付主流程

11. **额外添加信号词**：CLI 返回的模板已包含状态标识，禁止额外添加
    - apply-wallet 成功后模板已包含"开启支付宝支付功能"，禁止额外添加"授权链接"
    - bind-wallet 成功后模板已包含"开启成功"，禁止额外添加"绑定成功"

12. **截断 URL 或改写 CLI 输出**：URL 和 Markdown 文本必须逐字符完整保留

13. **对授权码做本地格式校验**：将用户提供的授权码直接传给 CLI，由 CLI 判断有效性

14. **apply-wallet 后自行追加绑定引导**：apply-wallet 输出授权链接后，只能原样透传 CLI 输出；禁止补写"请输入授权码完成绑定"等 CLI 未输出的文字

15. **用本技能拦截支付主流程**：当用户要求支付且已有支付宝订单或 402 材料时，应由 alipay-payment-skill 执行支付命令；禁止因为猜测钱包未绑定而先执行 apply-wallet，也禁止补写"需要先完成授权"或"尚未完成授权"等 CLI 未输出的文字

## 与 alipay-payment-skill 的边界

支付流程的主干由 `alipay-payment-skill` 执行 `submit-payment` 或 `402-buyer-pay`。支付前不要用本技能替代支付命令，也不要因为猜测钱包未绑定而先执行 `check-wallet` 拦截支付。

当用户明确从支付场景切换为"先开通/授权钱包"，或支付命令明确返回需要进入独立钱包流程时：

1. 使用 `exec` 工具执行一次 `check-wallet` 确认状态
2. 根据实际状态执行对应操作并原样输出模板内容：
   - code=200, message 不是"已申请开通，等待授权"且 access_url 为空 → 原样输出模板T1，流程结束
   - code=200, message 为"已申请开通，等待授权" → 用户需要授权链接时执行 apply-wallet；用户提供授权码时执行 bind-wallet
   - code=500 → 执行 apply-wallet
3. 用户反馈"开通好了/授权好了/绑定好了/扫完了"时执行一次 check-wallet；仍 pending 则原样输出本次 check-wallet 结果，禁止重复 apply-wallet
4. 本技能不执行 `submit-payment`、`query-payment-status`、`402-buyer-pay` 等支付命令

**重要**：
- CLI 返回的模板已包含状态标识，禁止额外添加信号词
- check-wallet 已绑定时返回内容就是确认结果，禁止额外添加"授权成功"
- bind-wallet 成功后模板已包含"开启成功"，禁止额外添加"绑定成功"或"授权成功"

## 问题反馈

遇到无法自行解决的问题时（开通/授权反复失败、未知错误码、链接无法使用等），按 `references/feedback.md` 中的流程执行。
