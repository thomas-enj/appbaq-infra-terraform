# AppBaq - Infrastructure

The foundational Azure cloud environment for the Azure Quiz (AppBaq) project is provisioned and managed by this repository. Infrastructure as Code (IaC) principles are strictly followed to ensure reproducible, automated, and secure cloud deployments.

## � The AppBaq Ecosystem & Deployment Order

The project is split across three interconnected repositories. A strict deployment sequence must be followed:
1. **[Infrastructure](https://github.com/thomas-enj/appbaq-infra-terraform):** The Azure cloud resources must be provisioned first (Current Repository).
2. **[Backend](https://github.com/thomas-enj/appbaq-backend):** The database schemas and API services must be deployed second.
3. **[Frontend](https://github.com/thomas-enj/appbaq-frontend):** The user interface must be deployed last.

## 🎯 Scope & Design Choices

A non-production environment is targeted, hosting a Java Spring Boot REST API and an Angular frontend. Two structural choices were made and are applied consistently across the three repositories:

| Axis | Choice |
| --- | --- |
| CI/CD tooling | GitHub Actions |
| Infrastructure target | Azure Kubernetes Service (AKS) |

Both applications are containerised and hosted on the shared AKS cluster. The application stack is completed by a PostgreSQL Flexible Server, an Azure Managed Redis instance (the legacy *Azure Cache for Redis* service no longer accepts new instances), a Storage Account, a Container Registry, and a Key Vault — all provisioned in the project resource group.

## 🗺️ Architecture Diagram

> **Status: work in progress.**

The target architecture diagram (draw.io) will be published here. The deployed infrastructure is expected to mirror it exactly; any divergence between the diagram and the provisioned resources will be documented in this section.

## 🏗️ Detailed Architecture & Terraform Modules

The infrastructure logic is centralized within the `terraform/` directory, utilizing a modular design. The following highly specialized Azure components are defined within the `terraform/modules/` folder:

* **`aks-integration`**: The connection between the shared AKS cluster and the project resources is established here — an `AcrPull` role assignment granted to the cluster kubelet identity, a bidirectional VNet peering towards the database network, and a private DNS zone link so that the PostgreSQL private FQDN can be resolved from the pods.
* **`container`**: An Azure Container Registry (Basic SKU, admin user disabled) is provisioned to store the project's Docker images.
* **`database`**: A PostgreSQL Flexible Server (`B_Standard_B1ms`, PostgreSQL 16) is deployed into a dedicated VNet with a delegated subnet and a private DNS zone, and the application database is created.
* **`keyvault`**: An Azure Key Vault is created so that application secrets and database credentials can be centralized and injected into the AKS workloads.
* **`redis`**: An Azure Managed Redis instance (`Balanced_B0`, access-key authentication) is deployed to provide caching for active quiz sessions.
* **`storage`**: A Storage Account and a private `quiz-results` blob container are configured for quiz result exports.

## 🤝 Shared Infrastructure & Ownership

The environment is hosted on the shared Simplon subscription, inside a dedicated resource group. The AKS cluster is provided by the trainer and is therefore **referenced as an existing resource**, never created by this repository. Its name, resource group, and VNet ID are supplied through variables rather than hard-coded in the Terraform code.

Ownership within the shared subscription is established through tagging. Every resource is tagged from `local.tags` in [terraform/main.tf](terraform/main.tf):

| Tag | Value |
| --- | --- |
| `owner` | Injected from the `TF_OWNER` variable |
| `environment` | `non-production` |
| `managed_by` | `terraform` |

These tags allow the project resources to be identified unambiguously within the shared subscription and are used by the downstream pipelines to resolve them.

## 🔐 Network & Secret Management

* **PostgreSQL** is deployed with private access only: a dedicated VNet and a delegated subnet are created, resolution is handled by a private DNS zone, and connectivity from the shared AKS VNet is granted through a bidirectional VNet peering and a DNS zone link. The public endpoint is disabled.
* **Storage** is restricted to private containers, public blob access is disabled, and TLS 1.2 is enforced as the minimum version. Access is delegated to the backend through a SAS token stored in Key Vault.
* **Key Vault** access is granted through access policies scoped to the deployment identity and to the frontend CI readers only. Soft-delete is kept enabled; a soft-deleted vault is recovered on the next apply rather than recreated.
* **Secrets are never committed.** Database credentials, the connection string, Redis credentials, the storage SAS token, and the backend API key are generated at apply time and stored exclusively in Key Vault, from where they are injected into the AKS workloads.

**Documented deviation.** Private endpoints are currently provisioned for PostgreSQL only. The Key Vault, the Managed Redis instance, and the Storage Account remain reachable over their public endpoints and are protected by identity-scoped access policies, access keys, and scoped SAS tokens respectively. No anonymous access is permitted on any of them. The rationale behind this trade-off is recorded in the [ADR section](#-architecture-decision-records-adr).

## ⚙️ Upfront Prerequisite: Remote State Storage

Before any automated pipeline is triggered, the remote backend for Terraform state management (`tfstate`) must be initialized. 

A specific bash script must be executed upfront by an administrator:
```bash
./deploy-remote-state-storage.sh
```

By executing this script, the underlying Azure Blob Storage infrastructure required for remote state locking and storage is properly created and configured.

## 🚀 CI/CD Pipelines & Automation

All infrastructure operations, including deployments, updates, and destruction (destroy), are completely automated via CI/CD pipelines.

* **GitHub Actions:** The execution of `terraform plan`, `terraform apply`, or `terraform destroy` is securely handled by the workflow located at `.github/workflows/terraform.yml`. Manual execution of these commands is strongly bypassed in favor of pipeline automation.
* **Authentication:** Azure authentication is performed through OIDC federated credentials. No client secret is stored in the repository.
* **Triggers:** A plan is produced on every pull request, while `apply` and `destroy` are exposed as manual `workflow_dispatch` actions.
* **Hand-off:** The Key Vault name, the ACR login server, and the shared AKS cluster name are exposed as Terraform outputs and consumed by the backend and frontend pipelines.

## 🛠️ Code Quality & Governance

Strict code quality and security standards are enforced automatically across the repository:

* **Linting & Formatting:** Code consistency is maintained by TFLint, which is configured via `terraform/.tflint.hcl`. Furthermore, Git hooks are managed by Pre-commit (`.pre-commit-config.yaml`) to ensure that no unformatted or invalid code can be pushed.
* **Security Scanning:** An IaC scan (Checkov) and a secret detection scan (Gitleaks) are executed on every push and pull request. GitHub's native secret scanning and Dependabot alerts are enabled on the repository as a second line of defence, and private vulnerability reporting is enabled so that issues can be disclosed responsibly.
* **Dependency Management:** Terraform provider versions are locked via `.terraform.lock.hcl` and are automatically kept up-to-date by Dependabot, configured in `.github/dependabot.yml`.
* **Code Ownership:** Repository review responsibilities are formally defined in `.github/CODEOWNERS`.
* **Verified Commits:** Commits are signed so that the *Verified* badge is obtained, and an incremental, prefixed commit history is maintained.

## 📒 Architecture Decision Records (ADR)

> **Status: work in progress.**

The structuring decisions taken for this environment will be recorded here, together with the alternatives that were discarded and the rationale behind each choice. The following topics are expected to be covered:

* the infrastructure target (AKS over managed services),
* the service SKUs selected under the cost constraints of the shared subscription,
* the network segmentation, and in particular why private endpoints were limited to PostgreSQL.
