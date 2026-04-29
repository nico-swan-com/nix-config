{
  # This will configure systemd-tmpfiles to automatically clean up /tmp.
  # Files will be removed after 30 days of not being accessed.
  boot.tmp.cleanOnBoot = true;
  systemd.tmpfiles.rules = [
    "D /tmp 1777 root root 30d"
  ];
}
