{ pkgs ? import <nixpkgs> { } }:

pkgs.appimageTools.wrapType2 rec {
  pname = "grok-bot";
  version = "0.68.1";

  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/33103062f95061ccf9c81c5b365d37ab152c3b66/linux/x64/Grok_Bot_${version}.AppImage";
    sha256 = "0nxsxy65wsyazkpppz79y4h1637cjwlikimh6fhmgmfcxjncbrrg";
  };

  extraInstallCommands =
    let
      appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in
    ''
      install -m 444 -D ${appimageContents}/grok-bot.desktop $out/share/applications/grok-bot.desktop
      mkdir -p $out/share/icons
      cp -r ${appimageContents}/usr/share/icons/* $out/share/icons/
      substituteInPlace $out/share/applications/grok-bot.desktop \
        --replace-fail 'Exec=AppRun' "Exec=$out/bin/${pname}"
      ln -s $out/bin/${pname} $out/bin/grokbot
    '';

  meta = with pkgs.lib; {
    description = "Grok Bot desktop agent";
    homepage = "https://cursor.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
