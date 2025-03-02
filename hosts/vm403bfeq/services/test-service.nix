{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "500m";

    virtualHosts = {
      "test.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        # enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:8080";
            extraConfig = ''
              auth_request /auth;
              auth_request_set $auth_status $upstream_status;
              set $auth_token "";  # Initialize the variable
              if ($cookie_auth_token) {
                set $auth_token $cookie_auth_token;
              }
              proxy_set_header Authorization "Bearer $auth_token";
              error_page 401 = @handle_unauthorized;
            '';
          };
          "/auth" = {
            proxyPass =
              "http://127.0.0.1:38080/realms/production/protocol/openid-connect/userinfo";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";
              proxy_set_header X-Original-URI $request_uri;
            '';
          };

          "@handle_unauthorized" = {
            extraConfig = ''
              return 302 https://keycloak.cygnus-labs.com/realms/production/protocol/openid-connect/auth?client_id=penpot&redirect_uri=$scheme://$http_host$request_uri&response_type=code&scope=openid;
            '';
          };
        };
      };
    };
  };

  virtualisation.oci-containers.containers = {
    helloworld = {
      image = "testcontainers/helloworld:latest";
      ports = [ "8080:8080" "8081:8081" ];
    };
  };
}
