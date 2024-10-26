{ pkgs, ... }:
{

  programs.vscode = {
    enable = true;
    #package = pkgs.vscodium;
    mutableExtensionsDir = true;
    #enableExtensionUpdateCheck = true;
    #enableUpdateCheck = true;

    #userSettings = {};
    #globalSnippets {
    #   fixme = {
    #     body = [
    #       "$LINE_COMMENT FIXME: $0"
    #     ];
    #     description = "Insert a FIXME remark";
    #     prefix = [
    #       "fixme"
    #     ];
    #   };
    # };
    #languageSnippets = {
    #   haskell = {
    #     fixme = {
    #       body = [
    #         "$LINE_COMMENT FIXME: $0"
    #       ];
    #       description = "Insert a FIXME remark";
    #       prefix = [
    #         "fixme"
    #       ];
    #     };
    #   };
    # };
    extensions = [


      #vscode-conventional-commits
    ] ++ (with pkgs.vscode-extensions; [
      #IDE
      dracula-theme.theme-dracula
      streetsidesoftware.code-spell-checker # Spell checker for VSCode
      #vscodevim.vim
      yzhang.markdown-all-in-one
      davidanson.vscode-markdownlint
      aaron-bond.better-comments # Improve your code commenting by annotating with alert, informational, TODOs, and more!
      mechatroner.rainbow-csv
      wakatime.vscode-wakatime
      alefragnani.project-manager
      oderwat.indent-rainbow
      usernamehw.errorlens

      eamodio.gitlens
      mhutchie.git-graph
      donjayamanne.githistory
      gitlab.gitlab-workflow


      ms-azuretools.vscode-docker
      jnoortheen.nix-ide
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers


      gruntfuggly.todo-tree
      bierner.emojisense   # Emoji int

      mkhl.direnv
      quicktype.quicktype  # Copy JSON, paste as Go, TypeScript, C#, C++ and more.
      christian-kohler.path-intellisense #Visual Studio Code plugin that autocompletes filenames
      mikestead.dotenv

      # AI
      github.copilot        # Github AI code assistant
      github.copilot-chat
      continue.continue     # The leading open-source AI code assistant           # Adds suggestions and autocomplete for emoji

      # Languages
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      redhat.vscode-yaml
      redhat.vscode-xml
      shardulm94.trailing-spaces

      # Angular
      angular.ng-template
      equinusocio.vsc-material-theme-icons

      # Html and CSS
      ecmel.vscode-html-css
      formulahendry.auto-rename-tag
      formulahendry.auto-close-tag
      bradlc.vscode-tailwindcss

      #Kubernetes
      ms-kubernetes-tools.vscode-kubernetes-tools

    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      #IDE
      {
        name = "vscode-conventional-commits";
        publisher = "vivaxy";
        version = "1.25.0";
        sha256 = "KPP1suR16rIJkwj8Gomqa2ExaFunuG42fp14lBAZuwI=";
      }

      {
        name = "vscode-todo-highlight";
        publisher = "wayou";
        version = "1.0.5";
        sha256 = "sha256-CQVtMdt/fZcNIbH/KybJixnLqCsz5iF1U0k+GfL65Ok=";
      }
      # Git
      {
        name = "commitlint";
        publisher = "joshbolduc";
        version = "2.6.0";
        sha256 = "sha256-3v7pXr65afjNLneTLH2OQi0XzCvm7bxhTJSnqSRsYcY=";
      }
      {
        name = "commit-message-editor";
        publisher = "adam-bender";
        version = "0.25.0";
        sha256 = "sha256-Vw5RkY3W4FqKvCWlscxxpGQsfm3g2bZJ5suityQ3mG8=";
      }
      {
        name = "vscode-git-tags";
        publisher = "howardzuo";
        version = "1.4.4";
        sha256 = "sha256-mRVpBDqorahkeVhQDigK1VxgxjMHDKDBx4s5ArvDhKw=";
      }
      {
        #Jump to a source code line in Github, Bitbucket, Gitlab, VisualStudio.com !
        name = "vscode-open-in-github";
        publisher = "ziyasal";
        version = "1.3.6";
        sha256 = "sha256-uJGCCvg6fj2He1HtKXC2XQLXYp0vTl4hQgVU9o5Uz5Q=";
      }

      #
      # Clean code
      #
      {
        name = "vscode-just-syntax";
        publisher = "nefrob";
        version = "0.6.0";
        sha256 = "sha256-CYFDNQQFk6vC6RG/ZLp36npunuJKHrqxrwiOF9RmPrM=";
      }

      #
      # Node
      #
      {
        name = "npm-intellisense";
        publisher = "christian-kohler";
        version = "1.4.5";
        sha256 = "sha256-liuFGnyvvVHzSv60oLkemFyv85R+RiGKErRIUz2PYKs=";
      }
      {
        name = "angular-console";
        publisher = "nrwl";
        version = "18.29.0";
        sha256 = "sha256-NYRPT7Nr/Eue/RvXlcH7C8cPHe5Z8ktOb4Ji51ngcIU=";
      }
      {
        name = "template-string-converter";
        publisher = "meganrogge";
        version = "0.6.1";
        sha256 = "sha256-w0ppzh0m/9Hw3BPJbAKsNcMStdzoH9ODf3zweRcCG5k=";
      }
      #
      # Testing
      #
      {
        name = "vscode-jest";
        publisher = "orta";
        version = "6.3.0";
        sha256 = "sha256-4H/GfTBfJONQIXhm+rxH40hLhHQc7sc6dh6KqF7vHHM=";
      }
      {
        name = "vscode-jest-runner";
        publisher = "firsttris";
        version = "0.4.74";
        sha256 = "sha256-35Ix6B/vkYQIky9KYsMsxgmRh1LYzBoRs9pMe8M5/rI=";
      }
      {
        name = "mock-server";
        publisher = "thinker";
        version = "21.2.1";
        sha256 = "sha256-YSMdR3uR+fc7T80pLrihCpHGP1eWklPbZZkD75ICiXY=";
      }
      {
        name = "quokka-vscode";
        publisher = "wallabyjs";
        version = "1.0.654";
        sha256 = "sha256-x5rjlKNGIuM4TjC8UqNcgWcO+CoKOeeh6uO5Z40hX9M=";
      }
      #
      # Typescript
      #
      {
        name = "vscode-bicep";
        publisher = "ms-azuretools";
        version = "0.30.23";
        sha256 = "sha256-WkHPZdeo42aro0qoy9EY1IauPFw9+Ld7dxJQTK4XLuE=";
      }
      {
        name = "tsimporter";
        publisher = "pmneo";
        version = "2.0.1";
        sha256 = "sha256-JQ7dAliryvVXH0Rg1uheSznOHqbp/BMwwlePH9P0kog=";
      }
      {
        name = "vscode-typescript-next";
        publisher = "ms-vscode";
        version = "5.7.20241015";
        sha256 = "sha256-rsgPV+KQExUzrMeWr8WiWXCphd3er1pxoAhlv2B9teE=";
      }
      {
        # Automatically finds, parses and provides code actions and code completion for all available imports. Works with Typescript and TSX.
        name = "autoimport";
        publisher = "steoates";
        version = "1.5.4";
        sha256 = "sha256-7iIwJJsoNbtTopc+BQ+195aSCLqdNAaGtMoxShyhBWY=";
      }
      {
        # Move TS - Move TypeScript files and update relative imports
        name = "move-ts";
        publisher = "stringham";
        version = "1.12.0";
        sha256 = "sha256-qjqdyER2T40YwpiBOQw5/jzaFa3Ek01wLx6hb1TM3ac=";
      }
      {
        # Move TS - Move TypeScript files and update relative imports
        name = "pretty-ts-errors";
        publisher = "yoavbls";
        version = "0.6.0";
        sha256 = "sha256-cmleAs7EMXT1z0o8Uq5ne2LrthUt/vhcN+iqfAy/i/8=";
      }
      {
        name = "vscode-auto-barrel";
        publisher = "imgildev";
        version = "1.4.3";
        sha256 = "sha256-JUYa6G0Rtu/ZAXZW7/i4VFP/NS5cX3GMcEsZW9ITGEw=";
      }

      #
      # Angular
      #
      {
        name = "angular-cli";
        publisher = "segerdekort";
        version = "0.0.19";
        sha256 = "sha256-SVtmVWxAbZ/0NSRlC096s5cCl+AcqG84LS1rnUFf5F8=";
      }
      {
        # Angular Material 2, Flex layout 1, Covalent 1 & Material icon snippets
        name = "angular-material";
        publisher = "1tontech";
        version = "0.13.0";
        sha256 = "sha256-a0CSuKJWBAT8IzN2ld/mlsxQ4UgWuZ9I1QbzL3S6N6U=";
      }

      {
        # Angular 18 snippets
        name = "angular2";
        publisher = "johnpapa";
        version = "18.0.2";
        sha256 = "sha256-h/qmDHG5zzDh76e4yq+s0vjNBYXupPqV5V72opEQsIs=";
      }
      {
        # Easily navigate to `typescript`|`template`|`style` in angular2 project.
        name = "angular2-switcher";
        publisher = "infinity1207";
        version = "0.4.0";
        sha256 = "sha256-hTSyH/AByYUcN3Ua+106/Eq8/fD5zQMGWjj8bGFyv9Y=";
      }
      {
        # Analyzes your Angular code and generates tests.
        name = "simontest";
        publisher = "simontest";
        version = "1.9.10";
        sha256 = "sha256-CISKqyWbT6Bmxt6kGtY3Knm1HOw4+5gvxwHyei3I1hE=";
      }
      {
        # Ultimate Angular code generation in Visual Studio Code.
        name = "angular-schematics";
        publisher = "cyrilletuzi";
        version = "6.16.0";
        sha256 = "sha256-Qxfws7Jghu9GSWhmWm8wO5UfQxWlKtz5rcX7JUxiR9o=";
      }
      {
        # This extension allows quickly scaffold angular 2 file templates in VS Code project.
        name = "vscode-angular2-files";
        publisher = "alexiv";
        version = "1.6.4";
        sha256 = "sha256-IpiPfakIfFG+sGmq7nn91mHNfPg7UkiUpDftmfwEQmI=";
      }
      {
        # The extension provides refactoring tools for your Angular codebase
        name = "arrr";
        publisher = "obenjiro";
        version = "0.1.3";
        sha256 = "sha256-nUKn58pP32LSLO0zS2lS+k/qVaNOI8cDMb5EFsxxBrU=";
      }

      {
        # Easily navigate between typescript, template, style, and associated test files in your Angular project using the Mac Touch
        name = "angular-file-changer";
        publisher = "john-crowson";
        version = "0.0.4";
        sha256 = "sha256-aBS4qn2p8Eh64EcWJJMkATNEzxt1O51QAxec5kb0Dug=";
      }

      # HTML and CSS
      {
        name = "color-info";
        publisher = "bierner";
        version = "0.7.2";
        sha256 = "sha256-Bf0thdt4yxH7OsRhIXeqvaxD1tbHTrUc4QJcju7Hv90=";
      }
      {
        name = "cssvar";
        publisher = "phoenisx";
        version = "2.6.4";
        sha256 = "sha256-3bfiV4rv43TBRkoo8Czf1mv+Q8bfq5foaA6Wp358k1s=";
      }
      {
        name = "vscode-scss-formatter";
        publisher = "sibiraj-s";
        version = "3.0.0";
        sha256 = "sha256-mpgMsbovPsUd0PSP2vj9g2Ql4m32P4DhQJVwqtnPV/g=";
      }
      {
        name = "vscode-scss";
        publisher = "mrmlnc";
        version = "0.10.0";
        sha256 = "sha256-Iuirq+SUZz3V6QHeZNyj9EaWSszL4fD4cdorcMnbbSI=";
      }
      {
        name = "vscode-css-peek";
        publisher = "pranaygp";
        version = "4.4.1";
        sha256 = "sha256-GX6J9DfIW9CLarSCfWhJQ9vvfUxy8QU0kh3cfRUZIaE=";
      }
      {
        name = "vscode-css-navigation";
        publisher = "pucelle";
        version = "1.15.0";
        sha256 = "sha256-qU0wVW17+YU5PCDEFmIqPR7XT867/pHNDoguFmdLk7A=";
      }
      #
      #Snippets
      #
      {
        name = "vscode-nestjs-snippets-extension";
        publisher = "imgildev";
        version = "1.4.0";
        sha256 = "sha256-03c4FShGO+kmrlRQRsk8Siob/Fmvbppsgpg7Sq+P4w4=";
      }
      {
        name = "vscode-nestjs-generator";
        publisher = "imgildev";
        version = "2.5.0";
        sha256 = "sha256-+0X/gwC8N5Ne1jwVYyShc4UhgV5crwxH3eV6fsEpRew=";
      }
      {
        name = "vscode-nestjs-swagger-snippets";
        publisher = "imgildev";
        version = "1.1.0";
        sha256 = "sha256-5V7yHRZ840fU4B2bdcVYCiTamfGt3KdzeF4m7mIWtHU=";
      }
      # {
      #   name = "";
      #   publisher = "";
      #   version = "";
      #   sha256 = "";
      # }

    ];
  };

}
