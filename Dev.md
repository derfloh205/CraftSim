# Developer setup

## Git hooks (submodules after pull)

This repository ships hooks under `.githooks` that run **`git submodule update --init --recursive`** after:

- **`post-merge`** — e.g. a normal `git pull` (merge)
- **`post-rebase`** — e.g. `git pull --rebase`

So when the parent repo moves to a commit that updates submodule pointers, your working tree’s submodules stay in sync automatically.

### One-time setup (each clone)

From the repository root:

```bash
git config core.hooksPath .githooks
```

That setting is **local to this clone** (stored in `.git/config`), so every machine and every new clone needs this command once.

Verify:

```bash
git config core.hooksPath
# should print: .githooks
```

### Requirements

- Git executes these hooks with **`sh`** (Git for Windows Bash, macOS, and Linux are fine).
- Hooks are marked executable in Git for Unix-like systems; on Windows, Git runs them via its bundled shell.

### First-time submodule checkout

If you cloned **without** `git clone --recurse-submodules`, run once:

```bash
git submodule update --init --recursive
```

After `core.hooksPath` is set, later **pulls** will keep submodules updated via the hooks.

### Optional: built-in pull behavior (no hooks)

To recurse into submodules on **`git pull`** without custom hooks (merge-style pull only; rebases differ), you can alternatively use:

```bash
git config pull.recurseSubmodules on
```

The `.githooks` setup is still recommended here because it also covers **rebase** flows.

---

## Symlink the addon into WoW (`Interface/AddOns`)

Point WoW’s **CraftSim** add-on folder at this repository so the game loads your working tree (no manual copying after edits).

1. Quit WoW.
2. In `…/World of Warcraft/_retail_/Interface/AddOns/` (or `_classic_` / `_classic_era_` if you develop there), remove or rename any existing **`CraftSim`** folder so it does not block the link.
3. Create a **directory symlink** from `AddOns/CraftSim` → your clone (commands below).

Replace the placeholder paths with your real WoW install and repo locations.

### Windows

**Directory symlinks** usually need either **Administrator** Command Prompt / PowerShell, or **Developer Mode** (Settings → System → **For developers** → **Developer Mode**), which allows creating symlinks without elevating every time.

**Command Prompt** (adjust paths; target is your repo root that contains `CraftSim.toc`):

```bat
mklink /D "C:\Path\To\WoW\_retail_\Interface\AddOns\CraftSim" "D:\Dev\CraftSim"
```

- `/D` creates a symbolic link to a directory.

**PowerShell** (same idea):

```powershell
New-Item -ItemType SymbolicLink `
  -Path "C:\Path\To\WoW\_retail_\Interface\AddOns\CraftSim" `
  -Target "D:\Dev\CraftSim"
```

If creation fails with “privilege” or “permission” errors, open the terminal **Run as administrator** or enable **Developer Mode**, then retry.

**Junction** (alternative, no symlink privilege): `mklink /J` only works well for **local** paths; it is not a true symlink but is often enough for “game AddOns → local disk repo”. Example:

```bat
mklink /J "C:\Path\To\WoW\_retail_\Interface\AddOns\CraftSim" "D:\Dev\CraftSim"
```

### Linux

Use a single symlink; `-f` replaces an existing link, `-n` treats a symlink to a directory correctly when replacing.

```bash
ln -sfn /path/to/your/CraftSim "/path/to/World of Warcraft/_retail_/Interface/AddOns/CraftSim"
```

Typical WoW paths depend on how you install (Wine, Lutris, Bottles, Steam): find the `_retail_` tree that contains `Interface/AddOns`, then run `ln -sfn` with that `AddOns` path.

Verify:

```bash
ls -la "/path/to/.../Interface/AddOns/CraftSim"
# should show CraftSim -> /path/to/your/CraftSim
```

Launch WoW and confirm **CraftSim** appears in the add-ons list.
