#!/bin/bash
# ML Platform Monitor Dashboard

while true; do
  clear
  echo "╔═══════════════════════════════════════════════════════════════╗"
  echo "║          🖥️  ML PLATFORM MONITOR - $(date '+%H:%M:%S')              ║"
  echo "╚═══════════════════════════════════════════════════════════════╝"
  
  echo -e "\n📊 NODES:"
  kubectl get nodes --no-headers | awk '{printf "   %-25s %-10s %-10s\n", $1, $2, $5}'
  
  echo -e "\n🚀 SERVICES:"
  kubectl get pods -n ml-platform --no-headers 2>/dev/null | awk '{printf "   %-40s %-12s %-10s\n", $1, $3, $5}'
  
  echo -e "\n🎯 TRAINING JOBS:"
  JOBS=$(kubectl get jobs -n ml-platform --no-headers 2>/dev/null)
  if [ -n "$JOBS" ]; then
    echo "$JOBS" | awk '{printf "   %-35s %-12s %-10s\n", $1, $2, $4}'
  else
    echo "   No training jobs"
  fi
  
  echo -e "\n🎮 GPU ALLOCATION:"
  kubectl describe node vm-mlplatform-gpu 2>/dev/null | grep -A 5 "Allocated resources" | tail -4 | sed 's/^/   /'
  
  echo -e "\n📈 TRAINING PROGRESS:"
  POD=$(kubectl get pods -n ml-platform --no-headers 2>/dev/null | grep train | grep Running | awk '{print $1}' | head -1)
  if [ -n "$POD" ]; then
    echo -n "   "
    kubectl logs $POD -n ml-platform 2>&1 | tail -1 | tr '\r' '\n' | tail -1
  else
    echo "   No training running"
  fi

  echo -e "\n💾 STORAGE:"
  kubectl get pvc -n ml-platform --no-headers 2>/dev/null | awk '{printf "   %-25s %-8s %-6s\n", $1, $4, $2}'

  echo -e "\n💽 DISK USAGE:"
  df -h / | tail -1 | awk '{printf "   Local: %s used of %s (%s)\n", $3, $2, $5}'

  echo -e "\n─────────────────────────────────────────────────────────────────"
  echo "   Press Ctrl+C to exit | Refreshing every 5s"
  
  sleep 5
done
