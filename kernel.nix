{
  lib,
  fetchurl,
  buildLinux,
  linuxKernel,
  ...
}:
let
  pname = "linux";
  version = "7.2.9";
  suffix = "-nix4loong";
  modVersion = lib.versions.pad 3 version;

  patchesDir = ./patches;
  localPatches =
    lib.mapAttrsToList
      (name: _: {
        inherit name;
        patch = patchesDir + "/${name}";
      })
      (
        lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".patch" name) (
          builtins.readDir patchesDir
        )
      );

  commonPatches = with linuxKernel.kernelPatches; [
    bridge_stp_helper
    request_key_helper
  ];
in
buildLinux {
  inherit pname;
  version = "${version}${suffix}";
  modDirVersion = "${modVersion}${suffix}";

  structuredExtraConfig = with lib.kernel; {
    LOCALVERSION = freeform suffix;

    MOUSE_PS2_PIXART = yes;
    CPU_HWMON = yes;
    CAN_LOONGSON_CANFD = module;
    DWMAC_MOTORCOMM = module;
    LOONGSON2_APB_CMC_DMA = module;
  };

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
    hash = "sha256-tMXfvlGjZKbH8DhpIA+IyOH3dANTkAXxS3/GvJG42Lo=";
  };

  kernelPatches = commonPatches ++ localPatches;

  extraMeta = {
    description = "The Linux kernel with patches for LoongArch platforms";
  };
}
