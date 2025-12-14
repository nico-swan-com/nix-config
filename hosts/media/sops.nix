# hosts level sops. see home/common/optional/sops.nix for home/user level
{ pkgs, inputs, config, cfg, ... }:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/secrets.yaml";
  homeDirectory = "/home/${cfg.username}";
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      "users/root/password".neededForUsers = true;
      "users/${cfg.username}/password".neededForUsers = true;
      "servers/home/cloudflare/envFile".neededForUsers = true;
    };
  };
  # The containing folders are created as root and if this is the first ~/.config/ entry,
  # the ownership is busted and home-manager can't target because it can't write into .config...
  # FIXME: We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
  system.activationScripts.sopsSetAgeKeyOwnwership = let
    ageFolder = "${homeDirectory}/.config/sops/age";
    user = config.users.users.${cfg.username}.name;
    group = config.users.users.${cfg.username}.group;
  in ''
    mkdir -p ${ageFolder} || true
    chown -R ${user}:${group} ${homeDirectory}/.config
  '';
}
