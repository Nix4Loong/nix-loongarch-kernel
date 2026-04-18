# nix-loongarch-kernel

Linux stable kernel with additional patches for LoongArch platforms.

Check available versions in [tags](https://github.com/Nix4Loong/nix-loongarch-kernel/tags), though staying up-to-date with `main` is recommended.

## Patches

- HWMon support for Loongson 3 family processors
- PixArt PS/2 touchpad driver
- Legacy firmware boot support and AMD GPU stability fixes
- Full patch list: https://loongfans.cn/pages/sdk.html

## Motorcomm YT6801 Ethernet Controller

On kernel 6.19 and earlier, YT6801 support was provided by an out-of-tree driver imported from AOSC/Deepin (`CONFIG_YT6801`, Motorcomm SDK, ~17000 lines).

Starting with kernel 7.0, this repository uses the **mainline driver** `dwmac-motorcomm` by Yao Zi, enabled via `CONFIG_DWMAC_MOTORCOMM=m` (which `select`s `MOTORCOMM_PHY`). The old YT6801 patches have been dropped. Related submission history: <https://lwn.net/Articles/1016815/>.

### Parameter comparison between the two drivers

Captured on identical YT6801 hardware (PCI `1f0a:6801`) with `ethtool` against the same link partner.

| `ethtool -i` | old `yt6801` (6.19) | new `dwmac-motorcomm` (7.0) |
|---|---|---|
| driver | `yt6801` | `st_gmac` |
| version | `1.0.27` | kernel version |
| firmware-version | `S.D.U: 52.0.10` | _(empty)_ |
| supports-register-dump | yes | yes |

| `ethtool -g` (rings) | old | new |
|---|---|---|
| RX max / current | 1024 / 1024 | 1024 / 512 |
| TX max / current | 256 / 256 | 1024 / 512 |

| `ethtool -c` (coalesce) | old | new |
|---|---|---|
| rx-usecs | 200 | 327 |
| tx-usecs | 200 | 5000 |
| tx-frames | n/a | 25 |

| `ethtool -k` (features, selected) | old | new |
|---|---|---|
| highdma | off [fixed] | on [fixed] |
| receive-hashing | on | off [fixed] |
| rx-vlan-filter | on | off [fixed] |
| tx-vlan-offload | on | on [fixed] |

| `ethtool` (link) | old | new |
|---|---|---|
| Supported ports | `[ MII ]` | `[ TP MII ]` |
| Transceiver | internal | external |
| Link partner info | not reported | reported |

## Binary Cache

To speed up builds, you can use the binary cache provided by nix4loong.cn:

```nix
nix.extraOptions = ''
  extra-substituters = https://cache.nix4loong.cn
  extra-trusted-public-keys = cache.nix4loong.cn-1:zmkwLihdSUyy6OFSVgvK3br0EaUEczLiJgDfvOmm3pA=
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

Special thanks to [loongfans.cn](https://loongfans.cn/pages/sdk.html) and all the patch authors for their contributions.
