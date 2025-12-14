{
  description = "Linux kernel with patches for LoongArch platforms";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs?ref=loong-release-25.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "loongarch64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      kernel = pkgs.callPackage ./kernel.nix { };
      linuxPackages = pkgs.linuxKernel.packagesFor kernel;
    in
    {
      packages.${system} = {
        default = kernel;
        kernel = kernel;
      };

      legacyPackages.${system} = {
        inherit linuxPackages;
      };

      overlay = self.overlays.default;
      overlays.default = final: prev: {
        linuxPackages-nix4loong = final.linuxKernel.packagesFor (final.callPackage ./kernel.nix { });
      };

      nixosModules.default = {
        boot.kernelPackages = linuxPackages;
      };

      hydraJobs.${system} = {
        inherit kernel;
      };
    };
}
