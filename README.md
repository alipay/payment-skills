# Payment Skills

English | [简体中文](#中文文档)

A collection of Alipay payment skills for AI agents, enabling seamless integration of Alipay's payment capabilities into your AI applications.

## Features

- **Alipay Wallet Authentication** - Secure wallet binding and authorization flow
- **Payment Processing** - Handle Alipay cashier links and payment status tracking
- **HTTP 402 Protocol Support** - Process A402 protocol payment flows
- **payment Feedback** - Built-in feedback mechanism for issue reporting

## Skills Included

| Skill | Description |
|-------|-------------|
| `alipay-authenticate-wallet` | Wallet binding, authorization, and management |
| `alipay-pay-for-service` | Payment processing with status polling |
| `alipay-pay-for-402-service` | HTTP 402 Payment Required protocol handler |
| `alipay-payment-feedback` | Issue reporting and feedback |

## Prerequisites

- Node.js and npm installed

## Installation

### One-Click Install (Recommended)

Install all skills and CLI tool in one command:

```bash
npx -y @alipay/agent-payment@latest install
```

### Manual Installation

Copy individual skill folders to your OpenClaw workspace:

```bash
# Install a specific skill
cp -r alipay-authenticate-wallet ~/.openclaw/workspace/skills/

# Or install all skills
cp -r alipay-* ~/.openclaw/workspace/skills/
```

## Skills on ClawHub

Each skill is also available on ClawHub:

| Skill | Description | ClawHub Link |
|-------|-------------|--------------|
| `alipay-authenticate-wallet` | Wallet binding, authorization, and management | [View on ClawHub](https://clawhub.ai/alipay/alipay-authenticate-wallet) |
| `alipay-pay-for-service` | Payment processing with status polling | [View on ClawHub](https://clawhub.ai/alipay/alipay-pay-for-service) |
| `alipay-pay-for-402-service` | HTTP 402 Payment Required protocol handler | [View on ClawHub](https://clawhub.ai/alipay/alipay-pay-for-402-service) |
| `alipay-payment-feedback` | Issue reporting and feedback | [View on ClawHub](https://clawhub.ai/alipay/alipay-payment-feedback) |

## Quick Start

The CLI tool is automatically installed during the one-click installation. If you need to install it separately:

```bash
npx -y @alipay/agent-payment@latest install-cli
```

2. **Use a skill in your agent**:
   - The skill will be triggered automatically based on context
   - Follow the skill-specific instructions in each SKILL.md

## Project Structure

```
payment-skills/
├── alipay-authenticate-wallet/    # Wallet authentication skill
│   └── SKILL.md
├── alipay-pay-for-service/        # Payment processing skill
│   └── SKILL.md
├── alipay-pay-for-402-service/    # 402 protocol skill
│   └── SKILL.md
├── alipay-payment-feedback/       # Feedback skill
│   └── SKILL.md
├── LICENSE                        # Apache 2.0 License
├── LEGAL.md                       # Legal documentation
└── README.md                      # This file
```

## Security

- All payment operations require explicit user authorization
- Sensitive credentials are never exposed to end users
- Built-in protection against common security pitfalls

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Support

For issues encountered while using the skills, use the built-in `alipay-payment-feedback` skill to report problems to the Alipay team.

---

# 中文文档

支付宝 AI 支付技能集合，为 AI 智能体提供支付宝支付能力的无缝集成。

## 功能特性

- **支付宝钱包认证** - 安全的钱包绑定与授权流程
- **支付处理** - 处理支付宝收银台链接及支付状态追踪
- **HTTP 402 协议支持** - 处理 A402 协议支付流程
- **问题反馈** - 内置问题反馈机制

## 包含技能

| 技能 | 描述 |
|------|------|
| `alipay-authenticate-wallet` | 钱包绑定、授权与管理 |
| `alipay-pay-for-service` | 支付处理与状态轮询 |
| `alipay-pay-for-402-service` | HTTP 402 Payment Required 协议处理器 |
| `alipay-payment-feedback` | 问题上报与反馈 |

## 环境要求

- 已安装 Node.js 和 npm

## 安装使用

### 一键安装（推荐）

使用一条命令安装所有技能和 CLI 工具：

```bash
npx -y @alipay/agent-payment@latest install
```

### 手动安装

将单个技能文件夹复制到 OpenClaw 工作目录：

```bash
# 安装单个技能
cp -r alipay-authenticate-wallet ~/.openclaw/workspace/skills/

# 或安装所有技能
cp -r alipay-* ~/.openclaw/workspace/skills/
```

## ClawHub 技能市场

各技能已在 ClawHub 上发布：

| 技能 | 描述 | ClawHub 链接 |
|------|------|--------------|
| `alipay-authenticate-wallet` | 钱包绑定、授权与管理 | [查看详情](https://clawhub.ai/alipay/alipay-authenticate-wallet) |
| `alipay-pay-for-service` | 支付处理与状态轮询 | [查看详情](https://clawhub.ai/alipay/alipay-pay-for-service) |
| `alipay-pay-for-402-service` | HTTP 402 协议处理器 | [查看详情](https://clawhub.ai/alipay/alipay-pay-for-402-service) |
| `alipay-payment-feedback` | 问题上报与反馈 | [查看详情](https://clawhub.ai/alipay/alipay-payment-feedback) |

## 快速开始

CLI 工具会在一键安装时自动安装。如需单独安装 CLI：

```bash
npx -y @alipay/agent-payment@latest install-cli
```

在智能体中使用技能：
- 技能会根据上下文自动触发
- 按照各 SKILL.md 中的指引操作

## 项目结构

```
payment-skills/
├── alipay-authenticate-wallet/    # 钱包认证技能
│   └── SKILL.md
├── alipay-pay-for-service/        # 支付处理技能
│   └── SKILL.md
├── alipay-pay-for-402-service/    # 402 协议技能
│   └── SKILL.md
├── alipay-payment-feedback/       # 问题反馈技能
│   └── SKILL.md
├── LICENSE                        # Apache 2.0 许可证
├── LEGAL.md                       # 合规文档
└── README.md                      # 说明文档
```

## 安全保障

- 所有支付操作需用户明确授权
- 敏感凭证不会暴露给最终用户
- 内置常见安全陷阱防护

## 开源许可

本项目采用 Apache License 2.0 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 技术支持

使用技能过程中遇到问题，可使用内置的 `alipay-payment-feedback` 技能向支付宝团队反馈，我们将尽快定位排查。
