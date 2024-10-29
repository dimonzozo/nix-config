{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.tools.common;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  options.${namespace}.tools.common = with types; {
    enable = mkBoolOpt false "Whether or not to install common tools.";
  };

  config = mkIf cfg.enable {
    catppuccin = {
      accent = "blue";
      flavor = "mocha";
    };

    programs = {
      aria2.enable = true;
      bat = {
        catppuccin.enable = true;
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
      cava = {
        catppuccin.enable = true;
        enable = isLinux;
      };
      dircolors = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
      yazi = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        catppuccin.enable = true;
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
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv = {
          enable = true;
        };
      };
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
      fzf = {
        catppuccin.enable = true;
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
      gitui = {
        catppuccin.enable = true;
        enable = true;
      };
      gpg.enable = true;
      home-manager.enable = true;
      info.enable = true;
      jq.enable = true;
      micro = {
        catppuccin.enable = true;
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
      nix-index.enable = true;
      # powerline-go = {
      #   enable = true;
      #   settings = {
      #     cwd-max-depth = 5;
      #     cwd-max-dir-size = 12;
      #     theme = "gruvbox";
      #     max-width = 60;
      #   };
      # };
      ripgrep = {
        arguments = [
          "--colors=line:style:bold"
          "--max-columns-preview"
          "--smart-case"
        ];
        enable = true;
      };
      # tmate.enable = true;
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
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        # Replace cd with z and add cdi to access zi
        options = [ "--cmd cd" ];
      };
    };

    home = {
      # A Modern Unix experience
      # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
      packages =
        with pkgs;
        [
          cloudflared
          manix
          devenv
          go
          gnused
          (writeShellScriptBin "gsed" "exec ${gnused}/bin/sed \"$@\"")
          lazygit
          sshpass
          asciinema-agg # Convert asciinema to .gif
          asciinema # Terminal recorder
          bc # Terminal calculator
          bandwhich # Modern Unix `iftop`
          bmon # Modern Unix `iftop`
          chafa # Terminal image viewer
          chroma # Code syntax highlighter
          croc # Terminal file transfer
          curlie # Terminal HTTP client
          cyme # Modern Unix `lsusb`
          dconf2nix # Nix code from Dconf files
          deadnix # Nix dead code finder
          difftastic # Modern Unix `diff`
          dogdns # Modern Unix `dig`
          dotacat # Modern Unix lolcat
          dua # Modern Unix `du`
          duf # Modern Unix `df`
          du-dust # Modern Unix `du`
          editorconfig-core-c # EditorConfig Core
          entr # Modern Unix `watch`
          fastfetch # Modern Unix system info
          fd # Modern Unix `find`
          file # Terminal file info
          frogmouth # Terminal mardown viewer
          glow # Terminal Markdown renderer
          girouette # Modern Unix weather
          gping # Modern Unix `ping`
          h # Modern Unix autojump for git projects
          hexyl # Modern Unix `hexedit`
          hr # Terminal horizontal rule
          httpie # Terminal HTTP client
          hueadm # Terminal Philips Hue client
          hyperfine # Terminal benchmarking
          iperf3 # Terminal network benchmarking
          ipfetch # Terminal IP info
          lima-bin # Terminal VM manager
          marp-cli # Terminal Markdown presenter
          mtr # Modern Unix `traceroute`
          netdiscover # Modern Unix `arp`
          nixfmt-rfc-style # Nix code formatter
          nixpkgs-review # Nix code review
          nix-prefetch-scripts # Nix code fetcher
          nurl # Nix URL fetcher
          onefetch # Terminal git project info
          procs # Modern Unix `ps`
          quilt # Terminal patch manager
          rclone # Modern Unix `rsync`
          rsync # Traditional `rsync`
          sd # Modern Unix `sed`
          speedtest-go # Terminal speedtest.net
          timer # Terminal timer
          tldr # Modern Unix `man`
          tokei # Modern Unix `wc` for code
          ueberzugpp # Terminal image viewer integration
          unzip # Terminal ZIP extractor
          upterm # Terminal sharing
          wget # Terminal HTTP client
          wget2 # Terminal HTTP client
          yq-go # Terminal `jq` for YAML
        ]
        ++ lib.optionals isLinux [
          iw # Terminal WiFi info
          lurk # Modern Unix `strace`
          pciutils # Terminal PCI info
          psmisc # Traditional `ps`
          ramfetch # Terminal system info
          s-tui # Terminal CPU stress test
          stress-ng # Terminal CPU stress test
          usbutils # Terminal USB info
          wavemon # Terminal WiFi monitor
          writedisk # Modern Unix `dd`
          zsync # Terminal file sync; FTBFS on aarch64-darwin
        ]
        ++ lib.optionals isDarwin [
          m-cli # Terminal Swiss Army Knife for macOS
          nh
          coreutils
        ];

    };
  };
}
