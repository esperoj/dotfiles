# Install
```bash
cd ~
export ENCRYPTION_PASSPHRASE=""
export MACHINE_NAME=segfault
curl -fsLS https://codeberg.org/esperoj/dotfiles/raw/branch/main/bin/setup.sh | bash
"${HOME}/.local/bin/chezmoi" init --apply --force
. ~/.profile
rclone copy -v koofr:working working
```

# Cron schedule

- Everyday will run backup at 23:30.
- Every sunday will run benchmark at 00:30 and 01:30.

# Benchmark Results

|         Name           | Single-Core | Multi-Core | Download  |   Upload  |             Geekbench Link                   |                Network Benchmark           |
| ---------------------- | ----------- | ---------- | --------- | --------- | -------------------------------------------- | ------------------------------------------ |
| Amazon EC2 m7g.xlarge  |     1511    |    4901    | 8342 Mbps | 2546 Mbps | https://browser.geekbench.com/v6/cpu/2112138 | https://cdn1.frocdn.ch/CM8IjrsTp6tmf0f.txt |
| Azure Standard_DS2_v2  |     1078    |    1962    | 8465 Mbps | 1288 Mbps | https://browser.geekbench.com/v6/cpu/2112263 | https://cdn1.frocdn.ch/Nk0TPKgdkj4ysSZ.txt |
|         MyLoc          |     1210    |    3808    | 683 Mbps  | 726 Mbps  | https://browser.geekbench.com/v6/cpu/2369795 | https://cdn1.frocdn.ch/9qfLPC71wb1JQTU.txt |
