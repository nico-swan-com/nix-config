{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    prefix = "C-a";
    terminal = "tmux-256color"; # screen-256color
    escapeTime = 10;
    baseIndex = 1;

    tmuxinator = {
      enable = true;
    };

    plugins = with pkgs; [
      tmuxPlugins.prefix-highlight
      tmuxPlugins.vim-tmux-navigator
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
      tmuxPlugins.resurrect
      tmuxPlugins.yank
    ];

  extraConfig = ''
    unbind %
    bind | split-window -h 

    unbind '"'
    bind - split-window -v

    bind j resize-pane -D 5
    bind k resize-pane -U 5
    bind l resize-pane -R 5
    bind h resize-pane -L 5

    bind -r m resize-pane -Z

    # set vi-mode
    set-window-option -g mode-keys vi
   
    # keybindings
    bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
    bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel # copy text with "y"
    bind-key -T copy-mode-vi C-v send -X rectangle-toggle

    unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode when dragging with mouse

    # Use Alt-arrow keys without prefix key to switch panes
    # bind - n M-Left select-pane - L
    # bind - n M-Right select-pane - R
    # bind - n M-Up select-pane - U
    # bind - n M-Down select-pane - D

    # Shift Alt vim keys to switch windows
    # bind - n M-H previous-window
    # bind - n M-L next-window

    # tpm plugin
    # set -g @plugin_path '~/.tmux/plugins/'
    set -g @plugin 'tmux-plugins/tpm'

    # list of tmux plugins
    set -g @plugin 'tmux-plugins/tmux-pain-control'
    # set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'tmux-plugins/tmux-logging'

    set -g @plugin 'fabioluciano/tmux-tokyo-night'

    ### Tokyo Night Theme configuration
    set -g @theme_variation 'moon'
    set -g @theme_left_separator ''
    set -g @theme_right_separator ''
    set -g @theme_plugins 'datetime,weather,playerctl,yay'

    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    run '~/.config/tmux/plugins/tpm/tpm'
      
 '';


  };
}
