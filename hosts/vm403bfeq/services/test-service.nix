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
              auth_request /auth-keycloak;
              auth_request_set $auth_status $upstream_status;
              error_page 401 = @handle_unauthorized;
            '';
          };
          "/auth-keycloak" = {
            proxyPass =
              "https://keycloak.cygnus-labs.com/realms/production/protocol/openid-connect/token/introspect";
            extraConfig = ''
              internal;
              proxy_ssl_server_name on;
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";
              proxy_set_header X-Original-URI $request_uri;
              proxy_set_header Authorization "Bearer $http_authorization";
              proxy_set_header X-Client-IP $remote_addr;
              proxy_set_header X-Client-Proto $scheme;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
          "@handle_unauthorized" = {
            return = 302;
            extraConfig = ''
              return 302 https://keycloak.cygnus-labs.com/realms/production/protocol/openid-connect/auth?client_id=your_client_id&redirect_uri=$scheme://$http_host$request_uri&response_type=code&scope=openid;
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
