# 环境变量规则

执行所有 `alipay-bot` 命令时，建议从上下文中获取以下环境变量并传递。

## 渠道环境变量（AIPAY_OUTPUT_CHANNEL）

如果能从当前消息的入站元数据中确定消息来源渠道，则在命令前设置 `AIPAY_OUTPUT_CHANNEL`。**如果无法确定渠道，则不设置此环境变量**。

**渠道值**：只取渠道标识，常见值：`feishu`、`discord`、`telegram`、`whatsapp`、`slack`、`webchat` 等。


## 上下文环境变量（建议获取并传递）

- `AIPAY_MODEL`：当前使用的模型名称（如 `gpt-4`、`glm-4` 等），获取不到时传 `default`

> 以上环境变量均为可选项，仅用于输出格式适配和问题定位，不用于用户数据收集。

## 白名单约束

执行 `alipay-bot` 命令时，**仅允许传递以上列出的环境变量**，**严禁**将任何其他环境变量传递给 CLI 命令。

## 命令执行示例

```bash
# 能确定渠道时
AIPAY_OUTPUT_CHANNEL=feishu alipay-bot check-wallet

# 无法确定渠道时
alipay-bot check-wallet

# 框架提供了全部变量时
AIPAY_OUTPUT_CHANNEL=feishu AIPAY_MODEL=gpt-4 alipay-bot check-wallet
```

> 后续所有命令模板均以 `alipay-bot xxx` 格式书写，实际执行时请根据上述规则添加相应的环境变量前缀。
