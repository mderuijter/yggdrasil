# Yggdrasil

Personal homelab infrastructure — built as a portfolio demonstrating senior Java backend, DevOps, and cloud-native (CKAD) engineering practices end to end.

## What this demonstrates

| Skill area | Implementation |
|---|---|
| **Infrastructure as Code** | Terraform (`bpg/proxmox`) — VM and LXC provisioning on Proxmox VE |
| **Configuration management** | Ansible — OS setup, service deployment, systemd units |
| **Secrets management** | SOPS + age — secrets encrypted locally, gitignored, decrypted at plan time |
| **AI platform** | GPU passthrough, Ollama, Open WebUI — full local AI inference stack |
| **Kubernetes / CKAD** | K3s cluster (Midgard) with ArgoCD GitOps + Helm delivery *(in progress)* |
| **Event streaming** | Kafka + PostgreSQL (Nidavellir) *(in progress)* |
| **Security posture** | OWASP Top 10 compliance |

## Realms

The world tree. Each realm is an isolated VM or LXC with its own IaC.

| Realm | Type | Purpose |
|---|---|---|
| **Asgard** | VM | OPNsense — router, firewall, inter-VLAN routing |
| **Muspelheim** | VM | AI inference — GPU passthrough, Ollama, Open WebUI |
| **Midgard** | VM | K3s cluster — portfolio service deployments |
| **Nidavellir** | LXC | Kafka + PostgreSQL |
| **Helheim** | — | ZFS bulk storage pool |

## IaC layout

```
terraform/          per-realm Terraform configs
ansible/            per-realm Ansible playbooks and templates
k8s/                Helm values and ArgoCD Application resources (Midgard)
```

## Secrets management

Secrets are encrypted with [SOPS](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age). Each Terraform realm has a `secrets.enc.yaml` — kept local and gitignored, decrypted at plan time via the `carlpett/sops` provider. Ansible secrets use Ansible Vault (gitignored).

To edit encrypted secrets:
```bash
sops terraform/<realm>/secrets.enc.yaml
```

## Tech stack

Proxmox VE · Terraform · Ansible · K3s · ArgoCD · Helm · SOPS + age · Ollama · Docker · Ubuntu 24.04 · OPNsense · Kafka · PostgreSQL
