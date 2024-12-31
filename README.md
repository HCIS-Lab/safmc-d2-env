# SAFMC D2 Development Environment

## For Linux Users

1. Copy the Linux configuration file:

```sh
cp .devcontainer/devcontainer.json.linux .devcontainer/devcontainer.json
mkdir -p workspace
```

2. Open the project in Visual Studio Code, then press `Ctrl + Shift + P` and choose `Dev Containers: Reopen in Container`.

## For Windows Users

1. Copy the Windows configuration file:

```powershell
Copy-Item .devcontainer/devcontainer.json.windows .devcontainer/devcontainer.json
New-Item -ItemType Directory -Path .\workspace
```

2. Open the project in Visual Studio Code, then press `Ctrl + Shift + P` and choose `Dev Containers: Reopen in Container`.

### Resolving Windows X11 Issues

If you encounter Windows X11 display issues, please refer to the following link for a solution: [Windows x11 解決方法](https://www.notion.so/Windows-c75f78f20fb449709ccd8c13302304b4?pvs=4)
