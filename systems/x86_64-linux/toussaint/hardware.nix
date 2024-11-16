{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.kernelModules = [
    "kvm-amd"
    "amdgpu"
  ];
  boot.kernelParams = [
    # "quiet"
    # "splash"
    # "console=tty0"
    # "console=ttyS0,115200n8"
    "amdgpu.ppfeaturemask=0xfff7ffff"
  ];

  # Plymouth configuration
  # boot.plymouth = {
  #   enable = true;
  #   theme = "spinner";
  # };

  # Optional: Configure kernel message logging
  # boot.kernel.sysctl = {
  #   "kernel.printk" = "7 4 1 7"; # console_loglevel default_message_loglevel minimum_console_loglevel default_console_loglevel
  # };
  # boot.consoleLogLevel = 7;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
    "tpm"
    "tpm_tis"
    "tpm_crb"
  ];
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "tpm"
    "tpm_tis" # For discrete TPM
    "tpm_crb" # For firmware TPM
  ];
  boot.extraModulePackages = [ ];

  boot.initrd.systemd.enable = true; # Required for TPM2 handling
  # FIX: enabling this is a safety risk, but it is good for debug
  boot.initrd.systemd.emergencyAccess = true;

  # use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."enc" = {
    device = "/dev/disk/by-uuid/6da23928-95a2-45e3-a72b-d4d2c09a2f3d";
    preLVM = true;
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pcrs=7"
      "tpm2-pin=yes"
      "fallback=yes" # Allow fallback to LUKS passphrase
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=log"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/AD3D-8FF1";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/a9062f39-5c61-4d91-8eb7-9550b6ed9962"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.linux-firmware ];

    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;

    cpu.amd.updateMicrocode = true;
    graphics = {
      enable = true;

      extraPackages = with pkgs; [
        # vaapi
        amdvlk # AMD Vulkan driver
        vaapiVdpau # VAAPI to VDPAU bridge for video decoding
        mesa.drivers # Open source drivers for various GPUs including Intel, AMD, and NVIDIA
        mesa
        libva
        libva-utils
        libdrm

        # vulkan
        vulkan-loader
        vulkan-validation-layers

        # For Firefox's multimedia backend
        libvdpau
        libvdpau-va-gl

        # rocm-opencl-icd
        # rocm-opencl-runtime
        # rocm-opencl-icd # ROCm OpenCL ICD (Installable Client Driver) loader
        # rocm-opencl-runtime # ROCm OpenCL runtime environment
        # intel-media-driver # Intel VA-API media driver (iHD) for hardware video acceleration
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    glxinfo
    libva-utils
    nvtopPackages.amd
  ];

  services.udev.extraRules = ''
    KERNEL=="renderD128", GROUP="video", MODE="0660"
    KERNEL=="card0", GROUP="video", MODE="0660"
  '';

  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.sessionVariables = {
    # vulkan
    # AMD_VULKAN_ICD = "RADV"; # Force RADV driver
    # RADV_DEBUG = "info"; # More verbose Vulkan logging
    # VK_LOADER_DEBUG = "info"; # Help diagnose driver loading issues
    # MESA_VK_VERSION_OVERRIDE = "1.3"; # Force Vulkan 1.3 features   
    # LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    # VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    LIBVA_DRIVER_NAME = "radeonsi";
    EGL_PLATFORM = "wayland";
  };
}
