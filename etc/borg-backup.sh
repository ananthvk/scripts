#!/bin/sh

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=/mnt/backup/BorgBackups/

# See the section "Passphrase notes" for more infos.
# export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"
echo "Starting backup on $(date)" | systemd-cat -t borg-backup

# Backup the most important directories into an archive named after
# the machine this script is currently running on:
# --list
# --filter AME                    \

borg create                         \
    --verbose                       \
    --progress                      \
    --stats                         \
    --show-rc                       \
    --compression auto,zstd         \
    --exclude-caches                \
    --exclude '/home/shank/.cache/*'            \
    --exclude '/home/shank/var/tmp/*'           \
    --exclude '/home/shank/.config/Code/Cache'  \
    --exclude '/home/shank/.config/BraveSoftware/Brave-Browser-backup-crashrecovery*'  \
    --exclude '/home/shank/Downloads/Telegram Desktop/*'         \
    --exclude '/home/shank/Downloads/LOTM/*'         \
    --exclude '/home/shank/.ghcup/*'            \
    --exclude '/home/shank/.wine/*'             \
    --exclude '/home/shank/VM/*'             \
    --exclude '/home/shank/.ollama/*'             \
    --exclude '/home/shank/code/learn-llm/*'             \
    --exclude '/home/shank/code/bmsce/madpro/*'             \
    --exclude '/home/shank/code/bmsce/mlg/*'             \
    --exclude '/home/shank/code/bmsce/devops/*'             \
    --exclude '/home/shank/code/bmsce/usp/*'             \
    --exclude '/home/shank/clone/__malwares/*' \
    --exclude '/home/shank/Shankar/videos/*'    \
    --exclude '/home/shank/Shankar/isos/*'    \
    --exclude '/home/shank/code/lfs/*'    \
    --exclude '/home/shank/code/RVC/*'    \
    --exclude '/home/shank/Shankar/wallpapers/*'  \
    --exclude '/home/shank/.local/share/nomic.ai/*'  \
    --exclude '/var/lib/docker/*'  \
    --exclude '*.iso'               \
    ::'{hostname}-{now}'            \
    /etc                            \
    /home/shank                     \
    /root                           \
    /var                            \
    /usr/share/plasma               \
    /usr/share/wallpapers           \
    /usr/share/fonts                \
    /usr/share/nvim                 

backup_exit=$?

info "Pruning repository"
echo "Pruning repository" | systemd-cat -t borg-backup

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-*' matching is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    --glob-archives '{hostname}-*'  \
    --show-rc                       \
    --keep-daily    3               \
    --keep-weekly   4               \
    --keep-monthly  6

prune_exit=$?

# actually free repo disk space by compacting segments

info "Compacting repository"
echo "Compacting repository" | systemd-cat -t borg-backup

borg compact

compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and Compact finished successfully"
    echo "Backup, Prune, and Compact finished successfully" | systemd-cat -t borg-backup
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or Compact finished with warnings"
    echo "Backup, Prune, and/or Compact finished with warnings" | systemd-cat -t borg-backup
else
    info "Backup, Prune, and/or Compact finished with errors"
    echo "Backup, Prune, and/or Compact finished with errors" | systemd-cat -t borg-backup
fi

info "Checking consistency"
echo "Checking consistency" | systemd-cat -t borg-backup
borg check --progress
info "Finished checking consistency"
echo "Finished checking consistency" | systemd-cat -t borg-backup

exit ${global_exit}
