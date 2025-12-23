{
  lib,
  fetchurl,
  buildLinux,
  linuxKernel,
  ...
}:
let
  pname = "linux-nix4loong";
  version = "6.17.7";
  commonPatches = linuxKernel.kernelPatches;
in
buildLinux {
  inherit pname;
  version = "${version}-nix4loong";
  modDirVersion = version;

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
    hash = "sha256-3fLqDUQ54dVxNr42IxAq+UWPYB9bHLd+gyRuiK6gnQ4=";
  };

  kernelPatches = [
    commonPatches.bridge_stp_helper
    commonPatches.request_key_helper
    {
      name = "add-motorcomm-yt6801-support";
      patch = ./patches/0141-BACKPORT-DEEPIN-ethernet-Add-motorcomm-yt6801-suppor.patch;
    }
    {
      name = "yt6801-fix-build-on-6.8";
      patch = ./patches/0143-DEEPIN-ethernet-yt6801-fix-build-on-6.8.patch;
    }
    {
      name = "add-ls7a-gpio-interrupt-support";
      patch = ./patches/0217-AOSCOS-gpio-loongson-64bit-Add-LS7A-GPIO-interrupt-s.patch;
    }
  ];

  extraMeta = {
    description = "The Linux kernel with patches for LoongArch platforms";
  };
}
