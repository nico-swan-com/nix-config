{ lib, stdenv, fetchFromGitHub, fetchYarnDeps, yarnConfigHook, yarnBuildHook
, yarnInstallHook, nodejs, }:

stdenv.mkDerivation (finalAttrs: {

  pname = "ghost-cli";
  version = "1.26.1";

  src = fetchFromGitHub {
    owner = "TryGhost";
    repo = "Ghost-CLI";
    rev = "master";
    sha256 = "trDjkxUbqfAkNKxPjAsAKofObnrzYBsnv2Ke29KM168=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-7ehM28xDqK5KDNFmZYwseBabTOdVWgAc6G9DPNLMiQg=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  meta = with lib; {
    description = "Ghost CLI Tool";
    homepage = "https://github.com/TryGhost/Ghost-CLI";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };

})
