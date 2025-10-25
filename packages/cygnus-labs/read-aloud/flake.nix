{

  description = "read aloud - is a script that reads the clibboard and reads it aloud for the user.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";

    defaultVoice = {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/joe/medium/en_US-joe-medium.onnx?download=true";
      flake = false;
    };

    defaultVoiceConfig = {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/john/medium/en_US-john-medium.onnx.json?download=true";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, flake-utils, defaultVoice, defaultVoiceConfig, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        name = "read-aloud";

        readAloud = pkgs.writeShellScriptBin "read-aloud" ''

          pidfile=/tmp/read-aloud.pid

          # Check if the pidfile exists and if the process is running
          if [[ -f $pidfile ]]; then
              pid=$(cat $pidfile)
              if ps -p $pid > /dev/null; then
              kill $pid
                  exit 1
              fi
          fi

          # Get selected text from clipboard and read it via piper and aplay commands
          ${pkgs.xclip}/bin/xclip -out -selection primary | ${pkgs.xclip}/bin/xclip -in -selection clipboard
          ${pkgs.xsel}/bin/xsel --clipboard | tr "\n" " " | ${pkgs.piper-tts}/bin/piper --model ${defaultVoice} --config ${defaultVoiceConfig} --output_file - | ${pkgs.alsa-utils}/bin/aplay &

          # Get the PID of the last backgrounded process (aplay command)
          pid=$!

          # Write the PID to the pidfile
          echo $pid > $pidfile

        '';
      in
      rec {

        defaultPackage = packages."${name}";
        packages.read-aloud = pkgs.symlinkJoin {
          name = name;
          paths = [ readAloud ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

      }
    );
}
