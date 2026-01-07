{
  lib,
  fetchurl,
  buildLinux,
  linuxKernel,
  ...
}:
let
  pname = "linux";
  version = "6.18.3";
  suffix = "-nix4loong";

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
  modDirVersion = "${version}${suffix}";

  structuredExtraConfig = with lib.kernel; {
    LOCALVERSION = freeform suffix;

    MOUSE_PS2_PIXART = yes;
    CPU_HWMON = yes;
    CAN_LSCANFD = yes;
    CAN_LSCANFD_PLATFORM = module;
  };

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
    hash = "sha256-VYxrurdJSSs0+Zgn/oB7ADmnRGk8IdOn4Ds6SO2quWo=";
  };

  kernelPatches = commonPatches ++ localPatches;

  extraMeta = {
    description = "The Linux kernel with patches for LoongArch platforms";
  };
}
