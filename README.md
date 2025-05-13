<a id="readme-top"></a>

<h3 align="center">💾 Obsidian Vault GitHub Sync (Windows)</h3>

<p align="center">
  Seamlessly sync your Obsidian notes to a private GitHub repository using a single PowerShell script.
  <br />
</p>

---

## 📑 Table of Contents

- [About the Project](#about-the-project)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Vault + GitHub Setup](#vault--github-setup)
  - [Automation Script](#automation-script)
- [Usage](#usage)
- [Contact](#contact)

---

## 🧠 About the Project

This PowerShell-based automation sets up your Obsidian vault to sync silently with a private GitHub repo every 15 minutes. It ensures:

- Automatic commit + push of your notes
- SSH key generation and registration
- No command prompt popups
- Runs entirely on Windows Task Scheduler

---

## ⚙️ Getting Started

### ✅ Prerequisites

- [Git for Windows](https://git-scm.com/download/win)
- Obsidian vault already created
- A GitHub account

---

### 🛠️ Vault + GitHub Setup

Open PowerShell **as administrator** in your Obsidian vault folder.

#### 🔐 Generate SSH key

```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted:
> `Enter file in which to save the key:`  
> ➜ Type: `D:\your_obsidian_vault\id_ed25519`

#### 🔑 Start SSH agent & add key

```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add D:\your_obsidian_vault\id_ed25519
```

#### 📋 Add key to GitHub

```powershell
Get-Content D:\your_obsidian_vault\id_ed25519.pub
```

Copy the full key → Go to GitHub → **Settings → SSH and GPG Keys → New SSH Key** → Paste and save.

Test the connection:

```powershell
ssh -T git@github.com
```

#### 📁 Create private GitHub repo

- Name it: `obsidian-sync`
- ✅ Mark it private
- ❌ Do not initialize with README or .gitignore

#### 💻 Initialize Git in your vault

```powershell
git init
git remote add origin git@github.com:yourusername/obsidian-sync.git
Set-Content .gitignore ".obsidian/cache/`n.obsidian/workspace`n.obsidian/plugins`nid_ed25519`nid_ed25519.pub`nscripts/"
git add .
git commit -m "Clean initial commit: safe sync setup"
git branch -M main
git push -f origin main
```

---

## 🤖 Automation Script

Run this one-time PowerShell script to fully automate silent syncing:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup_obsidian_sync.ps1 -VaultPath "D:\your_obsidian_vault" -PrivateKeyPath "D:\your_obsidian_vault\id_ed25519"
```

This will:
- Generate `sync_obsidian.ps1` and `load_ssh_key.ps1`
- Create two scheduled tasks:
  - SSH key loader at login
  - Auto-sync every 15 minutes (runs silently in the background)

---

## 🧪 Usage

Just update your notes in Obsidian — every 15 minutes the changes will be committed and pushed silently.

To test immediately:

```powershell
Start-ScheduledTask -TaskName "Obsidian_Auto_Sync"
```

You can verify pushes by checking your GitHub repository.

---

## 📬 Contact

Made with ❤️ by [Sneh Bavarva](https://snehbavarva.com)  
Feel free to fork, star, or suggest improvements!

<p align="right">(<a href="#readme-top">back to top</a>)</p>
