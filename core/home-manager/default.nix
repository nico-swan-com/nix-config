{ pkgs, cfg, ... }:
{

  imports = [
    ../common/home-packages.nix
  ];

  home.stateVersion = "24.05";

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    nicoswan = {
      zsh.enable = true;
      starship.enable = true;
    };

    # Git configuration
    git = {
      enable = true;
      userName = cfg.fullname;
      userEmail = cfg.email;
      extraConfig = {
        init.defaultBranch = "main";
        diff.colorMoved = "default";
        pull.rebase = true;
        core.pager = "delta";

        interactive.diffFilter = "${pkgs.delta}/bin/delta  --line-numbers --dark --paging=never --syntax-theme=dracula";

        delta = {
          navigate = true; # use n and N to move between diff sections
          dark = true; # or light = true, or omit for auto-detection
        };
        merge.conflictstyle = "zdiff3";

        ignores = [
          "*~"
          ".DS_Store"
        ];
        # Enhanced diffs
        # delta.enable = true;
        difftastic.enable = true;
        difftastic.display = "inline";
      };

      lazygit = {
        enable = true;
        settings = {
          git = {
            paging = {
              pager = "${pkgs.delta}/bin/delta  --line-numbers --dark --paging=never --syntax-theme=dracula";
            };
          };
          gui = {
            language = "en";
            mouseEvents = false;
            sidePanelWidth = 0.3;
            mainPanelSplitMode = "flexible";
            showFileTree = true;
            nerdFontsVersion = 3;
            commitHashLength = 6;
            showDivergenceFromBaseBranch = "arrowAndNumber";
            skipDiscardChangeWarning = true;
          };
          quitOnTopLevelReturn = true;
          disableStartupPopups = true;
          promptToReturnFromSubprocess = false;
          customCommands = [
            {
              key = "C";
              command = ''git commit -m "{{ .Form.Type }}{{if .Form.Scopes}}({{ .Form.Scopes }}){{end}}: {{ .Form.Description }}" -m "{{ .Form.LongDescription }}"'';
              description = "commit with commitizen and long description";
              context = "files";
              prompts = [
                {
                  type = "menu";
                  title = "Select the type of change you are committing.";
                  key = "Type";
                  options = [
                    {
                      name = "Feature";
                      description = "a new feature";
                      value = "feat";
                    }
                    {
                      name = "Fix";
                      description = "a bug fix";
                      value = "fix";
                    }
                    {
                      name = "Documentation";
                      description = "Documentation only changes";
                      value = "docs";
                    }
                    {
                      name = "Styles";
                      description = "Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)";
                      value = "style";
                    }
                    {
                      name = "Code Refactoring";
                      description = "A code change that neither fixes a bug nor adds a feature";
                      value = "refactor";
                    }
                    {
                      name = "Performance Improvements";
                      description = "A code change that improves performance";
                      value = "perf";
                    }
                    {
                      name = "Tests";
                      description = "Adding missing tests or correcting existing tests";
                      value = "test";
                    }
                    {
                      name = "Builds";
                      description = "Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)";
                      value = "build";
                    }
                    {
                      name = "Continuous Integration";
                      description = "Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)";
                      value = "ci";
                    }
                    {
                      name = "Chores";
                      description = "Other changes that don't modify src or test files";
                      value = "chore";
                    }
                    {
                      name = "Reverts";
                      description = "Reverts a previous commit";
                      value = "revert";
                    }
                  ];
                }
                {
                  type = "input";
                  title = "Enter the scope(s) of this change.";
                  key = "Scopes";
                }
                {
                  type = "input";
                  title = "Enter the short description of the change.";
                  key = "Description";
                }
                {
                  type = "input";
                  title = "Enter a longer description of the change (optional).";
                  key = "LongDescription";
                }
                {
                  type = "confirm";
                  title = "Is the commit message correct?";
                  body = ''
                    {{ .Form.Type }}{{if .Form.Scopes}}({{ .Form.Scopes }}){{end}}: {{ .Form.Description }}
                    {{ .Form.LongDescription }}
                  '';
                }
              ];
            }
          ];
        };
      };

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };


    };
  }
