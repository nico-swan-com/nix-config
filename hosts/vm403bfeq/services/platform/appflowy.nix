{ lib, rustPlatform, fetchFromGitHub, pkg-config, protobuf, openssl, sqlite
, zstd, }:
rustPlatform.buildRustPackage rec {
  pname = "appflowy-cloud";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "AppFlowy-IO";
    repo = "AppFlowy-Cloud";
    rev = version;
    hash = "sha256-bFonlXrd7MFSYEtGsDoO307KSDntiB2vQcdKC68hvcc=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "collab-0.2.0" = "sha256-3Y2UrAga7wiV5RF+Lj0PkWA6gsa2h/PkRVUnjbrepqc=";
    };
  };

  nativeBuildInputs = [ pkg-config protobuf ];

  buildInputs = [ openssl sqlite zstd ];
}
