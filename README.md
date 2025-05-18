# sysops-scripts
Misc. utility scripts and cronjobs I use throughout my infrastructure.

- `bin`: frequently used scripts, added to the system PATH
- `cron`: scripts that run as cron jobs. Con jobs run as Systemd timers [managed by nix](https://github.com/0xConnorRhodes/nix-forge/tree/main/modules/nixos).
- `bootstrap`: personal machine bootstrap scripts, can be run with `curl https://bootstrap.connor.engineer/script-name | bash`
- `lib`: re-usable modules imported into other scripts
- `phone`: scripts run on my phone using [Termux](https://termux.dev/en/).
- `pkm`: scripts used for personal knowledge management and general productivity workflows (task management, scheduling, note-taking, etc.)
- `priv`: submodule with private scrypts
- `work`: submodule with work scrypts
