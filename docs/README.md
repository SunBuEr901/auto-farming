# 文档导航

更新：2026-10-17。设备事实沿用带日期的历史证据，当前在线状态未知。

## 按任务阅读

| 目的 | 文档 |
|---|---|
| 了解已知能力与阶段 | [状态](status.md)、[待验证信息](pending.md) |
| 查询设备与连接 | [硬件和接线](environment/hardware.md)、[软件环境](environment/software.md) |
| 连接、启动、检查、停止 | [使用指南总览](guides/README.md)、[远程连接](guides/remote-access.md)、[传感器](guides/sensors.md)、[录制回放](guides/data-recording.md)、[机械臂教程](guides/arm.md) |
| 遇到故障 | [故障排查](troubleshooting/README.md) |
| 定位代码和接口 | [架构与代码地图](architecture.md) |
| 按模块理解 | [机械臂](modules/arm.md)、[感知](modules/sensors.md)、[底盘](modules/chassis.md)、[主机](modules/host.md) |
| 了解尚未实施的方案 | [农场作业方案](plans/farm-workflow.md) |
| 查原始资料 | [参考资料索引](references/README.md)、[15 份课程](references/arm-courses.md)、[照片](references/photos.md) |
| 回溯过程 | [变更记录](changes/README.md)、[2026-10-11 测试](reports/2026-10-11-static-tests.md)、[阶段快照](reports/2026-10-11-milestone.md) |
| 了解本次整理 | [审查报告](reports/2026-10-17-repository-audit.md)、[逐文件迁移清单](reports/2026-10-17-file-inventory.json) |
| 维护文档 | [维护规范](maintenance.md)、[可选模板](templates.md)、[skill 源码](../skills/robot-doc-governance/SKILL.md)、[分发包](../dist/robot-doc-governance.zip)、[工具说明](../tools/docs/README.md) |

## 两种阅读位置

人可一直在本目录按上表阅读。Agent 可在[模块目录](../modules/README.md)读取同级 `README.md` 与任务文档，这些正文由集中版生成；具体映射见 [agent-mirrors.json](agent-mirrors.json)。修改集中版后同步，副本不单独编辑。历史报告与原始 PDF 按任务需要打开，不自动并入每个模块。

本仓库未包含完整 ROS 工作空间、自定义底板固件或长期原始测试日志；文档中出现的远端路径不表示本地已有源码。
