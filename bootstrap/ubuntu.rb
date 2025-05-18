#!/usr/bin/env ruby

packages = %w[
  ruby
  python3
  python3-pip
  python3-jinja2
  magic-wormhole
  fish
  zoxide
  fd-find
  ripgrep
  fzf
  lf
]

`sudo apt-get update && sudo apt-get upgrade -y`
`sudo apt-get install -y #{packages.join(' ')}`

# `sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply 0xConnorRhodes`
# `~/.local/bin/chezmoi apply` # second run to decrypt secrets

unless File.exist?(File.expand_path("~/.ssh/id_ed25519"))
  `ssh-keygen -q -a 100 -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""`
end

# Create symlinks for fd and bat
`sudo ln -s $(which fdfind) /usr/local/bin/fd`
`sudo ln -s $(which batcat) /usr/local/bin/bat`
