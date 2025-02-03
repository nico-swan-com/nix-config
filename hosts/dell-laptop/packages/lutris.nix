{ pkgs, ... }: {
  hardware.graphics.enable32Bit = true;
  environment.systemPackages = with pkgs.unstable;
    [
      (lutris.override {
        #extraLibraries = pkgs:
        #  [
        #    # List library dependencies here
        #  ];
        extraPkgs = pkgs: [
          wineWowPackages.stable
          wineWowPackages.waylandFull
          #wineWowPackages.staging
          gamescope
          wine
          #(wine.override { wineBuild = "wine64"; })
          wine64
          winetricks
        ];
      })
    ];
}
