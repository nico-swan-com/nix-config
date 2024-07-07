{ config, ... }:
let
   accessTokenPath = "${config.sops.secrets."work/git-lab/access-token".path}";
in
{
  programs.zsh = {
    initExtra = ''
      if [ -f ${accessTokenPath} ] ; then
        export CI_JOB_TOKEN=$(cat ${accessTokenPath})
        export NPM_TOKEN=$(cat ${accessTokenPath})
      fi
    '';
  };

  home.file.".npmrc".text = ''
    @bcb-projects:registry=https://gitlab.com/api/v4/packages/npm/
    // gitlab.com/api/v4/packages/npm/:_authToken=$CI_JOB_TOKEN
    // gitlab.com/:_authToken=$CI_JOB_TOKEN
  '';
}
