{ lib, stdenv, fetchzip, autoPatchelfHook, ... }:

let
  # Determine the architecture and libc variant (robust across platforms)
  isx86_64 = stdenv.hostPlatform.isx86_64 or false;
  isAarch64 = stdenv.hostPlatform.isAarch64 or false;
  isMusl = stdenv.hostPlatform.isMusl or false;

  # Map Nix architectures to RustFS architectures
  rustfsArch = if isx86_64 then "x86_64"
               else if isAarch64 then "aarch64"
               else throw "Unsupported architecture: ${stdenv.hostPlatform.system}";

  # Choose between GNU and MUSL builds
  libcVariant = if isMusl then "musl" else "gnu";

  version = "1.0.0-alpha.65";
  
  # Construct the download URL based on architecture and libc
  downloadUrl = "https://dl.rustfs.com/artifacts/rustfs/release/rustfs-linux-${rustfsArch}-${libcVariant}-${version}.zip";
  
in stdenv.mkDerivation rec {
  pname = "rustfs";
   # Using latest since the install script doesn't specify a version
  inherit version;


  
  src = fetchzip {
    url = downloadUrl;
    sha256 = if rustfsArch == "x86_64" && libcVariant == "musl" then
      "sha256-87b8fa4e995803ce4daacad3b07d75829a2477d30e13d734dc4fee5b501ca8e8"
    else if rustfsArch == "x86_64" && libcVariant == "gnu" then
      "sha256-2cef83a7cf811ec724f5d0ab3d8a0d17b3b9ef533d109ce4daf082ab0265b43b"
    else if rustfsArch == "aarch64" && libcVariant == "musl" then
      "sha256-8329e2f996a3df057dbd75e10cd2d5f709fe8b1b443fb03d5b2d60d4b7d544a3"
    else if rustfsArch == "aarch64" && libcVariant == "gnu" then
      "sha256-b9003b308c97f0ecb32be6e9bad4c10383e6cc54698598f69e31339c0f0607bb"
    else
      throw "Unsupported combination: ${rustfsArch}-${libcVariant}";
  };
  
  nativeBuildInputs = [ autoPatchelfHook ];
  
  buildInputs = [ ];
  
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m0755 rustfs "$out/bin/rustfs"

    runHook postInstall
  '';
  
  meta = with lib; {
    description = "RustFS - High-performance distributed object storage system with S3-compatible API";
    homepage = "https://rustfs.com/";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "rustfs";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    
    longDescription = ''
      RustFS is a high-performance distributed object storage system with S3-compatible API.
      It is a fully open-source project and is licensed under the Apache License 2.0.
    '';
  };
}
