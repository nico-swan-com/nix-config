{ pkgs, ... }:
let
  efiUuid = "E4AA-3787";
  windowsUuid = "0A313D8E90543F1F";
in
{
  # Bootloader
  boot.plymouth.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];

  boot.loader = {
    timeout = 5;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    systemd-boot = {
      enable = false;
      configurationLimit = 1;
    };
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      configurationLimit = 3;
      copyKernels = false;
      fsIdentifier = "uuid";

      ## Restore Windows Boot Manager onto the shared ESP before GRUB scans
      # for other operating systems. os-prober only detects Windows when
      # /EFI/Microsoft/Boot/bootmgfw.efi exists.
      #extraPrepareConfig = ''
      #  if [ ! -e /boot/EFI/Microsoft/Boot/bootmgfw.efi ]; then
      #    mkdir -p /run/win-esp-restore
      #    if ${pkgs.util-linux}/bin/mount -t ntfs3 -o ro /dev/disk/by-uuid/${windowsUuid} /run/win-esp-restore 2>/dev/null \
      #      || ${pkgs.ntfs3g}/bin/ntfs-3g -o ro /dev/disk/by-uuid/${windowsUuid} /run/win-esp-restore 2>/dev/null; then
      #      if [ -f /run/win-esp-restore/Windows/Boot/EFI/bootmgfw.efi ]; then
      #        mkdir -p /boot/EFI/Microsoft/Boot
      #        cp -n /run/win-esp-restore/Windows/Boot/EFI/*.efi /boot/EFI/Microsoft/Boot/ || true
      #      fi
      #      ${pkgs.util-linux}/bin/umount /run/win-esp-restore || true
      #    fi
      #    rmdir /run/win-esp-restore 2>/dev/null || true
      #  fi
      #'';

      extraEntries = ''
        menuentry "Windows" --class windows --class os {
          insmod part_gpt
          insmod fat
          insmod chain
          insmod search_fs_uuid
          search --fs-uuid --set=root ${efiUuid}
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';

      theme = pkgs.stdenv.mkDerivation {
        pname = "distro-grub-themes";
        version = "3.1";
        src = pkgs.fetchFromGitHub {
          owner = "AdisonCavani";
          repo = "distro-grub-themes";
          rev = "v3.1";
          hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
        };
        installPhase = "cp -r customize/nixos $out";
      };
    };
  };

}
