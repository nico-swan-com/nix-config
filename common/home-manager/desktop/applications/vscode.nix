{ pkgs, ... }:
let
  vscode-conventional-commits = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-conventional-commits";
    publisher = "vivaxy";
    version = "1.25.0";
    sha256 = "KPP1suR16rIJkwj8Gomqa2ExaFunuG42fp14lBAZuwI=";
  };
in
{

  programs.vscode = {
    enable = true;
    extensions = [
      vscode-conventional-commits
    ] ++ (with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      #vscodevim.vim
      yzhang.markdown-all-in-one
      aaron-bond.better-comments
      eamodio.gitlens
      mhutchie.git-graph
      ms-azuretools.vscode-docker
      jnoortheen.nix-ide
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers
    ]);
  };

}
