# Payment Skills

English | [简体中文](#中文文档)

A collection of Alipay payment skills for AI agents, enabling seamless integration of Alipay's payment capabilities into your AI applications.

## Features

- **Unified Payment Processing** - Handle Alipay cashier links, HTTP 402 protocol payments, and issue reporting in a single skill
- **Alipay Wallet Authentication** - Secure wallet activation, authorization, binding, and unbinding flows
- **Supply-Chain Verified** - Each skill includes `.signature/` verification assets for integrity checking
- **Modular Documentation** - Each skill bundles `references/` for on-demand documentation (CLI setup, env vars, security, output rules, etc.)

## Skills Included

| Skill | Description |
|-------|-------------|
| `alipay-payment-skill` | Unified payment processing: cashier payment, HTTP 402 Payment Required protocol, and feedback |
| `alipay-authenticate-wallet` | Wallet activation, authorization, binding, and unbinding |

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
cp -r alipay-payment-skill ~/.openclaw/workspace/skills/

# Or install all skills
cp -r alipay-* ~/.openclaw/workspace/skills/
```

## Skills on ClawHub

Each skill is also available on ClawHub:

| Skill | Description | ClawHub Link |
|-------|-------------|--------------|
| `alipay-payment-skill` | Unified payment processing (cashier, 402, feedback) | [View on ClawHub](https://clawhub.ai/alipay/skills/alipay-payment-skill) |
| `alipay-authenticate-wallet` | Wallet activation, authorization, and management | [View on ClawHub](https://clawhub.ai/alipay/skills/alipay-authenticate-wallet) |

## Quick Start

The CLI tool is automatically installed during the installation. 

2. **Use a skill in your agent**:
   - The skill will be triggered automatically based on context
   - Follow the skill-specific instructions in each SKILL.md

## Project Structure

```
payment-skills/
├── alipay-payment-skill/             # Unified payment processing skill
│   ├── SKILL.md                      # Skill definition and payment routing
│   ├── .signature/                   # Supply-chain signature verification
│   └── references/                   # On-demand documentation
│       ├── cashier-payment.md        # Cashier payment flow
│       ├── 402-payment.md            # HTTP 402 protocol payment flow
│       ├── feedback.md               # Issue feedback flow
│       ├── cli-setup.md              # CLI installation guide
│       ├── env-vars.md               # Environment variable rules
│       ├── image-output.md           # Image output handling
│       ├── output-rules.md           # Output formatting rules
│       └── security.md               # Security and privacy notes
├── alipay-authenticate-wallet/       # Wallet authentication skill
│   ├── SKILL.md                      # Skill definition for wallet operations
│   ├── .signature/                   # Supply-chain signature verification
│   └── references/                   # On-demand documentation
│       ├── cli-setup.md              # CLI installation guide
│       ├── env-vars.md               # Environment variable rules
│       ├── feedback.md               # Issue feedback flow
│       ├── image-output.md           # Image output handling
│       ├── output-rules.md           # Output formatting rules
│       └── security.md               # Security and privacy notes
├── LICENSE                           # Apache 2.0 License
├── LEGAL.md                          # Legal documentation
└── README.md                         # This file
```

## Security

- All payment operations require explicit user authorization
- Sensitive credentials are never exposed to end users
- Built-in protection against common security pitfalls
- Supply-chain integrity verified via `.signature/` assets in each skill

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Support

For issues encountered while using the skills, use the built-in feedback flow within `alipay-payment-skill` to report problems to the Alipay team.

---

# 中文文档

支付宝 AI 支付技能集合，为 AI 智能体提供支付宝支付能力的无缝集成。

## 功能特性

- **统一支付处理** - 单一技能覆盖收银台支付、HTTP 402 协议支付、问题反馈全场景
- **支付宝钱包认证** - 安全的钱包开通、授权、绑定与解绑流程
- **供应链验证** - 每个技能包含 `.signature/` 签名验证资产，确保完整性
- **模块化文档** - 每个技能内置 `references/` 参考文档（CLI 安装、环境变量、安全说明、输出规则等），按需查阅

## 包含技能

| 技能 | 描述 |
|------|------|
| `alipay-payment-skill` | 统一支付处理：收银台支付、HTTP 402 Payment Required 协议、问题反馈 |
| `alipay-authenticate-wallet` | 钱包开通、授权、绑定与解绑 |

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
cp -r alipay-payment-skill ~/.openclaw/workspace/skills/

# 或安装所有技能
cp -r alipay-* ~/.openclaw/workspace/skills/
```

## ClawHub 技能市场

各技能已在 ClawHub 上发布：

| 技能 | 描述 | ClawHub 链接 |
|------|------|--------------|
| `alipay-payment-skill` | 统一支付处理（收银台、402 协议、反馈） | [查看详情](https://clawhub.ai/alipay/alipay-payment-skill) |
| `alipay-authenticate-wallet` | 钱包开通、授权与管理 | [查看详情](https://clawhub.ai/alipay/alipay-authenticate-wallet) |

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
├── alipay-payment-skill/             # 统一支付处理技能
│   ├── SKILL.md                      # 技能定义与支付路由
│   ├── .signature/                   # 供应链签名验证
│   └── references/                   # 按需参考文档
│       ├── cashier-payment.md        # 收银台支付流程
│       ├── 402-payment.md            # HTTP 402 协议支付流程
│       ├── feedback.md               # 问题反馈流程
│       ├── cli-setup.md              # CLI 安装指引
│       ├── env-vars.md               # 环境变量规则
│       ├── image-output.md           # 图片输出处理
│       ├── output-rules.md           # 输出格式化规则
│       └── security.md               # 安全与隐私说明
├── alipay-authenticate-wallet/       # 钱包认证技能
│   ├── SKILL.md                      # 钱包操作技能定义
│   ├── .signature/                   # 供应链签名验证
│   └── references/                   # 按需参考文档
│       ├── cli-setup.md              # CLI 安装指引
│       ├── env-vars.md               # 环境变量规则
│       ├── feedback.md               # 问题反馈流程
│       ├── image-output.md           # 图片输出处理
│       ├── output-rules.md           # 输出格式化规则
│       └── security.md               # 安全与隐私说明
├── LICENSE                           # Apache 2.0 许可证
├── LEGAL.md                          # 合规文档
└── README.md                         # 说明文档
```

## 安全保障

- 所有支付操作需用户明确授权
- 敏感凭证不会暴露给最终用户
- 内置常见安全陷阱防护
- 每个技能通过 `.signature/` 资产进行供应链完整性验证

## 开源许可

本项目采用 Apache License 2.0 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 技术支持

使用技能过程中遇到问题，可使用 `alipay-payment-skill` 内置的反馈流程向支付宝团队反馈，我们将尽快定位排查。