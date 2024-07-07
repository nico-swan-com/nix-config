{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    termscp
  ];
}
