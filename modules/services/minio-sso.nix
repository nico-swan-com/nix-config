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
        description = "OpenID Connect client secret";
        example = "your-client-secret";
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
          "MINIO_IDENTITY_OPENID_CLIENT_SECRET=${cfg.openid.clientSecret}"
          "MINIO_IDENTITY_OPENID_SCOPES=${cfg.openid.scopes}"
          "MINIO_IDENTITY_OPENID_DISPLAY_NAME=${cfg.openid.displayName}"
          "MINIO_IDENTITY_OPENID_CLAIM_NAME=${cfg.openid.claimName}"
          "MINIO_IDENTITY_OPENID_REDIRECT_URI_DYNAMIC=${if cfg.openid.redirectUriDynamic then "on" else "off"}"
        ] ++ (optional (cfg.openid.redirectUri != null) "MINIO_IDENTITY_OPENID_REDIRECT_URI=${cfg.openid.redirectUri}");
        
        # Load additional environment file if provided
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };
    };
  };
}
