{ stdenv, lib, fetchFromGitHub, nginx, openresty, redis }:

stdenv.mkDerivation rec {
  pname = "ceryx";
  version = "latest";

  src = fetchFromGitHub {
    owner = "withlogicco";
    repo = "ceryx";
    rev = "main";
    #sha256 = lib.fakeSha256;
    sha256 = "sha256-woSkN3jS+Szckc7WEgfEtGLKyzSaiVo8nP1bFeIHKNc=";
  };


  installPhase = ''
     mkdir -p $out
     cp -R $src/* $out
  '';

  meta = with lib; {
    description = "Dynamic reverse proxy based on NGINX and OpenResty with an API";
    homepage = "https://github.com/withlogicco/ceryx";
    license = licenses.mit;
    maintainers = with maintainers; [ "nico-swan-com" ];
    platforms = platforms.unix;
  };
}
