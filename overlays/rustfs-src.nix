{ lib, stdenv, rustPlatform, fetchFromGitHub, pkg-config, openssl, ... }:

rustPlatform.buildRustPackage rec {
  pname = "rustfs";
  version = "1.0.0-alpha.65"; # Latest release version

  src = fetchFromGitHub {
    owner = "rustfs";
    repo = "rustfs";
    rev = "${version}"; # Use the git tag for the specific version
    sha256 = "sha256-/GNIA5NYmSifCtWx2oN3H7NrO2PkadUenkzlRyso9r8=";
  };

  cargoHash = "sha256-IQY4xT8g84/UNMobul/zmVlAVu3fEAau6RPH0IOvf6w="; 

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  # Set environment variables for the build
  OPENSSL_NO_VENDOR = 1;

  # Run tests
  doCheck = false; # Set to true if you want to run tests (may take longer)

  meta = with lib; {
    description = "RustFS - High-performance distributed object storage system with S3-compatible API";
    homepage = "https://github.com/rustfs/rustfs";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
