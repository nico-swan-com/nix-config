{ pkgs, configVars, ... }:

{
  imports = [
    ../modules/colima.nix
  ];

  # services.colima = {
  #   enable = true;
  #   vms = [
  #     {
  #       cpu = 1;
  #       disk = 1;
  #       memory = 1;
  #       arch = "aarch64";
  #       runtime = "docker";
  #       hostname = "test";
  #       kubernetes = {
  #         enabled = true;
  #       };
  #       #autoActivate = true;
  #       network.address = true;
  #       # forwardAgent: false
  #       # docker: {}
  #       # vmType: qemu
  #       # rosetta: false
  #       # mountType: sshfs
  #       # mountInotify: false
  #       # cpuType: host
  #       # provision: []
  #       # sshConfig: true
  #       # mounts: []
  #       # env: {}
  #     }
  #   ];
  # };

}
