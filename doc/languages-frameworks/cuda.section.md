# CUDA {#cuda}

Compute Unified Device Architecture (CUDA) is a parallel computing platform and application programming interface (API) model created by NVIDIA. It's commonly used to accelerate computationally intensive problems and has been widely adopted for High Performance Computing (HPC) and Machine Learning (ML) applications.

Packages provided by NVIDIA which require CUDA are typically stored in CUDA package sets.

Nixpkgs provides a number of CUDA package sets, each based on a different CUDA release. Top-level attributes providing access to CUDA package sets follow these naming conventions:

- `cudaPackages_x_y`: A major-minor-versioned package set for a specific CUDA release, where `x` and `y` are the major and minor versions of the CUDA release.
- `cudaPackages_x`: A major-versioned alias to the major-minor-versioned CUDA package set with the latest widely supported major CUDA release.
- `cudaPackages`: An unversioned alias to the major-versioned alias for the latest widely supported CUDA release. The package set referenced by this alias is also referred to as the "default" CUDA package set.

While versioned package sets are available (e.g., `cudaPackages_12_2`), it is recommended to use the unversioned `cudaPackages` attribute, as versioned attributes are periodically removed.

Here are two examples to illustrate the naming conventions:

- If `cudaPackages_12_8` is the latest release in the 12.x series, but core libraries like OpenCV or ONNX Runtime fail to build with it, `cudaPackages_12` may alias `cudaPackages_12_6` instead of `cudaPackages_12_8`.
- If `cudaPackages_13_1` is the latest release, but core libraries like PyTorch or Torch Vision fail to build with it, `cudaPackages` may alias `cudaPackages_12` instead of `cudaPackages_13`.

All CUDA package sets include common CUDA packages like `libcublas`, `cudnn`, `tensorrt`, and `nccl`.

## Configuring Nixpkgs for CUDA {#cuda-configuring-nixpkgs-for-cuda}

CUDA support is not enabled by default in Nixpkgs. To enable CUDA support, make sure Nixpkgs is imported with a configuration similar to the following:

```nix
{
  allowUnfreePredicate =
    let
      ensureList = x: if builtins.isList x then x else [ x ];
    in
    package:
    builtins.all (
      license:
      license.free
      || builtins.elem license.shortName [
        "CUDA EULA"
        "cuDNN EULA"
        "cuSPARSELt EULA"
        "cuTENSOR EULA"
        "NVidia OptiX EULA"
      ]
    ) (ensureList package.meta.license);
  cudaCapabilities = [ <target-architectures> ];
  cudaForwardCompat = true;
  cudaSupport = true;
}
```

The majority of CUDA packages are unfree, so either `allowUnfreePredicate` or `allowUnfree` should be set.

The `cudaSupport` configuration option is used by packages to conditionally enable CUDA-specific functionality. This configuration option is commonly used by packages which can be built with or without CUDA support.

The `cudaCapabilities` configuration option specifies a list of CUDA capabilities. Packages may use this option to control device code generation to take advantage of architecture-specific functionality, speed up compile times by producing less device code, or slim package closures. As an example, one can build for Ada Lovelace GPUs with `cudaCapabilities = [ "8.9" ];`. If `cudaCapabilities` is not provided, the default value is calculated per-package set, derived from a list of GPUs supported by that version of CUDA. Please consult [supported GPUs](https://en.wikipedia.org/wiki/CUDA#GPUs_supported) for specific cards. Library maintainers should consult [NVCC Docs](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/) and its release notes.

:::{.important}
Certain CUDA capabilities are not targeted by default, including capabilities belonging to the Jetson family of devices (like `8.7`, which corresponds to the Jetson Orin) or non-baseline feature-sets (like `9.0a`, which corresponds to the Hopper exclusive feature set). If you need to target these capabilities, you must explicitly set `cudaCapabilities` to include them.
:::

The `cudaForwardCompat` boolean configuration option determines whether PTX support for future hardware is enabled.

## Configuring CUDA package sets {#cuda-configuring-cuda-package-sets}

CUDA package sets are created by `callPackage`-ing `pkgs/top-level/cuda-packages.nix` with an explicit argument for `cudaMajorMinorVersion`, a string of the form `"<major>.<minor>"` (e.g., `"12.2"`), which informs the CUDA package set tooling which version of CUDA to use. The majority of the CUDA package set tooling is available through the top-level attribute set `_cuda`, a fixed-point defined outside the CUDA package sets.

::: {.important}
The `cudaMajorMinorVersion` and `_cuda` attributes are not part of the CUDA package set fixed-point, but are instead provided by `callPackage` from the top-level in the construction of the package set. As such, they must be modified via the package set's `override` attribute.
:::

:::{.important}
As indicated by the underscore prefix, `_cuda` is an implementation detail and no guarantees are provided with respect to its stability or API. The `_cuda` attribute set is exposed only to ease creation or modification of CUDA package sets by expert, out-of-tree users.
:::

:::{.note}
The `_cuda` attribute set fixed-point should be modified through its `extend` attribute.
:::

The `_cuda.fixups` attribute set is a mapping from package name (`pname`) to a `callPackage`-able expression which will be provided to `overrideAttrs` on the result of our generic builder.

::: {.important}
Fixups are chosen from `_cuda.fixups` by `pname`. As a result, packages with multiple versions (e.g., `cudnn`, `cudnn_8_9`, etc.) all share a single fixup function (i.e., `_cuda.fixups.cudnn`, which is `pkgs/development/cuda-modules/_cuda/fixups/cudnn.nix`).
:::

As an example, you can change the fixup function used for cuDNN for only the default CUDA package set with this overlay:

```nix
final: prev: {
  cudaPackages = prev.cudaPackages.override (prevArgs: {
    _cuda = prevArgs._cuda.extend (
      _: prevAttrs: {
        fixups = prevAttrs.fixups // {
          cudnn = <your-fixup-function>;
        };
      }
    );
  });
}
```

## Extending CUDA package sets {#cuda-extending-cuda-package-sets}

CUDA package sets are scopes, so they provide the usual `overrideScope` attribute for overriding package attributes (see the note about `cudaMajorMinorVersion` and `_cuda` in [Configuring CUDA package sets](#cuda-configuring-cuda-package-sets)).

Inspired by `pythonPackagesExtensions`, the `_cuda.extensions` attribute is a list of extensions applied to every version of the CUDA package set, allowing modification of all versions of the CUDA package set without having to know what they are or find a way to enumerate and modify them explicitly. As an example, disabling `cuda_compat` across all CUDA package sets can be accomplished with this overlay:

```nix
final: prev: {
  _cuda = prev._cuda.extend (
    _: prevAttrs: {
      extensions = prevAttrs.extensions ++ [ (_: _: { cuda_compat = null; }) ];
    }
  );
}
```

## Using cudaPackages {#cuda-using-cudapackages}

::: {.important}
A non-trivial amount of CUDA package discoverability and usability relies on the various setup hooks used by a CUDA package set. As a result, users will likely encounter issues trying to perform builds within a `devShell` without manually invoking phases.
:::

To use one or more CUDA packages in an expression, give the expression a `cudaPackages` parameter, and in case CUDA support is optional, add a `config` and `cudaSupport` parameter:

```nix
{
  config,
  cudaSupport ? config.cudaSupport,
  cudaPackages,
}:
<package-expression>
```

In your package's derivation arguments, it is _strongly_ recommended the following are set:

```nix
{
  __structuredAttrs = true;
  strictDeps = true;
}
```

These settings ensure that the CUDA setup hooks function as intended.

When using `callPackage`, you can choose to pass in a different variant, e.g. when a package requires a specific version of CUDA:

```nix
{
  mypkg = callPackage { cudaPackages = cudaPackages_12_2; };
}
```

::: {.important}
Overriding the CUDA package set used by a package may cause inconsistencies, since the override affects niether the direct nor transitive dependencies of the package. As a result, it is easy to end up with a package which uses a different CUDA package set than its dependencies. If at all possible, it is recommended to change the default CUDA package set globally, to ensure a consistent environment.
:::

## Using cudaPackages.pkgs {#cuda-using-cudapackages-pkgs}

Each CUDA package set has a `pkgs` attribute, which is a variant of Nixpkgs where the enclosing CUDA package set is made the default CUDA package set. This was done primarily to avoid package set leakage, wherein a member of a non-default CUDA package set has a (potentially transitive) dependency on a member of the default CUDA package set.

:::{.note}
Package set leakage is a common problem in Nixpkgs and is not limited to CUDA package sets.
:::

As an added benefit of `pkgs` being configured this way, building a package with a non-default version of CUDA is as simple as accessing an attribute. As an example, `cudaPackages_12_8.pkgs.opencv` provides OpenCV built against CUDA 12.8.

## Using pkgsCuda {#cuda-using-pkgscuda}

The `pkgsCuda` attribute set is a variant of Nixpkgs configured with `cudaSupport = true;` and `rocmSupport = false`. It is a convenient way access a variant of Nixpkgs configured with the default set of CUDA capabilities.

## Using pkgsForCudaArch {#cuda-using-pkgsforcudaarch}

The `pkgsForCudaArch` attribute set maps CUDA architectures (e.g., `sm_89` for Ada Lovelace or `sm_90a` for architecture-specific Hopper) to Nixpkgs variants configured to support exactly that architecture. As an example, `pkgsForCudaArch.sm_89` is a Nixpkgs variant extending `pkgs` and setting the following values in `config`:

```nix
{
  cudaSupport = true;
  cudaCapabilities = [ "8.9" ];
  cudaForwardCompat = false;
}
```

:::{.note}
In `pkgsForCudaArch`, the `cudaForwardCompat` option is set to `false` because exactly one CUDA architecture is supported by the corresponding Nixpkgs variant. Furthermore, some architectures, including architecture-specific feature sets like `sm_90a`, cannot be built with forward compatibility.
:::

:::{.important}
Not every version of CUDA supports every architecture!

To illustrate: support for Blackwell (e.g., `sm_100`) was only added in CUDA 12.8. Assume our Nixpkgs' default CUDA package set is to CUDA 12.6. Then the Nixpkgs variant available through `pkgsForCudaArch.sm_100` is useless, since packages like `pkgsForCudaArch.sm_100.opencv` and `pkgsForCudaArch.sm_100.python3Packages.torch` will try to generate code for `sm_100`, an architecture unknown to CUDA 12.6. In such a case, you should use `pkgsForCudaArch.sm_100.cudaPackages_12_8.pkgs` instead (see [Using cudaPackages.pkgs](#cuda-using-cudapackages-pkgs) for more details).
:::

The `pkgsForCudaArch` attribute set makes it possible to access packages built for a specific architecture without needing to manually call `pkgs.extend` and supply a new `config`. As an example, `pkgsForCudaArch.sm_89.python3Packages.torch` provides PyTorch built for Ada Lovelace GPUs.

## Adding a new CUDA release {#adding-a-new-cuda-release}

> **WARNING**
>
> This section of the docs is still very much in progress. Feedback is welcome in GitHub Issues tagging @NixOS/cuda-maintainers or on [Matrix](https://matrix.to/#/#cuda:nixos.org).

The CUDA Toolkit is a suite of CUDA libraries and software meant to provide a development environment for CUDA-accelerated applications. Until the release of CUDA 11.4, NVIDIA had only made the CUDA Toolkit available as a multi-gigabyte runfile installer, which we provide through the [`cudaPackages.cudatoolkit`](https://search.nixos.org/packages?channel=unstable&type=packages&query=cudaPackages.cudatoolkit) attribute. From CUDA 11.4 and onwards, NVIDIA has also provided CUDA redistributables (“CUDA-redist”): individually packaged CUDA Toolkit components meant to facilitate redistribution and inclusion in downstream projects. These packages are available in the [`cudaPackages`](https://search.nixos.org/packages?channel=unstable&type=packages&query=cudaPackages) package set.

All new projects should use the CUDA redistributables available in [`cudaPackages`](https://search.nixos.org/packages?channel=unstable&type=packages&query=cudaPackages) in place of [`cudaPackages.cudatoolkit`](https://search.nixos.org/packages?channel=unstable&type=packages&query=cudaPackages.cudatoolkit), as they are much easier to maintain and update.

### Updating CUDA redistributables {#updating-cuda-redistributables}

1. Go to NVIDIA's index of CUDA redistributables: <https://developer.download.nvidia.com/compute/cuda/redist/>
2. Make a note of the new version of CUDA available.
3. Run

   ```bash
   nix run github:connorbaker/cuda-redist-find-features -- \
      download-manifests \
      --log-level DEBUG \
      --version <newest CUDA version> \
      https://developer.download.nvidia.com/compute/cuda/redist \
      ./pkgs/development/cuda-modules/cuda/manifests
   ```

   This will download a copy of the manifest for the new version of CUDA.
4. Run

   ```bash
   nix run github:connorbaker/cuda-redist-find-features -- \
      process-manifests \
      --log-level DEBUG \
      --version <newest CUDA version> \
      https://developer.download.nvidia.com/compute/cuda/redist \
      ./pkgs/development/cuda-modules/cuda/manifests
   ```

   This will generate a `redistrib_features_<newest CUDA version>.json` file in the same directory as the manifest.
5. Update the `cudaVersionMap` attribute set in `pkgs/development/cuda-modules/cuda/extension.nix`.

### Updating cuTensor {#updating-cutensor}

1. Repeat the steps present in [Updating CUDA redistributables](#updating-cuda-redistributables) with the following changes:
   - Use the index of cuTensor redistributables: <https://developer.download.nvidia.com/compute/cutensor/redist>
   - Use the newest version of cuTensor available instead of the newest version of CUDA.
   - Use `pkgs/development/cuda-modules/cutensor/manifests` instead of `pkgs/development/cuda-modules/cuda/manifests`.
   - Skip the step of updating `cudaVersionMap` in `pkgs/development/cuda-modules/cuda/extension.nix`.

### Updating supported compilers and GPUs {#updating-supported-compilers-and-gpus}

1. Update `nvccCompatibilities` in `pkgs/development/cuda-modules/_cuda/db/bootstrap/nvcc.nix` to include the newest release of NVCC, as well as any newly supported host compilers.
2. Update `cudaCapabilityToInfo` in `pkgs/development/cuda-modules/_cuda/db/bootstrap/cuda.nix` to include any new GPUs supported by the new release of CUDA.

### Updating the CUDA Toolkit runfile installer {#updating-the-cuda-toolkit}

> **WARNING**
>
> While the CUDA Toolkit runfile installer is still available in Nixpkgs as the [`cudaPackages.cudatoolkit`](https://search.nixos.org/packages?channel=unstable&type=packages&query=cudaPackages.cudatoolkit) attribute, its use is not recommended and should it be considered deprecated. Please migrate to the CUDA redistributables provided by the [`cudaPackages`](https://search.nixos.org/packages?channel=unstable&type=packages&query=cudaPackages) package set.
>
> To ensure packages relying on the CUDA Toolkit runfile installer continue to build, it will continue to be updated until a migration path is available.

1. Go to NVIDIA's CUDA Toolkit runfile installer download page: <https://developer.nvidia.com/cuda-downloads>
2. Select the appropriate OS, architecture, distribution, and version, and installer type.

   - For example: Linux, x86_64, Ubuntu, 22.04, runfile (local)
   - NOTE: Typically, we use the Ubuntu runfile. It is unclear if the runfile for other distributions will work.

3. Take the link provided by the installer instructions on the webpage after selecting the installer type and get its hash by running:

   ```bash
   nix store prefetch-file --hash-type sha256 <link>
   ```

4. Update `pkgs/development/cuda-modules/cudatoolkit/releases.nix` to include the release.

### Updating the CUDA package set {#updating-the-cuda-package-set}

1. Include a new `cudaPackages_<major>_<minor>` package set in `pkgs/top-level/all-packages.nix`.

   - NOTE: Changing the default CUDA package set should occur in a separate PR, allowing time for additional testing.

2. Successfully build the closure of the new package set, updating `pkgs/development/cuda-modules/cuda/overrides.nix` as needed. Below are some common failures:

| Unable to ...  | During ...                       | Reason                                           | Solution                   | Note                                                         |
| -------------- | -------------------------------- | ------------------------------------------------ | -------------------------- | ------------------------------------------------------------ |
| Find headers   | `configurePhase` or `buildPhase` | Missing dependency on a `dev` output             | Add the missing dependency | The `dev` output typically contain the headers               |
| Find libraries | `configurePhase`                 | Missing dependency on a `dev` output             | Add the missing dependency | The `dev` output typically contain CMake configuration files |
| Find libraries | `buildPhase` or `patchelf`       | Missing dependency on a `lib` or `static` output | Add the missing dependency | The `lib` or `static` output typically contain the libraries |

In the scenario you are unable to run the resulting binary: this is arguably the most complicated as it could be any combination of the previous reasons. This type of failure typically occurs when a library attempts to load or open a library it depends on that it does not declare in its `DT_NEEDED` section. As a first step, ensure that dependencies are patched with [`autoAddDriverRunpath`](https://search.nixos.org/packages?channel=unstable&type=packages&query=autoAddDriverRunpath). Failing that, try running the application with [`nixGL`](https://github.com/guibou/nixGL) or a similar wrapper tool. If that works, it likely means that the application is attempting to load a library that is not in the `RPATH` or `RUNPATH` of the binary.

## Running Docker or Podman containers with CUDA support {#cuda-docker-podman}

It is possible to run Docker or Podman containers with CUDA support. The recommended mechanism to perform this task is to use the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html).

The NVIDIA Container Toolkit can be enabled in NixOS like follows:

```nix
{
  hardware.nvidia-container-toolkit.enable = true;
}
```

This will automatically enable a service that generates a CDI specification (located at `/var/run/cdi/nvidia-container-toolkit.json`) based on the auto-detected hardware of your machine. You can check this service by running:

```ShellSession
$ systemctl status nvidia-container-toolkit-cdi-generator.service
```

::: {.note}
Depending on what settings you had already enabled in your system, you might need to restart your machine in order for the NVIDIA Container Toolkit to generate a valid CDI specification for your machine.
:::

Once that a valid CDI specification has been generated for your machine on boot time, both Podman and Docker (> 25) will use this spec if you provide them with the `--device` flag:

```ShellSession
$ podman run --rm -it --device=nvidia.com/gpu=all ubuntu:latest nvidia-smi -L
GPU 0: NVIDIA GeForce RTX 4090 (UUID: <REDACTED>)
GPU 1: NVIDIA GeForce RTX 2080 SUPER (UUID: <REDACTED>)
```

```ShellSession
$ docker run --rm -it --device=nvidia.com/gpu=all ubuntu:latest nvidia-smi -L
GPU 0: NVIDIA GeForce RTX 4090 (UUID: <REDACTED>)
GPU 1: NVIDIA GeForce RTX 2080 SUPER (UUID: <REDACTED>)
```

You can check all the identifiers that have been generated for your auto-detected hardware by checking the contents of the `/var/run/cdi/nvidia-container-toolkit.json` file:

```ShellSession
$ nix run nixpkgs#jq -- -r '.devices[].name' < /var/run/cdi/nvidia-container-toolkit.json
0
1
all
```

### Specifying what devices to expose to the container {#specifying-what-devices-to-expose-to-the-container}

You can choose what devices are exposed to your containers by using the identifier on the generated CDI specification. Like follows:

```ShellSession
$ podman run --rm -it --device=nvidia.com/gpu=0 ubuntu:latest nvidia-smi -L
GPU 0: NVIDIA GeForce RTX 4090 (UUID: <REDACTED>)
```

You can repeat the `--device` argument as many times as necessary if you have multiple GPU's and you want to pick up which ones to expose to the container:

```ShellSession
$ podman run --rm -it --device=nvidia.com/gpu=0 --device=nvidia.com/gpu=1 ubuntu:latest nvidia-smi -L
GPU 0: NVIDIA GeForce RTX 4090 (UUID: <REDACTED>)
GPU 1: NVIDIA GeForce RTX 2080 SUPER (UUID: <REDACTED>)
```

::: {.note}
By default, the NVIDIA Container Toolkit will use the GPU index to identify specific devices. You can change the way to identify what devices to expose by using the `hardware.nvidia-container-toolkit.device-name-strategy` NixOS attribute.
:::

### Using docker-compose {#using-docker-compose}

It's possible to expose GPU's to a `docker-compose` environment as well. With a `docker-compose.yaml` file like follows:

```yaml
services:
  some-service:
    image: ubuntu:latest
    command: sleep infinity
    deploy:
      resources:
        reservations:
          devices:
          - driver: cdi
            device_ids:
            - nvidia.com/gpu=all
```

In the same manner, you can pick specific devices that will be exposed to the container:

```yaml
services:
  some-service:
    image: ubuntu:latest
    command: sleep infinity
    deploy:
      resources:
        reservations:
          devices:
          - driver: cdi
            device_ids:
            - nvidia.com/gpu=0
            - nvidia.com/gpu=1
```
