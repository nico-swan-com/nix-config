{
  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile ~/.ssh/nicoswan-nixbuild-key
  '';

  # programs.ssh.knownHosts = {
  #   nixbuild = {
  #     hostNames = [ "eu.nixbuild.net" ];
  #     publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJk4Z76vOcMbDY1vNll3bUo4WEnM20oiG4HkrIparJph nicoswan-nixbuild-key";
  #   };
  # };


}
