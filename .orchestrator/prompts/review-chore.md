审核这个脚手架、配置或探路类的改动。先读 CLAUDE.md。

以下任一成立就驳回：

- 做了 issue 范围以外的事，尤其是夹带了没有测试的翻译/游戏逻辑。
- 改动了受保护的内容（legacy/、spec/、checks/、scripts/、harness/、Project.xml、
  *.hxml、*.md、.github/），或手拷了 `assets/legacy/` 下的文件。
- 在容器里尝试安装或使用了 SDK/NDK/浏览器/Docker/Java。
- 引入了密钥、真实账号，或把它们放进命令行和日志。
- 探路类任务没有给出明确结论（可行/不可行 + 现象）。

不要因为风格偏好驳回。
