# 项目概览 (Project Overview)

## 项目简介

Soperator 是一个复杂的 Kubernetes 操作器，用于在 Kubernetes 环境中管理 Slurm 集群。它结合了 Slurm 的先进调度功能与 Kubernetes 的自动扩展和自愈功能。操作器创建了"共享根文件系统"体验，所有 Slurm 节点看起来都有统一的文件系统，使传统 Slurm 使用方式与 Kubernetes 基础设施相结合成为可能。

## 目录结构及主要职责

| 目录 | 主要职责 | 关键文件 |
|------|----------|----------|
| `api/v1/` | 核心自定义资源定义 (SlurmCluster) | [slurmcluster_types.go](api/v1/slurmcluster_types.go) - 主要集群类型定义 |
| `api/v1alpha1/` | Alpha 版本自定义资源定义 | [nodeconfigurator_types.go](api/v1alpha1/nodeconfigurator_types.go) - 节点配置<br>[nodeset_types.go](api/v1alpha1/nodeset_types.go) - 节点分组<br>[activecheck_types.go](api/v1alpha1/activecheck_types.go) - 健康检查 |
| `cmd/` | 程序入口点和各种命令行工具 | [main.go](cmd/main.go) - 主操作器入口<br>exporter/main.go - 指标导出器<br>rebooter/main.go - 重启工具<br>soperatorchecks/main.go - 检查工具 |
| `internal/` | 内部业务逻辑（不对外使用） | [controller/](internal/controller/) - 控制器实现<br>[reconciler/](internal/controller/reconciler/) - 资源协调<br>[render/](internal/render/) - 模板渲染<br>[slurmapi/](internal/slurmapi/) - Slurm API 客户端 |
| `internal/controller/` | 控制器实现 | [clustercontroller/](internal/controller/clustercontroller/) - 集群控制器<br>[nodeconfigurator/](internal/controller/nodeconfigurator/) - 节点配置控制器<br>[nodesetcontroller/](internal/controller/nodesetcontroller/) - 节点分组控制器 |
| `internal/render/` | 配置模板渲染 | [controller/](internal/render/controller/) - 控制器组件渲染<br>[worker/](internal/render/worker/) - 工作节点渲染<br>[login/](internal/render/login/) - 登录节点渲染 |
| `helm/` | Helm 图表部署 | [soperator/](helm/soperator/) - 主操作器图表<br>[slurm-cluster/](helm/slurm-cluster/) - Slurm 集群图表<br>[slurm-cluster-storage/](helm/slurm-cluster-storage/) - 存储配置 |

## 构建/运行方式

### 开发环境构建

```bash
# 基础构建
make build                    # 构建管理器二进制文件
make run                      # 在主机上运行控制器（原生工具链）
make generate                 # 生成 DeepCopy 实现
make manifests                # 生成 CRDs、webhooks、RBAC
make fmt                      # 运行 go fmt 格式化代码
make vet                      # 运行 go vet 检查代码
make test                     # 运行所有测试
make test-coverage            # 运行测试并生成覆盖率报告
make lint                     # 运行 golangci-lint 和 yamllint
make lint-fix                 # 运行 golangci-lint 自动修复
```

### Docker 和部署

```bash
# Docker 构建和推送
make docker-build-and-push    # 构建并推送多架构 Docker 镜像
make docker-build-jail        # 构建 jail 容器
make docker-manifest          # 创建多架构镜像清单
make release-helm             # 构建并推送 Helm 图表

# Helm 图表管理
make helm                     # 更新 soperator Helm 图表
make helmtest                 # 运行 Helm 图表单元测试
```

### 版本管理

```bash
make get-version              # 获取当前版本
make get-operator-tag-version # 获取操作器镜像标签
make get-image-version        # 获取完整镜像版本
make sync-version             # 同步版本到所有文件
make test-version-sync       # 测试版本一致性
```

### Kubernetes 操作

```bash
make install                  # 将 CRDs 安装到集群
make uninstall                # 从集群卸载 CRDs
make deploy                   # 部署控制器到集群
make undeploy                # 从集群移除控制器
```

### 快速开发命令

```bash
# 本地开发运行（调试模式）
make run

# 构建并测试
make build test

# 生成所有必要的文件
make sync-version-from-scratch
```

## 外部依赖

### 核心依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| **Go** | 1.25 | 主要编程语言 |
| **Kubernetes controller-runtime** | v0.22.3 | 控制器框架 |
| **Kubernetes** | v1.31+ | 目标 Kubernetes 版本 |
| **Slurm** | 25.05.4 | 支持 Slurm 版本 |
| **Ubuntu** | 24.04 | 支持的操作系统版本 |
| **CUDA** | 12.9 | 支持的 GPU 版本 |

### 开发依赖

| 工具 | 版本 | 用途 |
|------|------|------|
| controller-gen | v0.19.0 | CRD 和 webhooks 代码生成 |
| kustomize | v5.5.0 | Kubernetes 配置管理 |
| helmify | 0.4.13 | 从 Kubernetes manifest 生成 Helm 图表 |
| yq | 4.44.3 | YAML 处理和版本管理 |
| mockery | v2.53.5 | 接口 mock 生成 |
| golangci-lint | v2.5.0 | 代码 linting |

### 数据库和 API 依赖

| 依赖 | 用途 |
|------|------|
| **MariaDB** | 数据库支持（通过 CRD） |
| **Prometheus** | 监控指标支持（通过 CRD） |
| **AppArmor** | 安全配置支持（通过 CRD） |
| **OpenKruise** | 增强的 Kubernetes 原生能力 |
| **Mariadb Operator** | MariaDB 管理支持 |

### 网络要求

- CNI 必须保留客户端源 IP（推荐使用 Cilium 在 kube-proxy 替代模式下）
- 不兼容 kube-proxy 的 IPVS 模式或 kube-router/Antrea Proxy

## 容器镜像

### 主要镜像

| 镜像名称 | 用途 | 构建目标 |
|----------|------|----------|
| `slurm-operator` | 主操作器 | manager |
| `worker_slurmd` | 工作节点 | slurmd |
| `controller_slurmctld` | 控制器 | slurmctld |
| `controller_slurmdbd` | 数据库控制器 | slurmdbd |
| `login_sshd` | 登录节点 | sshd |
| `soperator-exporter` | 指标导出器 | exporter |
| `jail` | 安全容器 | jail |
| `rebooter` | 重启工具 | rebooter |

### 版本格式

- **稳定版本**: `VERSION`
- **不稳定版本**: `VERSION-SHORT_SHA`
- **完整版本格式**: `VERSION-UBUNTU_VERSION-slurmSLURM_VERSION-SHORT_SHA`

## 环境配置

### 必需的环境变量

```bash
IS_PROMETHEUS_CRD_INSTALLED=true    # 启用 Prometheus CRDs
IS_MARIADB_CRD_INSTALLED=true       # 启用 MariaDB CRDs
ENABLE_WEBHOOKS=true/false          # 启用/禁用 webhooks（本地开发禁用）
IS_APPARMOR_CRD_INSTALLED=true       # 启用 AppArmor CRDs
```

### 开发标志

```bash
-log-level=debug                    # 启用调试日志
-leader-elect=true                  # 启用领导者选举
--enable-topology-controller=true   # 启用拓扑控制器
--operator-namespace=soperator-system # 指定操作器命名空间
```

## 新手阅读顺序

### 第一阶段：基础理解（1-2天）

1. **项目结构和概念**
   - 阅读 [README.md](README.md) 了解项目背景
   - 查看 [CLAUDE.md](CLAUDE.md) 获取开发指导
   - 理解 [SlurmCluster API](api/v1/slurmcluster_types.go)

2. **核心架构**
   - 从 [cmd/main.go](cmd/main.go:117) 开始理解入口点
   - 了解控制器模式：[internal/controller/clustercontroller/](internal/controller/clustercontroller/)
   - 理解 reconcile 模式：[internal/controller/reconciler/](internal/controller/reconciler/)

### 第二阶段：深入核心（2-3天）

3. **控制器实现**
   - 集群控制器：[internal/controller/clustercontroller/](internal/controller/clustercontroller/)
   - 节点配置控制器：[internal/controller/nodeconfigurator/](internal/controller/nodeconfigurator/)
   - 节点分组控制器：[internal/controller/nodesetcontroller/](internal/controller/nodesetcontroller/)

4. **渲染系统**
   - 模板渲染基础：[internal/render/](internal/render/)
   - 控制器组件渲染：[internal/render/controller/](internal/render/controller/)
   - 工作节点渲染：[internal/render/worker/](internal/render/worker/)

### 第三阶段：高级特性（1-2天）

5. **Slurm 集成**
   - Slurm API 客户端：[internal/slurmapi/](internal/slurmapi/)
   - 配置管理：[internal/render/controller/sconfigcontroller/](internal/render/controller/sconfigcontroller/)

6. **健康监控**
   - 检查系统：[internal/controller/soperatorchecks/](internal/controller/soperatorchecks/)
   - 活动检查：[api/v1alpha1/activecheck_types.go](api/v1alpha1/activecheck_types.go)

### 第四阶段：部署和运维（1天）

7. **Helm 部署**
   - 主图表：[helm/soperator/](helm/soperator/)
   - 集群图表：[helm/slurm-cluster/](helm/slurm-cluster/)
   - 存储配置：[helm/slurm-cluster-storage/](helm/slurm-cluster-storage/)

8. **测试和质量保证**
   - 单元测试：[*_test.go](test/) 文件
   - E2E 测试：[test/e2e/](test/e2e/)
   - 代码质量：[.golangci.yaml](.golangci.yaml)

## 关键技术栈

### 编程语言和框架
- **Go 1.25**: 主要开发语言
- **Kubernetes controller-runtime**: 控制器框架
- **Kubebuilder**: API 生成工具

### 部署工具
- **Helm 3**: 包管理和部署
- **Kustomize**: 配置基线管理
- **Docker**: 容器化构建

### 监控和运维
- **Prometheus**: 指标收集和监控
- **MariaDB**: 数据存储
- **AppArmor**: 安全框架

### 网络
- **CNI (Cilium)**: 网络插件
- **Ingress**: 外部访问入口

## 常用开发命令

```bash
# 本地开发
make run                          # 运行操作器（开发模式）
make build                        # 构建二进制文件
make test                         # 运行测试

# 代码生成
make generate                     # 生成代码
make manifests                    # 生成 CRDs
make helm                         # 生成 Helm 图表

# 部署
make install                      # 安装 CRDs
make deploy                      # 部署到集群

# 质量保证
make lint                         # 代码检查
make fmt                          # 代码格式化
make vet                         # 代码验证
```

## 限制和约束

### 技术限制
- **GPU-only 或 CPU-only**: 混合配置尚不支持
- **单分区集群**: 不支持多个分区
- **软件版本限制**: 仅支持 Ubuntu 24.04、Slurm 25.05.4、CUDA 12.9
- **网络要求**: 需要特定的 CNI 要求来保留客户端源 IP

### 开发约束
- 使用 `internal/` 包作为私有代码（不对外使用）
- 遵循 Kubebuilder 约定进行 CRD 生成
- 保持操作器逻辑与资源渲染的分离
- 在测试中使用 mockery 进行接口模拟

---

*注：此文档是 Soperator 项目的概览指南，为开发者提供项目结构、构建方式、依赖关系和阅读路径的整体了解。*