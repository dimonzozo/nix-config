{
  config,
  lib,
  internal,
  pkgs,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.virtualization;
in
{
  options.${namespace}.virtualization = {
    enable = mkEnableOption "Server virtualization stack";

    qemu = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable basic QEMU/KVM setup";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.qemu;
        description = "QEMU package to use";
      };

      users = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Users who should be able to use KVM";
      };
    };

    docker = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Docker container runtime";
      };
    };

    podman = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Podman container runtime";
      };

      dockerCompat = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Docker compatibility socket for Podman";
      };
    };

    libvirt = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable libvirt virtualization stack";
      };

      vswitch = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Open vSwitch integration";
        };

        interfaces = mkOption {
          type = types.attrsOf (types.attrsOf types.anything);
          example = {
            eno1 = { };
          };
          description = "Network interfaces configuration for vSwitch";
        };

        trunks = mkOption {
          type = types.listOf types.int;
          example = [
            1
            2
            3
          ];
          description = "VLAN trunks configuration";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.podman.enable {
      virtualisation.podman = {
        enable = true;
        dockerSocket.enable = true;
        dockerCompat = cfg.podman.dockerCompat;
        defaultNetwork.settings.dns_enabled = true;
      };
    })

    (mkIf cfg.docker.enable {
      virtualisation.docker = {
        enable = true;
      };
      internal.user.extraGroups = [ "docker" ];
    })

    (mkIf cfg.libvirt.enable {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
      };

      environment.systemPackages = with pkgs; [
        virt-manager
      ];

      internal.user.extraGroups = [ "libvirtd" ];
    })

    (mkIf (cfg.libvirt.enable && cfg.libvirt.vswitch.enable) {
      virtualisation.vswitch = {
        enable = true;
        resetOnStart = false;
      };

      networking.vswitches = {
        vs0 = {
          interfaces = cfg.libvirt.vswitch.interfaces;
          extraOvsctlCmds = ''
            set port eno1 vlan_mode=trunk
            set port eno1 trunks=${concatStringsSep "," (map toString cfg.libvirt.vswitch.trunks)}
          '';
        };
      };
    })

    (mkIf cfg.qemu.enable {
      environment.systemPackages = with pkgs; [
        cfg.qemu.package
        docker-compose
        spice-gtk
        swtpm
        virt-viewer
      ];

      users.groups.kvm.members = cfg.qemu.users;
    })

  ]);
}
