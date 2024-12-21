{ pkgs, ... }: {
  services.mongodb.enable = true;
  services.mongodb.package = pkgs.mongodb-ce;
}
