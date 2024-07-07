{ inputs, username, fullName, email, ... }:
{
  # User
  username = username;
  fullName = fullName;
  email = email;

  # System
  editor = "vi"; # Default editor;
  locale = "en_ZA.UTF-8";
  timezone = "Africa/Johannesburg";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  stateVersion = "24.05"; # DO NOT CHANGE
}
