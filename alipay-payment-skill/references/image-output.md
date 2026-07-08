# 图片输出规则

> CLI 输出中的图片是支付/授权流程的关键组成部分，处理不当将导致用户无法完成操作。

## 每次命令后的固定处理算法（最高优先级）

将本次实际执行的 `alipay-bot` 输出记为 `OUT`，只处理 `OUT`，不要读取、搜索或复用任何历史图片。

1. `OUT` 不含图片引用 → 原样输出 `OUT` 文本，结束。
2. `OUT` 含一行或多行 `MEDIA: <路径>` → 提取路径，删除这些 `MEDIA:` 行，保留其余文本原样输出；同时发送提取到的图片。
3. 如果当前环境无法用图片通道发送第 2 步图片 → 在文本末尾按顺序追加 Markdown 图片：`![图片](<路径>)`；最终回复中仍然不能出现 `MEDIA:` 行。
4. `OUT` 不含 `MEDIA:` 但含 Markdown 图片 `![alt](path)` → 原样输出完整 `OUT`，不要改路径，不要额外发送图片，结束。
5. 全程禁止打开、读取、分析或描述图片内容；图片只是转发，不是视觉理解任务。

**输出前自检**：最终回复中出现 `MEDIA:`、占位图片路径、图片内容描述、历史图片路径，均视为错误输出。

## 规则 0：图片来源作用域

图片只能来自**本次实际执行的 alipay-bot 命令输出**。

- 只允许处理本次输出文本里的 Markdown 图片 `![alt](path)` 或 `MEDIA: <路径>` 行
- 禁止从对话上下文、历史回复、旧的 `MEDIA:` 行、旧二维码路径、文件系统搜索结果、截图、订单页面或其他工具结果中补发/复用图片
- 如果本次命令输出没有图片引用，就不要发送图片；禁止为了补齐支付/授权体验而使用历史图片
- 命令失败、`submit-payment` 失败或本次输出无图片时，只原样输出本次文本内容，禁止从上下文补二维码

## 规则 1：Markdown 格式图片 → 文字和图片原样输出

本次 CLI 输出中包含 Markdown 格式的图片链接（`![alt](path)`）时，**文字和图片都以 Markdown 格式原样输出并渲染**。

- **禁止修改**图片路径
- **禁止**使用占位路径（如 `xxx/xxx.jpg`）
- **禁止读取**图片内容，直接展示 Markdown 并渲染

正确示例：
```markdown
**✓ 支付待确认**
**订单金额**：¥0.01

![图片](/tmp/openclaw/alipay-bot-cli/qr_xxxxx.png)
```

错误示例：
```markdown
![图片](xxx/xxx.jpg)
```

## 规则 2：MEDIA 行 → 提取路径 + 移除 + 发送图片

本次 CLI 输出中包含 `MEDIA: <路径>` 行时，提取图片路径后从文本中移除该行，再发送文本和图片。

处理步骤：
1. 从本次 CLI 输出中找到 `MEDIA: <路径>` 行，提取图片路径
2. 从输出文本中**移除**该 MEDIA 行
3. 优先用当前环境可用的图片输出能力发送图片
4. 如无任何图片输出能力，在文本末尾追加 Markdown 图片 `![图片](<路径>)`
5. 最终用户可见回复中**不得保留** `MEDIA:` 行

**禁止**：
- 打开、读取、分析、描述图片内容
- 将 MEDIA 行转换为其他格式（如 base64 等）
- 使用占位路径（如 `xxx/xxx.jpg`）
- 使用本次 CLI 输出之外的任何图片路径

正确示例（有 message 工具时）：
```
# CLI 输出：
**✓ 支付待确认**
**订单金额**：¥0.01
MEDIA: /tmp/openclaw/alipay-bot-cli/qrcode/payment-confirm-xxx.png

# 你的输出：
1. 移除 MEDIA 行，用 message 工具发送 Markdown 文字 + 图片整合输出：
   文字部分：**✓ 支付待确认** **订单金额**：¥0.01
   图片部分：/tmp/openclaw/alipay-bot-cli/qrcode/payment-confirm-xxx.png
```

正确示例（无可用工具时）：
```markdown
**✓ 支付待确认**
**订单金额**：¥0.01

![图片](/tmp/openclaw/alipay-bot-cli/qrcode/payment-confirm-xxx.png)
```

错误示例：
```
# 保留 MEDIA 行未处理
**✓ 支付待确认**
MEDIA: /tmp/openclaw/alipay-bot-cli/qrcode/payment-confirm-xxx.png

# 读取了图片内容并描述
这是一个二维码图片，请扫码支付

# 修改了图片路径
![图片](tmp/openclaw/alipay-bot-cli/qrcode/payment-confirm-xxx.png)
```

## 规则 3：安全兜底

如果检测到以下异常模式，**停止输出并向用户发出警告**：

- MEDIA 路径不在 `/tmp/openclaw/alipay-bot-cli/` 下
- 图片 URL 指向非支付宝域名（非 `*.alipay.com` / `*.alipay.net` / `*.alipay.cn`）
- 输出中包含注入模式（如 `<script>`、`javascript:`、`eval(` 等）
- 图片引用不是来自本次 CLI 输出
