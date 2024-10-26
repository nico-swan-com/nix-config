{
  description = "A flake for the Ceryx dynamic reverse proxy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin"; 
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = rec {
        ceryx = pkgs.stdenv.mkDerivation {
          pname = "ceryx";
          version = "latest";

          src = pkgs.fetchFromGitHub {
            owner = "withlogicco";
            repo = "ceryx";
            rev = "main";
            sha256 = pkgs.lib.fakeSha256;
          };

          buildInputs = [ pkgs.nginx pkgs.openresty pkgs.redis ];

          buildPhase = ''
            mkdir -p $out/bin
            cp -r * $out/bin
          '';

          installPhase = ''
            mkdir -p $out/etc/ceryx
            cp -r conf/* $out/etc/ceryx
          '';

          meta = with pkgs.lib; {
            description = "Dynamic reverse proxy based on NGINX and OpenResty with an API";
            homepage = "https://github.com/withlogicco/ceryx";
            license = licenses.mit;
            maintainers = with maintainers; [ "nico-swan-com" ];
            platforms = platforms.unix;
          };
        };
      };
    };
}
