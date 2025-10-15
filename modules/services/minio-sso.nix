{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.minio-sso;
  minioConfig = config.services.minio;
in
{
  options.services.minio-sso = {
    enable = mkEnableOption "MinIO with OpenID Connect SSO support";
    
    # OpenID Connect configuration
    openid = {
      configUrl = mkOption {
        type = types.str;
        description = "OpenID Connect configuration URL";
        example = "https://keycloak.example.com/realms/production/.well-known/openid-configuration";
      };
      
      clientId = mkOption {
        type = types.str;
        description = "OpenID Connect client ID";
        example = "minio-client";
      };
      
      clientSecret = mkOption {
        type = types.str;
        default = "";
        description = "OpenID Connect client secret (deprecated - use clientSecretFile instead)";
        example = "your-client-secret";
      };
      
      clientSecretFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "File containing the OpenID Connect client secret";
        example = "/run/secrets/minio-openid-secret";
      };
      
      scopes = mkOption {
        type = types.str;
        default = "openid,profile,email";
        description = "OpenID Connect scopes";
      };
      
      displayName = mkOption {
        type = types.str;
        default = "SSO Login";
        description = "Display name for the SSO provider";
      };
      
      claimName = mkOption {
        type = types.str;
        default = "preferred_username";
        description = "Claim name for user identification";
      };
      
      rolePolicy = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Default policy to assign to all OpenID Connect users";
        example = "readwrite";
      };
      
      redirectUri = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Redirect URI for OAuth callback";
      };
      
      redirectUriDynamic = mkOption {
        type = types.bool;
        default = true;
        description = "Enable dynamic redirect URI generation";
      };
    };
    
    # Environment file containing secrets
    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Environment file containing OpenID Connect secrets";
    };
  };

  config = mkIf cfg.enable {
    # Ensure the base MinIO service is enabled
    services.minio.enable = true;
    
    # Create environment file with OpenID Connect variables
    systemd.services.minio = {
      # Override the base MinIO service
      serviceConfig = {
        # Add OpenID Connect environment variables
        Environment = [
          "MINIO_IDENTITY_OPENID_CONFIG_URL=${cfg.openid.configUrl}"
          "MINIO_IDENTITY_OPENID_CLIENT_ID=${cfg.openid.clientId}"
          "MINIO_IDENTITY_OPENID_SCOPES=${cfg.openid.scopes}"
          "MINIO_IDENTITY_OPENID_DISPLAY_NAME=${cfg.openid.displayName}"
          "MINIO_IDENTITY_OPENID_CLAIM_NAME=${cfg.openid.claimName}"
          "MINIO_IDENTITY_OPENID_REDIRECT_URI_DYNAMIC=${if cfg.openid.redirectUriDynamic then "on" else "off"}"
        ] ++ (optional (cfg.openid.redirectUri != null) "MINIO_IDENTITY_OPENID_REDIRECT_URI=${cfg.openid.redirectUri}")
          ++ (optional (cfg.openid.clientSecret != "") "MINIO_IDENTITY_OPENID_CLIENT_SECRET=${cfg.openid.clientSecret}")
          ++ (optional (cfg.openid.rolePolicy != null) "MINIO_IDENTITY_OPENID_ROLE_POLICY=${cfg.openid.rolePolicy}");
        
        # Load environment files
        EnvironmentFile = let
          envFiles = (optional (cfg.environmentFile != null) cfg.environmentFile)
                   ++ (optional (cfg.openid.clientSecretFile != null) cfg.openid.clientSecretFile);
        in if envFiles != [] then envFiles else null;
      };
    };
  };
}
