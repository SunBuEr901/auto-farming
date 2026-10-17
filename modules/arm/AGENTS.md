# 机械臂目录阅读入口

从本目录 [README.md](README.md) 开始，只展开任务需要的文件：

- [operations.md](operations.md)：课程启动、检查、保存与停止。
- [environment.md](environment.md)：宿主机与容器环境。
- [vendor/README.md](vendor/README.md)：课程原件与原文疑点。

正文是生成副本，来源链接与校验值在文件开头；只修改来源，完成后从仓库根运行 `python tools/docs/doc_tools.py sync` 和 `python tools/docs/doc_tools.py check`。同一正文无需两处都读。跨模块任务再查[全局架构](../../docs/architecture.md)；未提供的源码、接口及设备状态明确为待验证。
