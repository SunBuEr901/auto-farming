---
status: DRAFT-WRITER-POLICY-PENDING
data_trust: VERIFIED
last_verified: 2026-10-11
verified_on: farm-arm-noetic 容器（yahboomtechnology/ros-noetic:3.0.5，Jetson Orin Nano 实机）
source: SSH 实测（catkin_make 输出、move_group 启动日志、rostopic 关节角读数、rosrun 节点输出）
writer_model: GLM-5.3-Flash
---

# Current Status（当前进度总览）

## 模型政策声明（为什么本文档是 DRAFT）

- 本文档由模型 **GLM-5.3-Flash** 写入；[rules/MODEL_POLICY.md](robot-doc-governance-skill.zip 内 rules/MODEL_POLICY.md，随技能包分发) 中项目指定写入模型当前为 `TO_BE_SPECIFIED`。
- 按《Robot Documentation Governance Skill》规定：指定模型缺位时，正式文档写入应停止，或仅写入**明确标注的草稿区**。本文档因此整体标注为 `DRAFT-WRITER-POLICY-PENDING`。
- 文中所有事实条目均来自 2026-10-11 实机/容器内实测（Trust 列逐条标注），数据可信度不受写入方模型影响；但按政策，**团队在 `MODEL_POLICY.md` 指定获批模型并复核本文档后**，方可把 `status` 改为 `VERIFIED` 并删除本声明。

## Hardware

| 项目 | 当前状态 | Trust | Last Verified | Source |
|---|---|---|---|---|
| 主控 | Jetson Orin Nano，Ubuntu 22.04.5，ROS 2 Humble | VERIFIED | 2026-10-11 | `uname -a`／`lsb_release` 实测 |
| 平台 | Yahboom ROSMASTER X3 Plus（5 自由度机械臂 + 平行夹爪） | VERIFIED | 2026-10-11 | 实物核对 + URDF `yahboomcar_X3plus.urdf` |
| 雷达 | YDLIDAR TG30，约 10.15 Hz | VERIFIED | 2026-10-11 | 文档库实测记录（帧计数） |
| 深度相机 | Astra Plus，RGB/深度/红外约 28 Hz，点云 22 Hz | VERIFIED | 2026-10-11 | 文档库实测记录 |
| 底盘 | 团队已刷自定义固件；原厂协议查询 0 字节响应 | UNVERIFIED（根因未明） | 2026-10-11 | 拔插对照 + 串口实测（文档库记录） |
| 机械臂真机 | 未连接、未控制（教程容器无串口映射） | UNKNOWN | 2026-10-11 | 容器 `/dev` 无 ttyUSB/ttyACM 实测 |

## Software

| 项目 | 当前状态 | Trust | Last Verified | Source |
|---|---|---|---|---|
| 教程容器 | `farm-arm-noetic`（`--network none`，无设备映射；宿主机 `~/farm-arm-data` ↔ 容器 `/root/farm_data` 持久化） | VERIFIED | 2026-10-11 | `arm-noetic.sh` + `docker inspect` |
| MoveIt 配置包 | 预装 `x3plus_moveit_config` 与第一课 PDF 逐项一致；`catkin_make` 通过 | VERIFIED | 2026-10-11 | SRDF/yaml 核对 + catkin_make 输出 |
| 课程示例 | `arm_moveit_demo` 6 个 C++ 可执行文件 + 7 个脚本均可用 | VERIFIED | 2026-10-11 | `devel/lib/arm_moveit_demo/` 列表 + 运行实测 |
| 仿真验收 | 第 1~8 课示例全部仿真通过（第 2 课真机部分除外） | VERIFIED | 2026-10-11 | 见 [文档库/MoveIt课程2-8课仿真验收](文档库/MoveIt课程2-8课仿真验收.md) |

## Connectivity

- SSH：`jetson@192.168.43.53` 可达，已装公钥免密（IP 为热点网段，随热点变化）— VERIFIED 2026-10-11
- 远程桌面：RDP/VNC 端口通，画面未验收 — UNVERIFIED
- 容器对外网络：无（设计隔离），ROS master 仅容器内 127.0.0.1:11311 — VERIFIED

## Verified Capabilities（MoveIt 仿真）

- [x] 第 1 课：配置包核对 + 预设位姿/随机目标规划 6/6
- [x] 第 3 课：随机移动（Python + C++ 双版本，关节角实测变化）
- [x] 第 4 课：逆解 `plan success`；正解末态与目标关节角一致
- [x] 第 5 课：笛卡尔直线路径规划并执行
- [x] 第 6 课：障碍物场景随机规划 6 成功 / 4 次预期失败
- [x] 第 7 课：支撑架场景 + 末端附着块，往返规划 5/5（需 init→int 补丁）
- [x] 第 8 课：三段轨迹合并为连续轨迹执行
- [ ] 第 2 课真机控制：**未执行**（容器无串口；需团队决策真机容器方案）

## Known Problems

### `06_set_Scene.py` 引用不存在的位姿名 `init`

Status: RESOLVED（容器内已补丁；容器重建后补丁丢失，恢复命令见验收文档）

Evidence: `MoveItCommanderException: Unable to set target init`；SRDF 实际位姿名为 `int`；原版/补丁版备份于 `/root/farm_data/`。

### Python 版 `02_set_pose_plan.py` 目标坐标损坏

Status: OPEN（厂商示例数据问题，不影响 C++ 版）

Evidence: 位姿 x≈111 m（C++ 版 0.187 m），Python 版规划必然失败。

### 宿主机磁盘占用 93%

Status: MONITORING

Evidence: `df -h`，仅剩约 12 GB；录制数据前需复查。

## Next Work

- [ ] 团队在 `MODEL_POLICY.md` 指定写入模型，复核本文档后转正（改 `status: VERIFIED`，删本文件顶部声明）
- [ ] 真机容器方案决策：映射串口的新容器 + 底盘自定义固件兼容性确认，或修复原厂 `run_docker.sh`
- [ ] 课程第 9 课起视觉方向（Mediapipe / 相机接入）
