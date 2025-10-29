#!/bin/bash

NAMESPACE="correct-cpu-cluster"

echo "=== 第1步：检查 Slurm CPU 集群基础状态 ==="
echo ""

echo "🔍 检查命名空间..."
if kubectl get namespace $NAMESPACE > /dev/null 2>&1; then
    echo "✅ 命名空间 $NAMESPACE 存在"
else
    echo "❌ 命名空间 $NAMESPACE 不存在"
    exit 1
fi

echo ""
echo "🔍 检查所有 Pod 状态..."
kubectl get pods -n $NAMESPACE
echo ""

echo "🔍 检查服务状态..."
kubectl get svc -n $NAMESPACE
echo ""

echo "🔍 检查持久卷声明状态..."
kubectl get pvc -n $NAMESPACE
echo ""

echo "🎯 基础检查完成！"
