#!/usr/bin/env bash
set -euo pipefail
name=farm-arm-noetic
image=yahboomtechnology/ros-noetic:3.0.5
mode=${1:-shell}

if [[ "$mode" == stop ]]; then
  docker stop "$name"
  exit
fi
case "$mode" in shell|core|setup|start) ;; *) echo 'Usage: arm-noetic.sh [start|shell|core|setup|stop]' >&2; exit 2;; esac

if ! docker container inspect "$name" >/dev/null 2>&1; then
  display=${DISPLAY:-:0}
  authority=${XAUTHORITY:-/run/user/$(id -u)/gdm/Xauthority}
  if [[ ! -r "$authority" ]]; then
    echo "Cannot read X authority: $authority. Run from the Jetson desktop terminal." >&2
    exit 1
  fi
  mkdir -p "$HOME/farm-arm-data"
  docker run -d --name "$name" --network none \
    --label farm.purpose=arm-tutorial \
    -e DISPLAY="$display" -e XAUTHORITY=/tmp/desktop.xauthority \
    -e QT_X11_NO_MITSHM=1 -e LIBGL_ALWAYS_SOFTWARE=1 \
    -e ROS_IP=127.0.0.1 -e ROS_MASTER_URI=http://127.0.0.1:11311 \
    -e ROBOT_TYPE=X3plus \
    --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix,readonly \
    --mount "type=bind,src=$authority,dst=/tmp/desktop.xauthority,readonly" \
    --mount "type=bind,src=$HOME/farm-arm-data,dst=/root/farm_data" \
    --entrypoint /bin/bash "$image" --noprofile --norc -c 'exec sleep infinity'
else
  [[ $(docker inspect -f '{{index .Config.Labels "farm.purpose"}}' "$name") == arm-tutorial ]] || {
    echo "Container name already belongs to another task: $name" >&2; exit 1;
  }
  if [[ $(docker inspect -f '{{.State.Running}}' "$name") != true ]]; then
    docker start "$name"
  fi
fi
[[ "$mode" == start ]] && exit 0
case "$mode" in
  shell) set -- /bin/bash --noprofile --norc -i ;;
  core) set -- roscore ;;
  setup) set -- rosrun moveit_setup_assistant moveit_setup_assistant ;;
esac
docker exec -it "$name" /bin/bash --noprofile --norc -c '
  source /opt/ros/noetic/setup.bash
  source /root/yahboomcar_ws/devel/setup.bash --extend
  source /root/software/library_ws/devel/setup.bash --extend
  exec "$@"
' bash "$@"
