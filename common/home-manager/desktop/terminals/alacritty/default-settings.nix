{
  env = {
    "TERM" = "xterm-256color";
  };

  selection.save_to_clipboard = true;
  live_config_reload = true;


  shell = {
    program = "/run/current-system/sw/bin/zsh";
    args = [ "-l" "-c" "tmux" ];
  };

  mouse.bindings = [
    { mouse = "Right"; action = "Paste"; }
  ];

  window = {
    padding.x = 0;
    padding.y = 0;
    decorations = "Full";
    blur = true;
    opacity = 0.95;
    dimensions = {
      columns = 150;
      lines = 50;
    };
  };

  scrolling = {
    history = 10000;
    multiplier = 40;
  };

  font = {
    size = 12.0;
    normal = { family = "FiraCode Nerd Font"; style = "Light"; };
    bold = { family = "FiraCode Nerd Font"; style = "Semibold"; };
    italic.family = "FiraCode Nerd Font";
  };

  cursor.style = "Beam";

  keyboard.bindings = [
    {
      key = "W";
      mods = "Command";
      action = "ToggleFullscreen";
    }
    {
      key = "N";
      mods = "Command|Shift";
      action = "SpawnNewInstance";
    }
    {
      key = "F";
      mods = "Command|Shift";
      action = "ToggleFullscreen";
    }
    {
      key = "Equals";
      mods = "Command|Shift";
      action = "IncreaseFontSize";
    }
    {
      key = "Minus";
      mods = "Command|Shift";
      action = "DecreaseFontSize";
    }
    # Use command + [ - to go to previous tmux window
    {
      key = "LBracket";
      mods = "Command";
      chars = "\x5c\x70";
    }
    # Use command + ] - to go to previous tmux window
    {
      key = "RBracket";
      mods = "Command";
      chars = "\x5c\x6e";
    }
    # ctrl-^ doesn't work in some terminals like alacritty
    {
      key = "Key6";
      mods = "Control";
      chars = "\x1e";
    }

  ];

  colors = {
    primary = {
      background = "#1a1b26";
      foreground = "#a9b1d6";
    };
    # Normal colors
    normal = {
      black = "#32344a";
      red = "#f7768e";
      green = "#9ece6a";
      yellow = "#e0af68";
      blue = "#7aa2f7";
      magenta = "#ad8ee6";
      cyan = "#449dab";
      white = "#787c99";
    };
    # Bright colors
    bright = {
      black = "#444b6a";
      red = "#ff7a93";
      green = "#b9f27c";
      yellow = "#ff9e64";
      blue = "#7da6ff";
      magenta = "#bb9af7";
      cyan = "#0db9d7";
      white = "#acb0d0";
    };
  };
}



# custom_cursor_colors: true
# colors:
#   # Default colors
#   primary:
#     # hard contrast: background = '#f9f5d7'
#     background: '#1A2025'
#     foreground: '#e3dfc5'

#     dim_foreground: '#dbdbdb'
#     bright_foreground: '#d9d9d9'
#     dim_background: '#202020'    # not sure
#     bright_background: '#3a3a3a' # not sure

#   # Cursor colors
#   cursor:
#     text: '#2c2c2c'
#     cursor: '#d9d9d9'

#   # Normal colors
#   vi_mode_cursor:
#     text: '#2e3440'
#     cursor: '#d8dee9'
#   selection:
#     text: CellForeground
#     background: '#4c566a'
#   search:
#     matches:
#       foreground: CellBackground
#       background: '#abd3de'
#     bar:
#       background: '#434c5e'
#       foreground: '#d8dee9'
#   normal:
#   # Bright colors
#     black: '#1c1c1c'
#     red: '#bc5653'
#     green: '#b4c28a'
#     yellow: '#ebc17a'
#     blue: '#7eaac7'
#     magenta: '#aa6292'
#     cyan: '#d3dde8'
#     white: '#cacaca'

#   # Bright colors
#   bright:
#     black: '#636363'
#     red: '#bc5653'
#     green: '#b4c28a'
#     yellow: '#ebc17a'
#     blue: '#7eaac7'
#     magenta: '#aa6292'
#     cyan: '#d3dde8'
#     white: '#f7f7f7'

#   # Dim colors
#   dim:
#     black: '#232323'
#     red: '#74423f'
#     green: '#9ea880'
#     yellow: '#8b7653'
#     blue: '#556b79'
#     magenta: '#6e4962'
#     cyan: '#5c8482'
#     white: '#828282'
#   indexed_colors:
#     - {index: 16, color: '#232323'}
#     - {index: 17, color: '#d65d0e'}
#     - {index: 18, color: '#000000'}
#     - {index: 19, color: '#d5c4a1'}
#     - {index: 20, color: '#665c54'}
#     - {index: 21, color: '#3c3836'}
# hide_cursor_when_typing: true
# shell:
#   program: /bin/zsh
#   args:
#     - -l
