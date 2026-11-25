# Homelab

Hello! I hope this message finds you... well! If this is of interest to anyone please be aware what is within is my repository for working with Kubernetes manifests and CI validation for a small homelab environment. What you see here is a work in progress and does not represent best practices nor should it be used as a template for a production deployment. This repository exists purely for my own testing and experiment as I learn more about containers and how to manage them using Kubernetes. With that out of the way, welcome!

## Repository structure

```text
.
├── .github/workflows/main.yml   # CI: kube-linter and Trivy scans
├── .kube-linter/config.yaml     # kube-linter configuration
├── .trivy/config.yaml           # Trivy configuration template
├── dep.yaml                     # Linkding Namespace + Deployment
├── svc.yaml                     # Linkding Service
├── homepage/                    # Homepage (gethomepage) manifests
├── obsidian/                    # Obsidian web manifests
├── Dockerfile                   # Dev container image with mise-managed tools
└── mise.toml                    # Tool versions installed in the dev container
```

## Kubernetes manifests

| Path | Contents |
| --- | --- |
| [`dep.yaml`](dep.yaml) | `linkding` Namespace and Deployment (`sissbruecker/linkding:1.42.0`) |
| [`svc.yaml`](svc.yaml) | `linkding-service` LoadBalancer Service (port `9090`) |
| [`homepage/`](homepage/) | Homepage manifests: Deployment, Service (NodePort `32767`), Ingress, ConfigMap, Secret, ServiceAccount, ClusterRoleBinding, and icons |
| [`obsidian/obsidian.yaml`](obsidian/obsidian.yaml) | Obsidian web PVC, Deployment (`lscr.io/linuxserver/obsidian:latest`), and NodePort Service |

## CI/CD validation

The GitHub Actions workflow in [`.github/workflows/main.yml`](.github/workflows/main.yml) runs on pushes to `main` and on pull requests.

### kube-linter

Scans Kubernetes manifests with [`stackrox/kube-linter-action`](https://github.com/stackrox/kube-linter-action):

- Scans the repository (`directory: .`)
- Uses [`.kube-linter/config.yaml`](.kube-linter/config.yaml)
- Outputs SARIF to `kube-linter.sarif`
- Uploads results to GitHub Code Scanning via `github/codeql-action/upload-sarif`

To adjust checks, edit [`.kube-linter/config.yaml`](.kube-linter/config.yaml). For example, to exclude a check:

```yaml
checks:
  doNotAutoAddDefaults: false
  exclude:
    - "latest-tag"
```

### Trivy

Scans the repository with [`aquasecurity/trivy-action`](https://github.com/aquasecurity/trivy-action):

- `scan-type: fs` with `scan-ref: .`
- Scanners: `vuln,secret,misconfig`
- Severity filter: `CRITICAL,HIGH`
- `ignore-unfixed: true`
- Outputs SARIF to `trivy-results.sarif` and uploads to GitHub Code Scanning

The workflow sets Trivy options explicitly. [`.trivy/config.yaml`](.trivy/config.yaml) provides a config template if you want to move shared defaults into a Trivy config file and pass `trivy-config: .trivy/config.yaml`.

Common adjustments:

- **IaC/Kubernetes-only scan:** use `scan-type: config`.
- **Report without failing:** add `exit-code: '0'`.
- **Change coverage:** adjust `severity`, `ignore-unfixed`, or `scanners`.

## Development environment

The repo includes a dev container setup:

- [`.devcontainer.json`](.devcontainer.json) configures the VS Code dev container.
- [`Dockerfile`](Dockerfile) builds from `mcr.microsoft.com/devcontainers/base:ubuntu`, installs `mise`, and installs tools from [`mise.toml`](mise.toml).
- [`mise.toml`](mise.toml) currently installs `kubectl`.

## Notes

- This repository contains manifests and CI configuration; apply/deploy steps depend on your target cluster and are not automated by the current workflow.
- Lint/security scans may fail until findings are fixed or scan rules are tuned for this environment.
