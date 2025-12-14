# nix-loongarch-kernel

Linux 6.17 kernel with additional patches for LoongArch platforms.

## Patches

- Motorcomm YT6801 NIC driver

## Binary Cache

To speed up builds, you can use the binary cache provided by nix4loong.cn:

```nix
nix.extraOptions = ''
  extra-substituters = https://cache.nix4loong.cn
  extra-trusted-public-keys = cache.nix4loong.cn-1:zmkwLihdSUyy6OFSVgvK3br0EaUEczLiJgDfvOmm3pA=
  extra-system-features = gccarch-la64v1.0 gccarch-loongarch64
'';
```

Alternatively, use the installation image from [nix4loong.cn](https://nix4loong.cn), which comes with the cache and the kernel pre-configured.

## Usage

### Option 1: NixOS Module (Recommended)

This method is recommended as it can take full advantage of the binary cache.

```nix
{
  inputs.nix-loongarch-kernel.url = "github:darkyzhou/nix-loongarch-kernel";

  outputs = { self, nixpkgs, nix-loongarch-kernel, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "loongarch64-linux";
      modules = [
        nix-loongarch-kernel.nixosModules.default
      ];
    };
  };
}
```

### Option 2: Overlay

Note: Using an overlay may not hit the binary cache due to different derivation hashes.

```nix
{
  inputs.nix-loongarch-kernel.url = "github:darkyzhou/nix-loongarch-kernel";

  outputs = { self, nixpkgs, nix-loongarch-kernel, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "loongarch64-linux";
      modules = [
        {
          nixpkgs.overlays = [ nix-loongarch-kernel.overlay ];
          boot.kernelPackages = pkgs.linuxPackages-nix4loong;
        }
      ];
    };
  };
}
```

## Acknowledgements

Special thanks to the [AOSC](https://aosc.io) community and all the patch authors for their contributions to LoongArch Linux support.
