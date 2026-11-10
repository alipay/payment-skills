# CLI 不可用时恢复

仅当已经尝试执行当前钱包命令，且 shell 明确返回找不到或无法解析 `alipay-bot` 可执行文件时进入本流程。

1. 说明需要安装固定版本 `@alipay/agent-payment@1.0.31`，先取得用户对外部安装的明确同意。
2. 查询该精确版本的发布完整性：

```bash
npm view '@alipay/agent-payment@1.0.31' dist.integrity --registry 'https://registry.npmjs.org'
```

3. 结果必须逐字符等于：

```text
sha512-+bMtwDsJdpuKMxf2nIAA2n0Sm3yxGIBX24LhfjhHGA0lCLTbxkMJvVLglXd99FPGETVl3k9Y7Rx+CTnswGHcrQ==
```

不一致或无法查询时停止，不安装。

4. 一致时安装精确版本，不修改全局 npm registry 配置：

```bash
npx -y --registry=https://registry.npmjs.org @alipay/agent-payment@1.0.31 install
```

5. 安装成功后仅重试最初失败的钱包命令一次，再回到原流程处理真实输出。
