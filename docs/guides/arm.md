# 机械臂 ROS 1 与 MoveIt 入门

更新：2026-10-17｜适用：已记录的 Jetson Orin Nano 与 Noetic 3.0.5 镜像｜最后设备验证：2026-10-11。
用途：课程配置与仿真准备。证据见[机械臂实测记录](../changes/README.md#2026-10-11机械臂教程需要进入预装的-ros-1-容器)；本次仅整理文档，未复测。原始课程见[课程索引](../references/arm-courses.md)。

## 1. 为什么 roscore 找不到

厂商《1、MoveIt配置.pdf》第 1 页要求运行 `roscore`、`rosrun moveit_setup_assistant moveit_setup_assistant`，属于 ROS 1。小车宿主机为 Ubuntu 22.04.5、ROS 2 Humble，`/opt/ros` 只有 `humble`，因此宿主机终端找不到 `roscore`。

ROS 1 已在本机 Docker 镜像 `yahboomtechnology/ros-noetic:3.0.5` 中，镜像内为 Ubuntu 20.04.6、ROS Noetic。无需为这个问题重装系统或给 Humble 补装 `roscore`。

实测存在的软件包：`moveit_setup_assistant`、`arm_moveit_demo`、`x3plus_moveit_config`。镜像内车型变量使用 `X3plus`；宿主机 ROS 2 配置使用 `x3plus`，两套环境不能直接混用。

## 2. 已部署的教程入口

小车脚本：`/home/jetson/farm-tools/arm-noetic.sh`。

本地副本：[modules/arm/arm-noetic.sh](../../modules/arm/arm-noetic.sh)。容器名称固定为 `farm-arm-noetic`，多个终端操作同一个容器。首次创建后保留容器，可停止后再次启动。

容器不映射 USB、串口或底盘设备，网络使用 `none`，ROS master 在容器内部的 `127.0.0.1:11311`。支持通过只读 X11 socket 与认证文件连接 Jetson 桌面，使用软件渲染。它适用于本课配置步骤；不能直接拿来控制真机或与其他机器的 ROS 节点通信。

保存配置时使用容器内 `/root/farm_data`，对应小车宿主机 `/home/jetson/farm-arm-data`。该目录在停止或移除容器后仍保留。保存在容器其他位置的修改不具备同样的外部持久化保证。

## 3. 现在按这几步做

### 第一步：终端 A 启动 roscore

在 SSH 登录后的小车终端，或者小车桌面终端执行：

```bash
bash /home/jetson/farm-tools/arm-noetic.sh core
```

看到 `started core service [/rosout]` 表示 master 已启动。保持该终端运行。不要在另一个终端重复启动第二个 master。

### 第二步：终端 B 打开配置助手

打开第二个小车终端（SSH 可另开一个连接），执行：

```bash
bash /home/jetson/farm-tools/arm-noetic.sh setup
```

图形窗口显示在 **Jetson 的桌面 `:0`**，不会显示在 Windows PowerShell 中。需要在小车连接的显示器，或能看到该桌面的远程桌面中操作。远程桌面连接若使用另一套显示会话，需先核对 `DISPLAY`；本入口默认针对当前 `:0` 会话。

### 第三步：选择配置路线

跟随第一课从头学习，可选择 `Create New MoveIt Configuration Package`，URDF 文件为：

```text
/root/yahboomcar_ws/src/yahboomcar_description/urdf/yahboomcar_X3plus.urdf
```

此文件存在已核对，模型加载、碰撞矩阵和规划组配置仍需按课程逐步验收。新生成的配置包保存为 `/root/farm_data/x3plus_moveit_config_tutorial`，避免覆盖预装配置。

若只是查看已有配置，可选择 `Edit Existing MoveIt Configuration Package`，目录为 `/root/yahboomcar_ws/src/x3plus_moveit_config`。不要把“已有配置存在”理解为实物关节零位、限位或底板协议已经验证。

### 第四步：结束

关闭配置助手，在终端 A 按 `Ctrl+C` 停止 `roscore`。需要停止容器时执行：

```bash
bash /home/jetson/farm-tools/arm-noetic.sh stop
```

以后再次运行 `core` 会启动并复用这个容器。关闭 SSH 窗口不等于可靠地停止容器内程序。

## 4. 检查命令

进入已经加载 ROS 1 工作空间的容器终端：

```bash
bash /home/jetson/farm-tools/arm-noetic.sh shell
```

然后执行：

```bash
echo "$ROS_VERSION $ROS_DISTRO"
rosnode list
rospack find moveit_setup_assistant
rospack find x3plus_moveit_config
```

预期环境为 `1 noetic`。只有终端 A 正在运行 master 时，`rosnode list` 才能正常连接。退出此交互终端用 `exit`。

## 5. 原厂启动脚本的问题

`/home/jetson/run_docker.sh` 使用 `xhost +`，并绑定固定 USB 编号和多个设备。2026-10-11 实测 `/dev/camera_depth` 不存在；其中硬编码 USB 路径也不等同于当时相机别名所指路径。直接运行可能因设备不存在而失败。当时保留原脚本，另部署独立教程入口；本次仅迁移本地副本。

## 6. 重启与待验证边界

桌面重新登录或小车重启后，X11 认证文件可能变化。若 `core` 正常但助手提示无法连接显示，先核对当前桌面的 `DISPLAY` 与 `XAUTHORITY`，不要直接执行 `xhost +`。旧容器可能需要在保存配置后重新创建以更新认证挂载；不要未经备份就删除容器。

2026-10-11 完成 ROS master 和软件环境检查，容器内 `xdpyinfo` 成功，并通过 `xwininfo` 确认配置助手已创建标题为 `MoveIt Setup Assistant` 的 1090×600 窗口。测试程序结束，容器保留并停止，执行第一步即可重启。未截图核对窗口内容。模型加载、配置生成、RViz 规划、真实舵机通信与运动、远程桌面画面验收分别记录，不能用 `roscore` 成功替代。

## 厂商课程原件

课程文件、适用边界和原文疑点见[课程索引](../references/arm-courses.md)。
