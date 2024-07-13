{ pkgs, lib, ... }:
{

  options = {
    read-aloud = {
      model = lib.mkOption {
        default = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/joe/medium/en_US-joe-medium.onnx?download=true";
        type = lib.types.string;
        description = ''
          The voice onnx download url
        '';
      };
    };

  };

  config = {
    home.file."read-aloud".source =
      let

        defaultVoice = {
          url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/joe/medium/en_US-joe-medium.onnx?download=true";
          flake = false;
        };

        defaultVoiceConfig = {
          url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/john/medium/en_US-john-medium.onnx.json?download=true.json";
          flake = false;
        };

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
      "${readAloud}/bin/read-aloud";

    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "read-aloud";
        command = "read-aloud";
        binding = "<Ctrl><Esc>";
      };
    };
  };

}
