#!/bin/bash

# ===== SSH 配置 =====
SSH_CMD="/usr/bin/ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5"

# ===== Host 列表 =====
HOSTS=(
  "xxx",
  "yyy",
  "zzz"
)

# ===== 初始化 =====
ALL_OUTPUT=""
GLOBAL_FREE=0
GLOBAL_TOTAL=0

# ===== 循环每台 Host =====
for HOST in "${HOSTS[@]}"; do
  RAW_DATA=$($SSH_CMD $HOST \
    "nvidia-smi --query-gpu=index,name,utilization.gpu,memory.free,memory.total --format=csv,noheader,nounits" \
    2>/dev/null)

  if [ $? -ne 0 ] || [ -z "$RAW_DATA" ]; then
    # Host 离线
    ALL_OUTPUT+="🖥 $HOST (Offline) | color=red\n"
    continue
  fi

  # ===== Bash 层统计 =====
  HOST_TOTAL=$(echo "$RAW_DATA" | wc -l | tr -d ' ')
  HOST_FREE=$(echo "$RAW_DATA" | awk -F', ' '$3 < 5 && $4 > 4000 {c++} END {print c+0}')

  GLOBAL_TOTAL=$((GLOBAL_TOTAL + HOST_TOTAL))
  GLOBAL_FREE=$((GLOBAL_FREE + HOST_FREE))

  # ===== 菜单渲染 =====
  MENU=$(echo "$RAW_DATA" | awk -F', ' -v host="$HOST" -v hf="$HOST_FREE" -v ht="$HOST_TOTAL" '
  BEGIN {
    # 打印 Host 行
    printf "🖥 %s (%d/%d Free)\n", host, hf, ht
  }
  {
    idx=$1
    name=$2
    util=$3
    mem_free=$4
    mem_total=$5

    gsub(/NVIDIA /, "", name)
    split(name, a, "-")
    name = a[1]

    if (util < 5 && mem_free > 4000)
      icon="🟢"
    else
      icon="🔴"

    # 每个 GPU 行，保证有换行
    printf "%s [%s] %s: %d/%d MB Free (Util:%d%%) | font=Menlo size=12 refresh=true\n", \
           icon, idx, name, mem_free, mem_total, util
  }
  ')
  
  # 每台 Host 的菜单块末尾加一个换行，防止 Host 行串在一起
  ALL_OUTPUT+="$MENU"$'\n'

done

# ===== SwiftBar 顶部栏 =====
if [ "$GLOBAL_TOTAL" -eq 0 ]; then
  echo "GPU: Offline | color=red"
elif [ "$GLOBAL_FREE" -eq 0 ]; then
  echo "GPU: $GLOBAL_FREE/$GLOBAL_TOTAL Free | color=red"
else
  echo "GPU: $GLOBAL_FREE/$GLOBAL_TOTAL Free"
fi

# ===== SwiftBar 下拉菜单 =====
echo "---"
printf "%b" "$ALL_OUTPUT"
echo "---"
echo "Refresh All | refresh=true"
