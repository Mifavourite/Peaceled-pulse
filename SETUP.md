# Setup Instructions

## Windows Setup

Since you're on Windows, some shell scripts may need to be run in Git Bash or WSL.

### Option 1: Using Git Bash

1. Open Git Bash
2. Navigate to the project directory
3. Run the setup scripts:
```bash
./install.sh
./secure-setup.sh --audit-mode
```

### Option 2: Using WSL (Windows Subsystem for Linux)

1. Open WSL terminal
2. Navigate to the project directory (usually in `/mnt/c/Users/tobel/Desktop/secure_flutter_app`)
3. Run the setup scripts:
```bash
./install.sh
./secure-setup.sh --audit-mode
```

### Option 3: Manual Setup (Windows PowerShell)

1. Install Flutter dependencies:
```powershell
flutter pub get
```

2. Start Docker services:
```powershell
docker-compose up -d
```

3. Initialize Vault (in Git Bash or WSL):
```bash
make vault-init
make vault-unseal
```

## Making Scripts Executable (Linux/Mac/WSL)

If you need to make scripts executable:
```bash
chmod +x install.sh secure-setup.sh .githooks/pre-commit
```

## Running Security Commands

All Makefile commands work the same way:
```bash
make security-scan
make pentest
make audit
```

## Docker Services

Docker services should work the same on Windows:
```powershell
docker-compose up -d
docker-compose logs -f
docker-compose stop
```
