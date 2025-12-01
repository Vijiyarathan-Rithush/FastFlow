# FastFlow (ff)

FastFlow (`ff`) is a lightweight Git workflow helper written in Bash.

It adds safety and speed to your daily Git commands by:

- protecting the `main` branch by default  
- providing a safe `ff push` flow (interactive staging + commit + push)  
- adding shortcuts for common Git actions  
- keeping everything simple, transparent, and under your control  

FastFlow is built for developers who work in the terminal and want a faster, safer Git flow.
---

## **Features**

- **Main branch protection**  
  - Destructive actions (`push`, `undo`, `hard`) are blocked on `main` by default  
  - Can be explicitly overridden with `ff disable main`

- **Safe push workflow**  
  - `ff push "message"`  
  - Uses `git add -p` (interactive staging)  
  - Commits with your message  
  - Pushes to the current branch

- **Protected history operations**  
  - `ff undo` → soft resets last commit  
  - `ff hard` → hard resets last commit (with confirmation)

- **Safe branch switching**  
  - `ff switch <branch>`  
  - Prevents switching away from `main` if there are uncommitted changes while main protection is enabled

- **Simple config file**  
  - Uses `~/.ffconfig` to store `MAIN_PROTECTION`  
  - Created automatically on first run  
  - Persistent across sessions

- **Clean, readable Bash code**  
  - Structured helpers (`enforce_protection`, `safe_switch_check`)  
  - Easy to extend with new commands

---

## **Requirements**

- Git  
- Bash (Linux, macOS, WSL, or Git Bash on Windows)

---

## **Installation (manual)**

1. **Clone the repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/fastflow.git
   cd fastflow
   ```
2. **Make the script executable**
    ```bash
    chmod +x ff
    ```
3. **Move it into your `$HOME/bin`**
    ```bash
    mkdir -p "$HOME/bin"
    cp ff "$HOME/bin/ff"
    ```
4. **Add `$HOME/bin` to your PATH**
    Add this line to your ~/.bashrc
    ```bash
    export PATH="$HOME/bin:$PATH"
    ```
    Then reload your shell:
    ```bash
    source ~/.bashrc
    ```
5. **Test**
    ```bash
    ff status
    ```
> Later you can replace these steps with a `./setup.sh` script. For now, this is enough.
---
## **Usage**
### Protect / unprotect `main`
    ```bash 
    ff enable main # Disable protection (allow destructive actions on main)
    ff disable main # Enable protection (block destructive actions on main)
    ```
> By default, `MAIN_PROTECTION` is set to `1` (enabled) in `~/.ffconfig`.
---
## **Safe push**
    ```bash
    ff push "implement ticket API"
    ```
This will:
1. Run `git add -p` (interactive staging)
2. Create a commit with your message
3. Push to the **current** branch
If there are no changes, it prints an info message instead of creating an empty commit.
---
## **Pull with rebase**
    ```bash
    ff pull
    ```
Uses:
    ```bash
    git pull --rebase origin <current-branch>
    ```
Keeps history cleaner than merge-based pulls.
---
## **History helpers**
Soft undo (keeps changes in working directory):
    ```bash
    ff undo
    ```
Hard reset (DESTROYS last commit - with confirmation):
    ```bash
    ff undo
    ```
---
## **Branch helpers**
List local branches:
    ```bash
    ff branch
    ```
Switch branches safely:
    ```bash
    ff switch <branch-name>
    ```
If you are on `main` with protection enabled and have uncommitted changes, FastFlow will refuse to switch to prevent accidental loss.
---
## **Info helpers**
    ```bash
    ff status   # git status
    ff log      # git log --oneline
    ff reflog   # git reflog
    ```
---
## **Config**
FastFlow uses a simple config file:
    ```bash
    ~/.ffconfig
    ```
Content example:
    ```bash
    MAIN_PROTECTION=1
    ```
- `1` -> protection enabled (default)
- `0` -> protection disabled (`ff enable main` sets this)
You normally don't need to edit this file manually - use:
    ```bash
    ff enable main
    ff disable main
    ```
---
## **License**
MIT License.
You are free to use, modify, and share this tool.
---
## **Author**
Vijiyarathan Rithush
Backend-focused developer and Linux enjoyer.
---
## **Contributions**
This project started as a personal workflow tool.
If you want to extend it or adapt it, feel free to fork an customize it.