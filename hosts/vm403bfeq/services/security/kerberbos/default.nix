{ config, pkgs, ... }: {

  sops = { secrets = { "servers/cygnus-labs/kerberbos/masterKey" = { }; }; };

  systemd.services.kerberos-initialze-realm = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.krb5}/bin/kdb5_util create -s -r cygnus-labs.com -P $(cat ${
        config.sops.secrets."servers/cygnus-labs/kerberbos/masterKey".path
      })
      systemctl restart kadmind.service kdc.service
    '';
  };

  security.krb5 = {
    # Here you can choose between the MIT and Heimdal implementations.
    package = pkgs.krb5;
    # package = pkgs.heimdal;

    # Optionally set up a client on the same machine as the server
    enable = true;
    settings = {
      libdefaults.default_realm = "cygnus-labs.com";
      realms."cygnus-labs.com" = {
        kdc = "kerberos.security.cygnus-labs.com";
        admin_server = "kerberos.security.cygnus-labs.com";
      };
    };
  };

  services.kerberos_server = {
    enable = true;
    settings = {
      realms."cygnus-labs.com" = {
        acl = [{
          access = "all";
          principal = "admin/admin";
        }];
      };
    };
  };
}
