{ lib, stdenv, fetchurl, unzip, ... }:

let
  version = "latest";
  src = fetchurl {
    url = "https://dl.rustfs.com/artifacts/rustfs/release/rustfs-linux-x86_64-musl-${version}.zip";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # This will need to be updated
  };
in

stdenv.mkDerivation rec {
  pname = "rustfs";
  inherit version;

  src = fetchurl {
    url = "https://dl.rustfs.com/artifacts/rustfs/release/rustfs-linux-x86_64-musl-${version}.zip";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # This will need to be updated
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    cp rustfs $out/bin/
    chmod +x $out/bin/rustfs
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "RustFS - High-performance distributed object storage system with S3-compatible API";
    homepage = "https://rustfs.com/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
