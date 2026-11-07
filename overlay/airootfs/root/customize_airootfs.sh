#!/usr/bin/env bash
# ==============================================================================
# Twilight OS Live Environment Customizer
# Executed inside the chroot by mkarchiso
# ==============================================================================
set -e

# 1. Unlock root password for live environment
passwd -d root 2>/dev/null || true

# 2. Setup liveuser account with hardware & administrator groups
if ! id -u liveuser >/dev/null 2>&1; then
    groupadd -g 1000 liveuser 2>/dev/null || true
    useradd -m -u 1000 -g 1000 -s /bin/bash liveuser 2>/dev/null || true
fi

for grp in wheel audio video render storage optical input power network; do
    groupadd -r "$grp" 2>/dev/null || true
    usermod -aG "$grp" liveuser 2>/dev/null || true
done
passwd -d liveuser 2>/dev/null || true

# 3. Ensure liveuser home and desktop permissions
if [[ -d /home/liveuser ]]; then
    cp -r /etc/skel/. /home/liveuser/ 2>/dev/null || true
    chown -R 1000:1000 /home/liveuser
    chmod 750 /home/liveuser
    chmod +x /home/liveuser/Desktop/*.desktop 2>/dev/null || true
fi

# 4. Enable SDDM display manager & NetworkManager
systemctl enable sddm.service NetworkManager.service 2>/dev/null || true
systemctl set-default graphical.target 2>/dev/null || true

# 5. Run branding script
if [[ -x /usr/local/bin/apply-twilight-branding ]]; then
    /usr/local/bin/apply-twilight-branding
fi

# 6. Clean up caches and docs to reduce live SquashFS size
rm -rf /var/cache/pacman/pkg/* 2>/dev/null || true
rm -rf /usr/share/doc/* 2>/dev/null || true
rm -rf /usr/share/man/* 2>/dev/null || true
