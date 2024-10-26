{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.bcb.per-branch;
  # nix-prefetch-git git@gitlab.com:bcb-projects/bcb-services.git --quiet --rev refs/heads/feature/TECH-12567-TARGET2-PaymentRail | jq -r '.sha256'
  gitRepo = builtins.fetchGit {
    url = "git@gitlab.com:bcb-projects/${cfg.name}.git";
    ref = cfg.branch;
  };
  
in
{
  options.services.bcb.per-branch = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the local admin api service.";
    };

    name = mkOption {
      type = types.str;
      default = "bcb-services";
      description = "Service project name.";
    };

    branch = mkOption {
      type = types.str;
      default = "main";
      description = "The branch name of the Node.js application repository.";
    };
  };

  config = mkIf cfg.enable {

     

    home.activation.fetchGitProject = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH=/Users/Nico.Swan/.nvm/versions/node/v20.13.0/bin:/nix/store/glhrv5jqmmsa4933zppz22fgyvn71mjx-google-cloud-sdk-475.0.0/google-cloud-sdk/bin:/opt/local/bin:/opt/local/sbin:/Library/Frameworks/Python.framework/Versions/3.11/bin:/Library/Frameworks/Python.framework/Versions/3.12/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/Nico.Swan/.nix-profile/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
      #mkdir -p /Users/Nico.Swan/bcb/per-branch/${cfg.branch}/${cfg.name}
      #echo "Fetching Git project..."
      #export GIT_SSH_COMMAND="/usr/bin/ssh"
      #${pkgs.git}/bin/git clone --branch ${cfg.branch} --single-branch git@gitlab.com:bcb-projects/${cfg.name}.git /Users/Nico.Swan/bcb/per-branch/${cfg.branch}/${cfg.name}
      #echo "Build Admin-api"
      cd /Users/Nico.Swan/bcb/per-branch/${cfg.branch}/${cfg.name}
      ${pkgs.nodejs_20}/bin/npm ci
      ${pkgs.nodejs_20}/bin/npm build
      ${pkgs.sqlite}/bin/sqlite3 /Users/Nico.Swan/bcb/per-branch/services.db "CREATE TABLE IF NOT EXISTS services (name TEXT PRIMARY KEY, branch TEXT);"
      ${pkgs.sqlite}/bin/sqlite3 /Users/Nico.Swan/bcb/per-branch/services.db "INSERT OR REPLACE INTO services (name, branch) VALUES (${cfg.name}, ${cfg.branch});"


    '';
    
  };
}
