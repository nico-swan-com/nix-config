{ pkgs, config, ... }:

let
  commonExtraConfig = ''
    # Allow special characters in headers
    ignore_invalid_headers off;

    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;

    # Disable buffering
    proxy_buffering off;
    proxy_request_buffering off;
  '';
in {
  sops = {
    secrets = { "servers/cygnus-labs/minio/rootCredentialsFiles" = { }; };
  };

  services.nginx = {
    virtualHosts = {
      "s3.cygnus-labs.com" = {
        forceSSL = false;
        enableACME = false;

        extraConfig = commonExtraConfig + ''
          add_header Content-Security-Policy "default-src 'self' 'unsafe-eval' 'unsafe-inline'; font-src 'self' data:;";
        '';

        locations."/" = {
          proxyPass = "http://localhost:9000";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_connect_timeout 300;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            chunked_transfer_encoding off;
          '';
        };
      };

      "minio-console.platform.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;

        extraConfig = commonExtraConfig + ''
          add_header Content-Security-Policy "default-src 'self' 'unsafe-eval' 'unsafe-inline'; font-src 'self' data:;";
        '';

        locations."/" = {
          proxyPass = "http://localhost:9001";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_set_header X-NginX-Proxy true;
            real_ip_header X-Real-IP;
            proxy_connect_timeout 300;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            chunked_transfer_encoding off;
          '';
        };
      };
    };
  };

  # S3 compatible storage service
  services.minio = {
    enable = true;
    package = pkgs.unstable.minio;
    region = "af-south-1";
    rootCredentialsFile =
      config.sops.secrets."servers/cygnus-labs/minio/rootCredentialsFiles".path;
  };

}
