{ lib, stdenv, fetchurl, unzip, ... }:

stdenv.mkDerivation rec {
  pname = "rustfs";
  version = "latest";

  src = fetchurl {
    url = "https://dl.rustfs.com/artifacts/rustfs/release/rustfs-linux-x86_64-musl-${version}.zip";
    sha256 = "sha256-87b8fa4e995803ce4daacad3b07d75829a2477d30e13d734dc4fee5b501ca8e8";
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
