# ai-vault

A **Claude Code project template and global command library** for empirical finance research.

Each project is organized around one or more **tracks** — self-contained analytical sub-projects, each with its own code, data, and full LaTeX paper draft. The vault provides shared skills, agents, and an init flow that scaffolds projects and tracks.

- **Initialize a new project:** run `scripts/new-project.ps1` (Windows) or `scripts/new-project.sh` (Mac/Linux). This creates the shared (cross-track) folder structure and symlinks the vault's skills and agents.
- **Add a track:** run `scripts/new-track.ps1` (or `.sh`). Each track gets its own `code/`, `data/`, and `latex/`.
- **Full usage guide:** [VAULT_USAGE.md](VAULT_USAGE.md)
- **Project context template:** [CLAUDE.md](CLAUDE.md)

## Quick Start

```powershell
# Windows
.\scripts\new-project.ps1 -ProjectPath "C:\projects\my-paper"
.\scripts\new-track.ps1   -ProjectPath "C:\projects\my-paper" -TrackName "did"
```

```bash
# Mac / Linux
./scripts/new-project.sh ../my-paper
./scripts/new-track.sh   ../my-paper did
```

Then open the new project in Claude Code, fill in `CLAUDE.md`, edit `tracks/did-<month-year>/latex/main.tex`, and start coding.
