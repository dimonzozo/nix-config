{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  internal.disko.laptop = {
    enable = true;
    device = "/dev/vda";
    swapSize = "2G";
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "virtio_blk"
        "sr_mod"
      ];
      systemd.enable = true;
      # Bootstrap-flow testing: keep the emergency shell reachable.
      systemd.emergencyAccess = true;
    };

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = true;
      };
    };
  };

  systemd.services.emergency.environment.SYSTEMD_SULOGIN_FORCE = "1";
  systemd.services.rescue.environment.SYSTEMD_SULOGIN_FORCE = "1";

  networking.useDHCP = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
