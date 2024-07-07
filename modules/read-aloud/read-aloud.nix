{ stdenv, pkgs, lib }:
let

  defaultVoice = pkgs.fetchurl {
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/joe/medium/en_US-joe-medium.onnx?download=true";
    name = "en_US-joe-medium.onnx";
    sha256 = "sha256-WK/OAyG42cRtfN+cFlAMxVp5O0IgIS26a3D7eIs7rwY=";
  };

  defaultVoiceConfig = pkgs.fetchurl {
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/john/medium/en_US-john-medium.onnx.json?download=true.json";
    name = "en_US-john-medium.onnx.json";
    sha256 = "sha256-r2Dxd7a1UPPXowJyDA+4nn+UqCtdykZHde9jscaboJo=";
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
    description = "read aloud - is a script that reads the clibboard and reads it aloud for the user.";
    longDescription = ''
    '';
    homepage = "https://github.com/nico-swan-com/read-aloud";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
