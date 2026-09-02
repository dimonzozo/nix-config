{
  config,
  lib,
  internal,
  namespace,
  pkgs,
  inputs,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.tools.common;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  options.${namespace}.tools.common = with types; {
    enable = mkBoolOpt true "Whether to enable the common tools module";

    core = {
      enable = mkBoolOpt true "Whether to enable core tools";
      extraPackages = mkOption {
        type = listOf package;
        default = [ ];
        description = "Additional core packages to install";
      };
    };

    development = {
      enable = mkBoolOpt false "Whether to enable development tools";
      go = mkBoolOpt false "Whether to enable Go development tools";
      nix = mkBoolOpt false "Whether to enable Nix development tools";
      markdown = mkBoolOpt false "Whether to enable Markdown/HTML development tools";
      sdr = mkBoolOpt false "Whether to enable SDR development tools";
      extraPackages = mkOption {
        type = listOf package;
        default = [ ];
        description = "Additional development packages to install";
      };
    };

    system = {
      enable = mkBoolOpt false "Whether to enable system tools";
      monitoring = mkBoolOpt false "Whether to enable monitoring tools";
      network = mkBoolOpt false "Whether to enable network tools";
      extraPackages = mkOption {
        type = listOf package;
        default = [ ];
        description = "Additional system packages to install";
      };
    };

    multimedia = {
      enable = mkBoolOpt false "Whether to enable multimedia tools";
      viewers = mkBoolOpt false "Whether to enable document/media viewers";
      extraPackages = mkOption {
        type = listOf package;
        default = [ ];
        description = "Additional multimedia packages to install";
      };
    };

    shell = {
      enable = mkBoolOpt false "Whether to enable shell enhancements";
      navigation = mkBoolOpt false "Whether to enable file navigation tools";
      misc = mkBoolOpt false "Whether to enable misc utilities";
      extraPackages = mkOption {
        type = listOf package;
        default = [ ];
        description = "Additional shell utility packages to install";
      };
    };

    theming = {
      enable = mkBoolOpt true "Whether to enable theming";
      catppuccin = mkBoolOpt true "Whether to enable Catppuccin theme";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Core tools configuration
    (mkIf cfg.core.enable {
      programs = {
        # Bat: Modern alternative to 'cat' with syntax highlighting and Git integration
        bat = {
          enable = true;
          extraPackages = with pkgs.bat-extras; [
            batgrep
            batwatch
            prettybat
          ];
          config = {
            style = "plain";
          };
        };

        # Bottom: Bottom - a cross-platform graphical process/system monitor
        bottom = {
          enable = true;
        };

        # Dircolors: Colorize file listings in terminal
        dircolors = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };

        # Direnv: Directory-specific environment variables manager
        direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          nix-direnv = {
            enable = true;
          };
        };

        # Eza: Modern replacement for 'ls' command
        eza = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          extraOptions = [
            "--group-directories-first"
            "--header"
          ];
          git = true;
          icons = "auto";
        };

        # Fzf: Command-line fuzzy finder
        fzf = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
        };

        # Gitui: Terminal user interface for Git
        gitui = {
          enable = true;
        };

        # GPG: GNU Privacy Guard for encryption and signing
        gpg.enable = true;

        # Home-manager: Nix-based user environment management tool
        home-manager.enable = true;

        # Jq: Command-line JSON processor
        jq.enable = true;

        # Micro: Modern terminal-based text editor
        micro = {
          enable = true;
          settings = {
            autosu = true;
            diffgutter = true;
            paste = true;
            rmtrailingws = true;
            savecursor = true;
            saveundo = true;
            scrollbar = true;
            scrollbarchar = "░";
            scrollmargin = 4;
            scrollspeed = 1;
          };
        };

        # Nix-index: Index for searching Nix packages
        nix-index.enable = true;

        # Ripgrep: Fast line-oriented search tool
        ripgrep = {
          arguments = [
            "--colors=line:style:bold"
            "--max-columns-preview"
            "--smart-case"
          ];
          enable = true;
        };

        # Yazi: Terminal file manager
        yazi = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          settings = {
            manager = {
              show_hidden = false;
              show_symlink = true;
              sort_by = "natural";
              sort_dir_first = true;
              sort_sensitive = false;
              sort_reverse = false;
            };
          };
        };

        # Yt-dlp: Video downloader supporting various streaming platforms
        yt-dlp = {
          enable = true;
          settings = {
            audio-format = "best";
            audio-quality = 0;
            embed-chapters = true;
            embed-metadata = true;
            embed-subs = true;
            embed-thumbnail = true;
            remux-video = "aac>m4a/mov>mp4/mkv";
            sponsorblock-mark = "sponsor";
            sub-langs = "all";
          };
        };

        # Zoxide: Smarter cd command with directory jumping
        zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          options = [ "--cmd cd" ];
        };
      };

      home.sessionVariables = {
        PAGER = "bat";
      };

      home.packages =
        with pkgs;
        [
          asciiquarium-transparent # Terminal aquarium
          bc # Arbitrary precision calculator
          btop # System resources monitor
          cloudflared # Cloudflare tunnel client
          coreutils # Basic file/shell manipulation utilities
          curl # Command-line tool for transferring data
          devenv # Development environment manager
          dua # Disk usage analyzer
          duf # Disk usage utility
          fastfetch # System information tool
          fd # Find alternative
          file # File type identification utility
          frogmouth # Markdown viewer
          glow # Markdown renderer
          gnumake # GNU make tool
          gnused # GNU stream editor
          hexyl # Hex viewer
          killall # Process termination utility
          mtr # Network diagnostic tool
          nh # Nix helper scripts
          onefetch # Git repository summary
          procs # Modern process viewer
          rsync # File transfer tool
          sd # Search & replace tool
          sshpass # Non-interactive ssh password authentication
          timer # Command-line timer utility
          tldr # Simplified man pages
          tokei # Code statistics tool
          unzip # ZIP archive extraction utility
          wget # Network utility to retrieve files
          yq-go # YAML/XML/JSON processor
          # zathura # Document viewer
        ]
        ++ lib.optionals isLinux [
          acpi # Battery information
          glibc.dev # Glibc documentation
          man-pages # Man pages
          man-pages-posix # Man pages for POSIX stuff
          pciutils # PCI utilities
          ramfetch # RAM information
          usbutils # USB utilities
        ]
        ++ lib.optionals isDarwin [
          m-cli # macOS command-line tools
        ]
        ++ cfg.core.extraPackages;
    })

    # Development tools configuration
    (mkIf cfg.development.enable (mkMerge [
      {
        home.packages = cfg.development.extraPackages;
      }
      (mkIf cfg.development.markdown {
        home.packages = with pkgs; [
          superhtml # HTML/CSS/JS language server
          marksman # Markdown language server
        ];
      })
      (mkIf cfg.development.go {
        home.packages = with pkgs; [
          go # Go programming language
          (lib.lowPrio gopls) # Go language server
          gotools # Go tools collection
          golangci-lint # Go linter aggregator
          golangci-lint-langserver # Language server for golangci-lint
          gofumpt # Stricter gofmt
          # gci # Go package import ordering
        ];
      })
      (mkIf cfg.development.nix {
        home.packages = with pkgs; [
          nix-diff # Compare Nix derivations
          nvd # Nix/NixOS version diff tool
          nixfmt # Nix code formatter
          nixpkgs-review # Review nixpkgs pull requests
          nix-prefetch-scripts # Prefetch source tarballs
          nurl # Generate Nix fetcher calls
          deadnix # Find unused code in .nix files
          meld # File and directory comparison tool
        ];
      })
      (mkIf cfg.development.sdr (
        let
          unstable = import inputs.unstable {
            system = pkgs.system;
          };
        in
        {
          home.packages = with pkgs; [
            gnuradio # General-purpose software-defined radio framework
            gqrx
            inspectrum
            libad9361 # Interface library for Analog Devices AD936x RF transceivers
            libiio # Library for industrial I/O devices and ADC/DAC interfacing
            # (sdrangel.overrideAttrs (
            #   finalAttrs: previousAttrs: {
            #     cmakeFlags = (previousAttrs.cmakeFlags or [ ]) ++ [
            #       "-DIIO_DIR=${pkgs.libiio}/lib"
            #     ];
            #   }
            # ))
            sdrpp
            sigdigger
            soapysdr
            unstable.soapyplutosdr
            urh
          ];
          home.sessionVariables = {
            SOAPY_SDR_PLUGIN_PATH = "${unstable.soapyplutosdr}/lib/SoapySDR/modules0.8-3";
          };
        }
      ))
    ]))

    # System tools configuration
    (mkIf cfg.system.enable (mkMerge [
      {
        home.packages = cfg.system.extraPackages;
      }
      (mkIf cfg.system.monitoring {
        home.packages = with pkgs; [
          bandwhich # Network utilization monitor
          bmon # Bandwidth monitor
        ];
      })
      (mkIf (isLinux && cfg.system.monitoring) {
        home.packages = with pkgs; [
          s-tui # CPU monitoring/stress testing
          stress-ng # System stress testing
          sysstat # Performance monitoring tools
          lurk # System call monitor
          psmisc # Process management tools
          writedisk # Disk writer
        ];
      })
      (mkIf cfg.system.network {
        home.packages = with pkgs; [
          curlie # Curl wrapper
          doggo # Modern DNS client
          gping # Ping with graph
          httpie # User-friendly HTTP client
          iperf3 # Network performance tool
          netdiscover # Network address discovery
          speedtest-go # Internet speed test
          tcpdump
          wavemon # Wireless device monitor
        ];
      })
    ]))

    # Shell enhancements configuration
    (mkIf cfg.shell.enable (mkMerge [
      {
        home.packages = cfg.shell.extraPackages;
      }
      (mkIf cfg.shell.navigation {
        home.packages = with pkgs; [
          h # Quick directory navigator
          broot # Directory tree explorer
          lf # Terminal file manager
          nnn # Terminal file manager
        ];
      })
      (mkIf cfg.shell.misc {
        home.packages = with pkgs; [
          rclone # Cloud storage sync
          croc # File transfer tool
          chafa # Terminal graphics
          w3m # Text-based browser
          entr # File change watcher
          hyperfine # Command benchmark tool
        ];
      })
    ]))

    # Multimedia configuration
    (mkIf cfg.multimedia.enable (mkMerge [
      {
        home.packages = cfg.multimedia.extraPackages;
      }
      (mkIf isLinux {
        home.packages = with pkgs; [
          imv # Image viewer
        ];
      })
      {
        home.packages = with pkgs; [
          asciinema # Terminal recorder
          asciinema-agg # Asciinema to GIF converter
          dotacat # Text colorizer
          peaclock # Terminal clock
        ];
      }
    ]))

    # Platform-specific configurations
    # Theming configuration
    (mkIf cfg.theming.enable {
      catppuccin = mkIf cfg.theming.catppuccin (
        let
          accent = "blue";
          flavor = "mocha";
        in
        {
          inherit accent flavor;
          yazi.enable = true;
          starship.enable = true;
          micro.enable = true;
          lazygit.enable = true;
          kitty.enable = true;
          gitui.enable = true;
          fzf.enable = true;
          fish.enable = true;
          bottom.enable = true;
          bat.enable = true;
          hyprland.enable = true;
          kvantum = {
            inherit accent flavor;
            enable = true;
            apply = true;
          };
          gtk = {
            icon = {
              inherit accent flavor;
              enable = true;
            };
          };
        }
      );
    })
  ]);
}
