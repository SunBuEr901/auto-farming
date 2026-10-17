# 参考资料与证据附件

更新：2026-10-17｜设备证据：2026-10-11 历史记录；本次未连接设备。

## 文件与参考资料

本地文件分工、历史报告、skill 分发包与 15 份厂商课程 PDF 统一从[文档库索引](../README.md)查找；远端源码和部署位置见[架构与代码地图](../architecture.md#2-本地与设备代码定位)。

| 位置 | 用途 |
|---|---|
| `/home/jetson/.bashrc` | 历史 ROS 环境与型号选择位置 |
| `/home/jetson/yahboomcar_ros2_ws/software/library_ws` | 雷达、相机等原厂库工作空间 |
| `/home/jetson/yahboomcar_ros2_ws/yahboomcar_ws` | 机器人应用工作空间 |
| `/home/jetson/Rosmaster` | 原厂库示例等资料 |
| `/tmp/farm-test-sslr28u_` | 当时相机与错误 A1 测试日志 |
| `/tmp/farm-ydlidar-2vv68sgi.log` | 正确 YDLIDAR 成功复测日志 |

`/tmp` 日志尚未作为长期附件归档，可能随清理或重启消失。历史数值来自 2026-10-11 会话记录。

- [官方 ROSMASTER X3 Plus 资料入口](https://www.yahboom.com/study/ROSMASTER-X3-PLUS)；资料访问方式按官方页面或向团队获取。
- [官方 Rosmaster 说明书](https://www.yahboom.com/build?id=5566&cid=542)，2026-10-11 记录曾读取接口布局与出厂固件说明；示例板卡版本与本机是否一致待核对。
- [官方 X3 Plus GitHub 资料](https://github.com/YahboomTechnology/ROSMASTERX3-PLUS)。选择课程时需区分主控、ROS 版本和板卡版本。

## 本地原件

- [厂商机械臂课程](arm-courses.md)：15 份 PDF，原文与本机事实区分。
- [历史照片](photos.md)：14 张原图及来源路径索引。
- [农场流程 Word 原件](plans/farm-workflow.docx)与[方案说明](../plans/farm-workflow.md)：设计设想，不是设备验收。
- [逐文件迁移清单](../reports/2026-10-17-file-inventory.json)：包含全部原件的原路径、目标路径、大小和 SHA-256。
- [待分类归档](../../archive/unclassified/README.md)：两份与项目无关的种子，未下载内容。

以上附件保持原字节。Git 中保存文档不代表已有异地备份；备份位置、恢复流程及资料许可仍待确认。
