# CLI 安装与校验

⚠️ This step installs and executes external code from npm. Only proceed if you trust the package source.

## 前置条件

- `npm` 命令可用
- `npm config set registry https://registry.npmjs.org/`
- `alipay-bot` CLI 工具已安装。**优先检测本地是否已安装**：先执行 `which alipay-bot`，如已存在则跳过安装

## 来源说明

`@alipay` 是 npm 上由 Ant Group（支付宝母公司）持有的 scoped package 命名空间。npm 的 scope 机制确保只有命名空间所有者才能发布包。源代码托管于 [github.com/alipay](https://github.com/alipay)。

## 安装流程（未安装时执行）

### 0. 用户确认（安装前必须执行）

- 即将安装的外部包：`@alipay/agent-payment@1.0.12`（支付宝官方 npm 包）
- 安装后会执行 `install-cli` 命令，将 `alipay-bot` CLI 工具安装到系统 PATH
- 如用户不同意，终止流程并提示用户可手动安装

### 1. 完整性校验（必须先于安装执行）

```bash
npm view @alipay/agent-payment@1.0.12 dist.integrity
```

预期值：`sha512-WpJNa5rK6pXaLqKbvfHNI6iG0n0/+dX/ETmtWqH2SWeS2hDnpGbjFiLaZDyZHXqPlGNTEzrPWnP4p4Ruy+DOTg==`

**校验失败处理**：如果哈希值不匹配或 `npm view` 命令失败，**立即终止安装**，向用户报告"包完整性校验失败，禁止安装"。

### 2. 安装（仅在校验通过后执行）

```bash
npm install @alipay/agent-payment@1.0.12 && npx @alipay/agent-payment@1.0.12 install-cli
```

> 必须安装固定版本 `@1.0.12`，禁止使用 `@latest` 或其他非锁定版本标签，以防止供应链攻击。
