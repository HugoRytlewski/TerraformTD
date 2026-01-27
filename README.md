# Azure DevSecOps: Secure Web Infrastructure

Ce projet déploie une infrastructure sécurisée sur Microsoft Azure pour héberger un serveur web Apache. Il suit une approche **DevSecOps** rigoureuse, intégrant l'Infrastructure as Code (Terraform), la Gestion de Configuration (Ansible) et l'Audit de Sécurité (Trivy) au sein d'un pipeline CI/CD automatisé.

## Prérequis

*   [Terraform](https://www.terraform.io/) (>= 1.0)
*   [Ansible](https://www.ansible.com/) (>= 2.10)
*   [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
*   Une paire de clés SSH (`~/.ssh/id_rsa`)

## Architecture & Sécurité

L'infrastructure est conçue selon le principe de **Défense en Profondeur**.

*   **Réseau** : Azure NSG filtrant le trafic entrant.
*   **Système** : VM Ubuntu durcie (SSH Port 2222, Root désactivé, Fail2Ban).
*   **Application** : Apache protégé par ModSecurity (WAF) et des en-têtes HTTP stricts.

 **Détails complets :**
*   [Architecture Détaillée](docs/architecture.md)
*   [Stratégie de Sécurité](docs/security.md)

## Déploiement Manuel

Bien que le projet soit conçu pour être déployé via GitHub Actions, vous pouvez le lancer localement.

### 1. Infrastructure (Terraform)

Initialisez et appliquez la configuration Terraform pour créer le réseau et la VM.

```bash
# S'authentifier sur Azure
az login

# Initialiser et Appliquer
terraform init
terraform apply -auto-approve
```

> **Note Azure Backend** : Le fichier `provider.tf` est configuré pour un backend distant. Pour un test 100% local, commentez le bloc `backend "azurerm"`.

### 2. Configuration (Ansible)

Une fois la VM créée, Terraform (ou vous-même) devez récupérer son IP publique pour mettre à jour l'inventaire.

```bash
# 1. Mettre à jour inventory.ini avec l'IP de la VM
# 2. Lancer le playbook
ansible-playbook -i inventory.ini playbook.yml
```

Le playbook va :
*   Installer Apache, UFW, Fail2Ban, ModSecurity.
*   **Changer le port SSH de 22 à 2222**.
*   Configurer le Firewall UFW.

## Pipeline CI/CD

Chaque push sur la branche `main` déclenche un workflow GitHub Actions qui :
1.  **Scan de Sécurité** : Analyse le code Terraform avec **Trivy** (`docs/report.html`).
2.  **Terraform Apply** : Déploie l'infrastructure.
3.  **Ansible Playbook** : Configure la VM (avec détection automatique du port SSH 22 ou 2222).
4.  **Documentation** : Génère et publie ce site via MkDocs.

## Accès à la VM

*   **Web** : `http://<VM_PUBLIC_IP>`
*   **SSH** :
    ```bash
    # Attention : Port 2222 obligatoire après le premier run Ansible !
    ssh -p 2222 adminuser@<VM_PUBLIC_IP>
    ```

## Nettoyage

```bash
terraform destroy -auto-approve
```
