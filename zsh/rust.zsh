# rust.zsh — put cargo/rustup tools on PATH when the toolchain is installed.
# No-op on machines without Rust. rustup was installed with --no-modify-path so
# this fragment is the single place that wires it into the shell.
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
