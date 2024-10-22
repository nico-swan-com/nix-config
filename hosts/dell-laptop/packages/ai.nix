{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    open-interpreter
    ollama
    oterm

    vimPlugins.ollama-nvim
  ];
}
