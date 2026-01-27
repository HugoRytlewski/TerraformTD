# Stratégie de Sécurité (Hardening)

La sécurité est appliquée en "couches" (Defense in Depth).

## Mesures Appliquées

### Niveau Réseau (Azure NSG & UFW)
* Seuls les ports strictement nécessaires sont ouverts.
* Le pare-feu interne (UFW) bloque tout trafic sortant suspect.

### Niveau Système (OS)
* **Fail2Ban** : Bannit les IP après 3 tentatives SSH échouées.
* **SSH Hardening** :
    * Désactivation authentification par mot de passe.
    * Changement de port (22 -> 2222).
    * Désactivation Login Root.
* **Kernel** : Protection contre les attaques ICMP Redirect et SYN Flood.

### Niveau Application (Web)
* **ModSecurity** : Pare-feu applicatif (WAF) activé.
* **CSP Strict** : `Content-Security-Policy` configurée pour bloquer le XSS.
* **Headers** : `X-Frame-Options`, `X-Content-Type-Options`.

---

## Rapport d'Audit Automatisé (Trivy)

Ce rapport est généré à chaque déploiement. Il analyse la conformité du code Terraform et Ansible.

!!! info "Lecture du rapport"
    Les vulnérabilités sont classées par sévérité.
    Certaines alertes peuvent être marquées comme ignorées si des mesures compensatoires sont en place.



## Analyse des Risques & Justifications

Le scan Trivy remonte actuellement **3 vulnérabilités CRITIQUES**. Voici l'analyse détaillée et pourquoi ces risques sont acceptés (Risk Acceptance).

### 1. Ouverture du Port HTTP (80)
**Code Erreur :** `AVD-AZU-0047`
> *Security group rule allows unrestricted ingress from any IP address.*

* **Le problème théorique :** Le port 80 est ouvert à tout internet (`0.0.0.0/0`).
* **Justification :** C'est le comportement attendu pour un **Serveur Web Public**. Le site doit être accessible par les visiteurs.
* **Mesure Compensatoire :** Le serveur est protégé par **ModSecurity (WAF)** et des en-têtes HTTP stricts pour limiter les attaques applicatives.

### 2. Ouverture du Port SSH (2222)
**Code Erreur :** `AVD-AZU-0050`
> *Security group should not allow unrestricted ingress to SSH port from any IP address.*

* **Le problème théorique :** Le port d'administration est ouvert à tout internet. Idéalement, il ne devrait être ouvert qu'à l'IP VPN de l'entreprise.
* **Contrainte Technique :** Le déploiement s'effectue via GitHub Actions et l'administration se fait depuis des IP dynamiques. Le whitelist d'IP est impossible dans ce contexte.
* **Mesures Compensatoires (Défense en Profondeur) :**
    1.  **Port Non-Standard :** Le port a été déplacé sur `2222` (Security by Obscurity).
    2.  **Authentification Forte :** Mots de passe désactivés (`PasswordAuthentication no`), seules les **Clés SSH** sont autorisées.
    3.  **Protection Active :** **Fail2Ban** est configuré pour bannir définitivement toute IP effectuant plus de 3 tentatives échouées.
# Conclusion de l'Audit

Bien que des ports soient ouverts au public ("0.0.0.0/0"), le risque est **maîtrisé** par l'utilisation de clés cryptographiques et d'un IPS (Intrusion Prevention System) local.

<iframe src="../report.html" width="100%" height="800px" style="border: 1px solid #ddd; border-radius: 4px;"></iframe>