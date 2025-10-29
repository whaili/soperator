#!/bin/bash

NAMESPACE="correct-cpu-cluster"

echo "=== 第2步：访问 Slurm 登录节点 ==="
echo ""

LOGIN_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/component=login -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$LOGIN_POD" ]; then
    echo "❌ 未找到 Login Pod"
    exit 1
fi

echo "✅ 找到 Login Pod: $LOGIN_POD"
echo ""

echo "🔍 检查登录节点环境..."
kubectl exec $LOGIN_POD -n $NAMESPACE -- whoami
echo ""

echo "🔍 检查共享存储挂载..."
kubectl exec $LOGIN_POD -n $NAMESPACE -- df -h | grep jail
echo ""

echo "🔍 检查 Slurm 安装..."
kubectl exec $LOGIN_POD -n $NAMESPACE -- which srun squeue sinfo sbatch 2>/dev/null || echo "❌ Slurm 命令不可用"
echo ""

echo "🔍 检查网络连通性..."
CONTROLLER_IP=$(kubectl get svc correct-cpu-cluster-controller-svc -n $NAMESPACE -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ ! -z "$CONTROLLER_IP" ]; then
    echo "Controller IP: $CONTROLLER_IP"
    kubectl exec $LOGIN_POD -n $NAMESPACE -- timeout 2 bash -c "</dev/tcp/$CONTROLLER_IP/6817" 2>/dev/null && echo "✅ Controller 端口可达" || echo "❌ Controller 端口不可达"
else
    echo "❌ 无法获取 Controller IP"
fi
echo ""

echo "🚀 如需交互式登录，请运行:"
echo "kubectl exec -it $LOGIN_POD -n $NAMESPACE -- bash"
echo ""

echo "✅ 登录节点访问检查完成！"
