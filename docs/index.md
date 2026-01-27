# Azure DevSecOps Pipeline

![Badge](https://img.shields.io/badge/Security-Hardened-success?style=for-the-badge&logo=shield)
![Badge](https://img.shields.io/badge/Deployed%20on-Azure-blue?style=for-the-badge&logo=microsoftazure)
![Badge](https://img.shields.io/badge/IaC-Terraform-purple?style=for-the-badge&logo=terraform)

Bienvenue sur la documentation technique du projet **DevSecOps Azure**.
Ce projet démontre le déploiement **automatisé et sécurisé** d'une infrastructure Web.

---

## Objectifs du Projet

Ce projet vise à résoudre les problématiques classiques de déploiement manuel :

* **Éliminer** les configurations manuelles (source d'erreurs).
* **Supprimer** les "Configuration Drifts" (différences entre environnements).
* **Garantir** la sécurité dès le déploiement ("Security by Design").

## Fonctionnalités Clés

| Composant | Technologie | Rôle |
| :--- | :--- | :--- |
| **Infrastructure** | Terraform | Provisioning immuable de la VM et du Réseau. |
| **Configuration** | Ansible | Installation Apache, Hardening SSH, WAF. |
| **Sécurité** | Trivy + Fail2Ban | Scan de vulnérabilités et protection brute-force. |
| **CI/CD** | GitHub Actions | Orchestration complète du pipeline. |

!!! success "État Actuel"
    Le système est opérationnel et déployé sur la région **France Central**.
    L'accès SSH est restreint au port **2222**.