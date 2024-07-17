#!/nix/store/5jw69mbaj5dg4l2bj58acg3gxywfszpj-bash-5.2p26/bin/bash

pidfile=/tmp/read-aloud.pid

VOICE_PATH=

while [ $# -gt 0 ]; do
  case "$1" in
    --voice*|-v*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      VOICE_PATH="${1#*=}"
      ;;
    --voice-config*|-c*)
      if [[ "$1" != *=* ]]; then shift; fi
      VOICE_CONFIG_PATH="${1#*=}"
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






# Check if the pidfile exists and if the process is running
if [[ -f $pidfile ]]; then
    pid=$(cat $pidfile)
    if ps -p $pid > /dev/null; then
    kill $pid
        exit 1
    fi
fi

# Get selected text from clipboard and read it via piper and aplay commands
/nix/store/p0nzv81f76dzc8w1p8blmwdzbwvh39mc-xclip-0.13/bin/xclip -out -selection primary | /nix/store/p0nzv81f76dzc8w1p8blmwdzbwvh39mc-xclip-0.13/bin/xclip -in -selection clipboard
/nix/store/rhdpl4pi2sx09b1nqzam5rxqb5rq8k1n-xsel-1.2.1/bin/xsel --clipboard | tr "\n" " " | /nix/store/k126rsvh49qgkyapns02l9fcl3m3ahwi-piper-2023.11.14-2/bin/piper --model /nix/store/qha4846n9w9bgmdzmb7gf9pn9f7dr5zl-en_US-joe-medium.onnx --config /nix/store/zdpns0f19b0vl3584c5b36cs9zm8ardm-en_US-joe-medium.onnx.json --output_file - | /nix/store/dhz1x7fy1wngjjih7hs4s3a2cdbrpfcq-alsa-utils-1.2.10/bin/aplay &

# Get the PID of the last backgrounded process (aplay command)
pid=$!

# Write the PID to the pidfile
echo $pid > $pidfile


