# About

A service that runs periodic backups

# What do I want from my backup system

- Run automatically at designated time intervals.

- Notify me at the end of the process with a report.

- Have the ability to backup data in a remote storage medium

  as well as a local one.

- Should ignore version controlled source trees.

# Crontab

## Installation

```sh

# On arch install cronie
sudo pacman -S cronie

# Start the service
sudo systemctl enable cronie
sudo systemctl start cronie

```

## Job scheduling

```sh

# Schedule the backup script to run
# At the 1st minute exactly 1 hour after midnight
crontab -e
01 1 * * * ~/bin/autobak

```


## Logs

logs at /var/local/cron/autobak.log

# Contact

- Pavlos Noulis

    pavlos.noulis@gmail.com

    [github](https://github.com/pnoulis)


- Project Link

    [autobak](https://github.com/pnoulis/autobak)
