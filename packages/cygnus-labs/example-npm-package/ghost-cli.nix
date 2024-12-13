{ lib, buildNpmPackage, fetchFromGitHub, nodejs, yarn2nix }:

buildNpmPackage rec {
  pname = "ghost-cli";
  version = "1.26.1";

  src = fetchFromGitHub {
    owner = "TryGhost";
    repo = "Ghost-CLI";
    rev = "master";
    sha256 = "trDjkxUbqfAkNKxPjAsAKofObnrzYBsnv2Ke29KM168=";
  };

  npmDepsHash = "sha256-VYuDpn/oeYDhCC8dfhJ/L9oTuvRO/KSZsGeS/rjt3Qg=";

  buildInputs = [ yarn2nix ];

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  preBuild = ''
    yarn2nix --lockfile=yarn.lock > yarn.nix
  '';

  buildPhase = ''
    yarn install --frozen-lockfile
  '';

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';

  meta = with lib; {
    description = "Ghost CLI Tool";
    homepage = "https://github.com/TryGhost/Ghost-CLI";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}

