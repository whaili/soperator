# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Soperator is a sophisticated Kubernetes operator that manages Slurm clusters within Kubernetes environments. It combines the advanced scheduling capabilities of Slurm with the auto-scaling and self-healing features of Kubernetes. The operator creates a "shared root filesystem" experience where all Slurm nodes appear to have a unified filesystem, making it possible to use Slurm in a traditional way while leveraging Kubernetes infrastructure.

## Development Commands

### Build and Run
```bash
make build                    # Build manager binary
make run                      # Run controller from host (native toolchain)
make generate                 # Generate DeepCopy implementations
make manifests                # Generate CRDs, webhooks, RBAC
make fmt                      # Run go fmt against code
make vet                      # Run go vet against code
make test                     # Run all tests
make test-coverage            # Run tests with coverage
make lint                     # Run golangci-lint and yamllint
make lint-fix                 # Run golangci-lint with auto-fix
```

### Docker and Deployment
```bash
make docker-build-and-push    # Build and push multi-arch Docker images
make docker-build-jail        # Build jail container
make docker-manifest          # Create multi-arch manifests
make release-helm             # Build & push Helm charts
make helm                     # Update soperator Helm chart
make helmtest                 # Run Helm chart unit tests
```

### Version Management
```bash
make get-version              # Get current version
make get-operator-tag-version # Get operator image tag
make get-image-version        # Get full image version
make sync-version             # Sync versions across all files
make test-version-sync       # Test version consistency
```

### Kubernetes Operations
```bash
make install                  # Install CRDs into cluster
make uninstall                # Uninstall CRDs from cluster
make deploy                   # Deploy controller to cluster
make undeploy                # Remove controller from cluster
```

## Architecture Overview

### Core Components

**Custom Resource Definitions (APIs):**
- `SlurmCluster` (v1) - Main cluster management resource
- `NodeConfigurator` (v1alpha1) - Node configuration management
- `ActiveCheck` (v1alpha1) - Health monitoring
- `NodeSet` (v1alpha1) - Node grouping and labeling
- `JailedConfig` (v1alpha1) - Security configurations

**Main Controllers (cmd/):**
- `main.go` - Primary operator entry point
- Controllers for SlurmCluster, NodeConfigurator, ActiveCheck, Soperator checks, Exporter, Rebooter

**Internal Architecture (internal/):**
- `clustercontroller` - Main SlurmCluster reconciliation logic
- `reconciler` - Resource management (Deployments, Services, StatefulSets)
- `nodeconfigurator` - Node configuration management
- `nodesetcontroller` - Node grouping logic
- `soperatorchecks` - Health monitoring and validation
- `sconfigcontroller` - Slurm configuration management
- `slurmapi` - SLURM API client and interactions
- `render` - Template rendering for configurations
- `exporter` - Metrics collection and Prometheus integration

### Helm Charts (13+ charts)
- `soperator` - Main operator deployment
- `slurm-cluster` - Core Slurm cluster resources
- `slurm-cluster-storage` - Persistent storage configurations
- `nodeconfigurator` - Node configuration management
- `soperatorchecks` - Health monitoring components
- `soperator-activechecks` - Active health checks
- `soperator-notifier` - Notification system
- `soperator-dcgm-exporter` - GPU monitoring (DCGM)
- `soperator-fluxcd` - GitOps integration
- `nodesets` - Node grouping
- `nfs-server` - NFS storage solution

### Key Architectural Patterns

1. **Controller Pattern**: Uses Kubernetes controller-runtime for resource reconciliation
2. **Render Pattern**: Template-based configuration generation with separation of concerns
3. **Health Monitoring Pattern**: Active health checks with configurable policies and GPU monitoring
4. **Multi-tenancy Support**: Namespace-based isolation and configurable node filtering

## Development Guidelines

### Testing Framework
- **Ginkgo/Gomega**: BDD-style testing framework for unit tests
- **Terratest**: Infrastructure testing for E2E scenarios
- **Mock generation**: Uses mockery for interface mocking
- **Integration tests**: E2E testing capabilities in `test/e2e/`

### Code Quality
- **golangci-lint**: Comprehensive linting with 30+ rules enabled
- **EditorConfig**: Code formatting standards enforced
- **Spell checking**: Codespell configuration for documentation

### File Structure Conventions
- **API definitions**: `api/v1/` and `api/v1alpha1/`
- **Controllers**: `internal/controller/`
- **Business logic**: `internal/` (not for external use)
- **Templates**: `internal/render/`
- **Utilities**: `internal/utils/`
- **Test files**: `*_test.go` alongside source files
- **Integration tests**: `test/e2e/`

### Key Entry Points
- **Main operator**: `cmd/main.go` - Initializes all controllers and webhooks
- **Core reconciliation**: `internal/controller/reconciler/reconcile.go` - Main SlurmCluster reconciliation logic
- **SLURM API client**: `internal/slurmapi/` - Handles SLURM interactions

## Dependencies and Requirements

### Core Dependencies
- **Go 1.25**: Primary language
- **Kubernetes controller-runtime v0.22.3**: Framework
- **Kubernetes v1.31+**: Required Kubernetes version
- **Slurm 25.05.4**: Supported Slurm version
- **Ubuntu 24.04**: Supported OS version
- **CUDA 12.9**: Supported GPU version

### Development Dependencies
- **controller-gen**: Code generation for CRDs and webhooks
- **kustomize**: Kubernetes configuration management
- **helmify**: Generate Helm charts from Kubernetes manifests
- **yq**: YAML processing and version management
- **mockery**: Generate interface mocks
- **golangci-lint**: Code linting

### Network Requirements
- CNI must preserve client source IP (Cilium recommended in kube-proxy replacement mode)
- Not compatible with kube-proxy in IPVS mode or kube-router/Antrea Proxy

## Image Building and Deployment

### Image Versioning
- Version format: `VERSION-UBUNTU_VERSION-slurmSLURM_VERSION-SHORT_SHA` (unstable)
- Operator image tag: `VERSION` (stable) or `VERSION-SHORT_SHA` (unstable)
- Multiple architectures: AMD64 and ARM64 support

### Container Images
- **Main operator**: `slurm-operator`
- **Worker nodes**: `worker_slurmd`
- **Controller**: `controller_slurmctld`
- **Database**: `controller_slurmdbd`
- **Login**: `login_sshd`
- **Exporter**: `soperator-exporter`
- **Jail**: `jail`
- **Rebooter**: `rebooter`

## Environment Configuration

### Required Environment Variables
- `IS_PROMETHEUS_CRD_INSTALLED`: Enable Prometheus CRDs
- `IS_MARIADB_CRD_INSTALLED`: Enable MariaDB CRDs
- `ENABLE_WEBHOOKS`: Enable/disable webhooks (disable for local development)
- `IS_APPARMOR_CRD_INSTALLED`: Enable AppArmor CRDs

### Development Flags
- `-log-level=debug`: Enable debug logging
- `-leader-elect=true`: Enable leader election
- `--enable-topology-controller=true`: Enable topology controller
- `--operator-namespace`: Specify operator namespace

## Limitations and Constraints

### Technical Limitations
- **GPU-only or CPU-only**: Mixed configurations not yet supported
- **Single-partition clusters**: Multiple partitions not supported
- **Software versions**: Limited support for Ubuntu 24.04, Slurm 25.05.4, CUDA 12.9
- **Network requirements**: Specific CNI requirements for client source IP preservation

### Development Constraints
- Use `internal/` packages for private code (not for external use)
- Follow Kubebuilder conventions for CRD generation
- Maintain separation between operator logic and resource rendering
- Use mockery for interface mocking in tests

## Code Architecture
The detailed project understanding documents are organized into five parts under the `docs/claude/` directory:  
- 01-overview.md – Project Overview (directories, responsibilities, build/run methods, external dependencies, newcomer reading order)  
- 02-entrypoint.md – Program Entry & Startup Flow (entry functions, CLI commands, initialization and startup sequence)  
- 03-callchains.md – Core Call Chains (function call tree, key logic explanations, main sequence diagram)  
- 04-modules.md – Module Dependencies & Data Flow (module relationships, data structures, request/response processing, APIs)  
- 05-architecture.md – System Architecture (overall structure, startup flow, key call chains, module dependencies, external systems, configuration)  
When answering any questions related to source code structure, module relationships, or execution flow, **always refer to these five documents first**, and include file paths and function names for clarity.

## Reply Guidelines
- Always reference **file path + function name** when explaining code.
- Use **Mermaid diagrams** for flows, call chains, and module dependencies.
- If context is missing, ask explicitly which files to `/add`.
- Never hallucinate non-existing functions or files.
- Always reply in **Chinese**

## Excluded Paths
- vendor/
- build/
- dist/
- .git/
- third_party/

## 设计文档
- 原设计文档在docs/ 目录下，你需要阅读并参考