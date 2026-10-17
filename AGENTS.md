# 项目工作约定

本仓库是无人农场小车的长期数字文档中心。正文维护在 `docs/`，模块同级副本由工具生成。

## 按任务读取

先用下表选入口，不要求每次读全局索引、状态和全部历史。

| 任务 | 首选入口 |
|---|---|
| 全局状态、计划或跨模块问题 | [docs 导航](docs/README.md)、[状态](docs/status.md)、[待验证](docs/pending.md) |
| 机械臂课程、教程脚本 | [modules/arm/AGENTS.md](modules/arm/AGENTS.md) |
| 雷达、相机、录制 | [modules/sensors/AGENTS.md](modules/sensors/AGENTS.md) |
| 底盘或自定义固件 | [modules/chassis/AGENTS.md](modules/chassis/AGENTS.md) |
| 网络、主机环境、桌面 | [modules/host/AGENTS.md](modules/host/AGENTS.md) |
| 文档结构或维护工具 | [维护规范](docs/maintenance.md)、[文档工具](tools/docs/README.md) |

模块入口列出的同级文档足够时，不再重复读取集中版。编程需核对真实源码；远端路径不是本地源码。仅在任务需要时展开相关报告或 PDF。

## 维护规则

- 按 [robot-doc-governance skill](skills/robot-doc-governance/SKILL.md) 利用和维护文档。集中正文是手工维护源；生成副本有来源和 SHA-256，修改来源后运行 `python tools/docs/doc_tools.py sync`，再运行 `python tools/docs/doc_tools.py check`。
- 新环境、根因、配置、命令或测试结果写入受影响的主文档，并在 [变更记录](docs/changes/README.md)追加日期、证据、操作、结果和未验证项。操作变化同步[使用指南](docs/guides/README.md)或其专题；新专题更新导航，重要阶段更新根 README。
- 仅查询或润色且无新工程事实，不增加工程记录。结构变更记录本地成果，不改写设备能力。
- 区分实测、历史记录、用户确认、厂商示例、设计设想和待验证；未知写 TODO / 待验证，不猜参数、IP、版本、状态或结果。旧结论被推翻时标明取代关系并保留历史。
- 不保存密码、令牌或 X11 认证 cookie。日志归档前脱敏。
- ROS master、图形窗口、模型加载、仿真、真机通信、运动和停止分别验收。文档更新、本地修改、部署与设备复测分别说明。

文件名采用小写英文与连字符，正文可用中文；具体约定见[维护规范](docs/maintenance.md)。文档流程不扩大执行授权，不自动连接设备、控制硬件、提交或推送。
