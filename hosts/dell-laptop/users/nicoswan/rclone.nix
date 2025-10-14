{ pkgs, ... }: {

  # Install rclone and GUI tools
  home.packages = [ 
    pkgs.rclone 
    pkgs.gnome-shell-extensions
    pkgs.libnotify  # For desktop notifications
  ];

  # Enable GNOME Shell extensions for rclone management
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "rclone-manager@aunetx"  # Install via: gnome-extensions install rclone-manager@aunetx
      ];
    };
  };

  # Create mount directories and scripts
  home.file.".config/rclone-mount-pretoria.sh" = {
    text = ''
      #!/usr/bin/env bash
      mkdir -p /home/nicoswan/mnt/wetink/pretoria-files
      ${pkgs.rclone}/bin/rclone --config=~/.config/rclone/rclone.conf --vfs-cache-mode writes --ignore-checksum mount "s3-wetink:pretoria-files" "/home/nicoswan/mnt/wetink/pretoria-files" &
      echo $! > /tmp/rclone-pretoria.pid
      notify-send "RClone" "Pretoria files mounted at /home/nicoswan/mnt/wetink/pretoria-files"
    '';
    executable = true;
  };

  home.file.".config/rclone-mount-captown.sh" = {
    text = ''
      #!/usr/bin/env bash
      mkdir -p /home/nicoswan/mnt/wetink/captown-files
      ${pkgs.rclone}/bin/rclone --config=~/.config/rclone/rclone.conf --vfs-cache-mode writes --ignore-checksum mount "s3-wetink:capetown-files" "/home/nicoswan/mnt/wetink/captown-files" &
      echo $! > /tmp/rclone-captown.pid
      notify-send "RClone" "Capetown files mounted at /home/nicoswan/mnt/wetink/captown-files"
    '';
    executable = true;
  };

  home.file.".config/rclone-umount-pretoria.sh" = {
    text = ''
      #!/usr/bin/env bash
      if [ -f /tmp/rclone-pretoria.pid ]; then
        kill $(cat /tmp/rclone-pretoria.pid) 2>/dev/null || true
        rm -f /tmp/rclone-pretoria.pid
      fi
      /run/wrappers/bin/fusermount -u /home/nicoswan/mnt/wetink/pretoria-files 2>/dev/null || true
      notify-send "RClone" "Pretoria files unmounted"
    '';
    executable = true;
  };

  home.file.".config/rclone-umount-captown.sh" = {
    text = ''
      #!/usr/bin/env bash
      if [ -f /tmp/rclone-captown.pid ]; then
        kill $(cat /tmp/rclone-captown.pid) 2>/dev/null || true
        rm -f /tmp/rclone-captown.pid
      fi
      /run/wrappers/bin/fusermount -u /home/nicoswan/mnt/wetink/captown-files 2>/dev/null || true
      notify-send "RClone" "Capetown files unmounted"
    '';
    executable = true;
  };

  # Nautilus scripts for right-click integration
  home.file.".local/share/nautilus/scripts/Upload to Pretoria Files" = {
    text = ''
      #!/usr/bin/env bash
      for FILE in "$@"; do
        ${pkgs.rclone}/bin/rclone copy "$FILE" "s3-wetink:pretoria-files/$(basename "$FILE")"
        notify-send "Upload Complete" "Uploaded $(basename "$FILE") to Pretoria Files"
      done
    '';
    executable = true;
  };

  home.file.".local/share/nautilus/scripts/Upload to Capetown Files" = {
    text = ''
      #!/usr/bin/env bash
      for FILE in "$@"; do
        ${pkgs.rclone}/bin/rclone copy "$FILE" "s3-wetink:capetown-files/$(basename "$FILE")"
        notify-send "Upload Complete" "Uploaded $(basename "$FILE") to Capetown Files"
      done
    '';
    executable = true;
  };

  # Desktop shortcuts for easy access
  home.file.".local/share/applications/rclone-pretoria.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Mount Pretoria Files
      Comment=Mount S3 Wetink Pretoria Files
      Exec=${pkgs.gnome-terminal}/bin/gnome-terminal -- /home/nicoswan/.config/rclone-mount-pretoria.sh
      Icon=folder-remote
      Terminal=false
      Categories=System;FileManager;
    '';
  };

  home.file.".local/share/applications/rclone-captown.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Mount Capetown Files
      Comment=Mount S3 Wetink Capetown Files
      Exec=${pkgs.gnome-terminal}/bin/gnome-terminal -- /home/nicoswan/.config/rclone-mount-captown.sh
      Icon=folder-remote
      Terminal=false
      Categories=System;FileManager;
    '';
  };

  # Add shell aliases for easy mounting/unmounting
  programs.zsh.shellAliases = {
    "mount-pretoria" = "~/.config/rclone-mount-pretoria.sh";
    "mount-captown" = "~/.config/rclone-mount-captown.sh";
    "umount-pretoria" = "~/.config/rclone-umount-pretoria.sh";
    "umount-captown" = "~/.config/rclone-umount-captown.sh";
  };

}
