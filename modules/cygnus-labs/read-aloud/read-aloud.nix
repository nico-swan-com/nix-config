{ stdenv, pkgs, lib }:
let

  defaultVoice = pkgs.fetchurl {
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/joe/medium/en_US-joe-medium.onnx?download=true";
    name = "en_US-joe-medium.onnx";
    sha256 = "sha256-WK/OAyG42cRtfN+cFlAMxVp5O0IgIS26a3D7eIs7rwY=";
  };

  defaultVoiceConfig = pkgs.fetchurl {
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/joe/medium/en_US-joe-medium.onnx.json?download=true.json";
    name = "en_US-joe-medium.onnx.json";
    sha256 = "sha256-PW1UELN5XLGVBZUkfvjwYZBxnm/b+jojVtjsNo4arTM=";
  };

  readAloud = pkgs.writeShellScriptBin "read-aloud" ''

    PID_FILE=/tmp/read-aloud.pid
    VOICE_MODEL_PATH=${defaultVoice}
    VOICE_CONFIG_PATH=${defaultVoiceConfig}


    while [ $# -gt 0 ]; do
      case "$1" in
        --voice*|-v*)
          if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
          VOICE_MODEL_PATH="''${1#*=}"
          ;;
        --voice-config*|-c*)
          if [[ "$1" != *=* ]]; then shift; fi
          VOICE_CONFIG_PATH="''${1#*=}"
          ;;
        --help|-h)
          printf "Read aloud - Reads selected text aloud for the user. \n"
          printf "A TTS script that reads the clibboard and reads it aloud for the user. It uses the \n"
          printf "xclip, xsel to grab the text and then send it to piper-tts for text to speach conversion. \n"
          printf "\n"
          printf " Usage: read-aloud [options] \n"
          printf " Options \n"
          printf "  --voice | -v  The path to the onnx model file.\n"
          printf "  --voice-config | -c The path to the model config json file.\n"
          printf "\n"
          exit 0
          ;;
        *)
          >&2 printf "Error: Invalid argument\n"
          exit 1
          ;;
      esac
      shift
    done



    # Check if the pid file exists and if the process is running
    if [[ -f $PID_FILE ]]; then
        pid=$(cat $PID_FILE)
        if ps -p $pid > /dev/null; then
        kill $pid
            exit 1
        fi
    fi

    # Get selected text from clipboard and read it via piper and aplay commands
    ${pkgs.xclip}/bin/xclip -out -selection primary | ${pkgs.xclip}/bin/xclip -in -selection clipboard
    ${pkgs.xsel}/bin/xsel --clipboard | tr "\n" " " | ${pkgs.piper-tts}/bin/piper --model $VOICE_MODEL_PATH --config $VOICE_CONFIG_PATH --output_file - | ${pkgs.alsa-utils}/bin/aplay &

    # Get the PID of the last backgrounded process (aplay command)
    pid=$!

    # Write the PID to the pidfile
    echo $pid > $PID_FILE

  '';

in
stdenv.mkDerivation rec {
  name = "read-aloud-${version}";
  pname = "read-aloud";
  version = "1.0";

  src = [ readAloud ];

  buildInputs = [ readAloud ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/bin/${pname} $out/bin/${pname}
  '';

  meta = with lib; {
    description = "Read aloud - Reads selected text aloud for the user.";
    longDescription = ''
      A TTS script that reads the clibboard and reads it aloud for the user. It uses the
      xclip, xsel to grab the text and then send it to piper-tts for text to speach conversion.

      Addtional voices can be downloaded at https://huggingface.co/rhasspy/piper-voices/tree/main
    '';
    homepage = "https://github.com/cygnus-labs-com/gnome-read-aloud";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
