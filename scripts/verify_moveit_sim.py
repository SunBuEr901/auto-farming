#!/usr/bin/env python3
# coding: utf-8
"""按《1、MoveIt配置.pdf》要求验证 x3plus_moveit_config:
SRDF 规划组 arm_group / grip_group、预设位姿 up/down/int、open/close、
KDL 逆解 + OMPL 规划 + fake 控制器执行,全部走一遍。"""
import sys

import moveit_commander
import rospy
from moveit_commander.move_group import MoveGroupCommander

rospy.init_node("pdf_verify_moveit", anonymous=True, disable_signals=True)

arm = MoveGroupCommander("arm_group")
arm.set_planning_time(10)
arm.set_num_planning_attempts(10)
arm.set_goal_tolerance(0.01)
grip = MoveGroupCommander("grip_group")

results = []


def step(name, fn):
    try:
        ok = bool(fn())
    except Exception as e:  # noqa: BLE001
        ok = False
        print("[ERROR] %s: %s" % (name, e), flush=True)
    results.append(ok)
    print("[%s] %s" % ("PASS" if ok else "FAIL", name), flush=True)


step("arm_group 预设位姿 down", lambda: (arm.set_named_target("down"), arm.go())[1])
step("arm_group 预设位姿 int", lambda: (arm.set_named_target("int"), arm.go())[1])
step("arm_group 预设位姿 up", lambda: (arm.set_named_target("up"), arm.go())[1])
step("arm_group 随机目标(KDL逆解+OMPL规划)", lambda: (arm.set_random_target(), arm.go())[1])
step("grip_group 预设位姿 open", lambda: (grip.set_named_target("open"), grip.go())[1])
step("grip_group 预设位姿 close", lambda: (grip.set_named_target("close"), grip.go())[1])

passed = sum(results)
print("RESULT: %d/%d passed" % (passed, len(results)), flush=True)
moveit_commander.roscpp_shutdown()
sys.exit(0 if passed == len(results) else 1)
