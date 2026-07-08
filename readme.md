# SLICES-FR

Companion repository for SLICES-FR 2026 Summer School workshop session.

It shows two ways to get NixOS environment onto Grid'5000 nodes, both built from
the same shared configuration ([`modules/base.nix`](modules/base.nix)):

- **Path A (Kadeploy image)**: build a Kadeploy NixOS system image with
  [nixos-g5k-image](https://github.com/oar-team/nixos-g5k-image) and deploy it
  yourself with `kadeploy3`.
- **Path B (NixOS Compose)**: describe a composition once with
  [nixos-compose](https://github.com/oar-team/nixos-compose), iterate on it
  locally in VMs, then deploy the same description to Grid'5000 (`nxc` runs
  Kadeploy for you).

## Prerequisites

- A Grid'5000 account with SSH access set up
  ([getting started](https://www.grid5000.fr/w/Getting_Started)). The commands
  below assume the recommended SSH aliases, e.g. `ssh grenoble.g5k`.
- [Nix](https://nixos.org/download/) with flakes enabled on the machine where
  you build (your laptop for Path A, or wherever you run `nxc` for Path B).
- This repository:

  ```sh
  git clone https://github.com/stepbrobd/slices
  cd slices
  ```

Everything in this repo is pre-built and cached at `https://cache.ysun.co`
(declared in [`flake.nix`](flake.nix)'s `nixConfig`). Answer _yes_ when Nix asks
whether to use the flake's substituters, or pass `--accept-flake-config` to skip
the prompt. Builds then become downloads.

## Repository layout

| Path               | Purpose                                                                 |
| ------------------ | ----------------------------------------------------------------------- |
| `modules/base.nix` | Shared NixOS module (packages, nix settings, caches) used by both paths |
| `kadeploy/`        | Path A: Kadeploy image built via `nixos-g5k-image`                      |
| `nxc/`             | Path B: NixOS Compose composition                                       |
| `slides/`          | The talk                                                                |

## Path A: custom Kadeploy image

### 1. Build the image

On your laptop (or any machine with Nix):

```sh
nix build .#kadeploy --accept-flake-config
```

`result/` now contains the three deployment artifacts:

- `nixos-x86_64-linux.yaml`: the Kadeploy _environment description_
- `nixos-x86_64-linux.tar.xz`: the system tarball (the OS itself)
- `g5k-image-info.json`: kernel/initrd/init metadata

### 2. Copy it to the site frontend

The YAML references the tarball as `g5k-image/nixos-x86_64-linux.tar.xz`
relative to where `kadeploy3` runs, so copy the artifacts into a directory named
`g5k-image` in your frontend home. The `-L` flag dereferences the Nix store
symlinks. Adjust the site to yours:

```sh
rsync -avL result/ grenoble.g5k:g5k-image/
```

### 3. Reserve nodes with OAR

On the frontend, ask for nodes with the _deploy_ job type (required to
reprovision the OS):

```sh
ssh grenoble.g5k
oarsub -I -t deploy -l host=1,walltime=1:00:00
```

`-I` drops you into an interactive shell once the job starts, and
`$OAR_NODEFILE` lists the hostnames you were granted.

### 4. Deploy with Kadeploy

From your home directory on the frontend:

```sh
kadeploy3 -a ~/g5k-image/nixos-x86_64-linux.yaml -f $OAR_NODEFILE
```

Kadeploy PXE-boots the nodes into a mini OS, writes the image to disk, runs the
Grid'5000 post-install (network, hardware quirks), and reboots into _your_
NixOS.

### 5. Use the nodes

```sh
ssh root@$(head -n 1 $OAR_NODEFILE)
```

You have root on bare metal: the whole environment is exactly what
`modules/base.nix` declares.

### 6. Iterate / clean up

- To change the environment: edit `modules/base.nix` (or add modules in
  `kadeploy/default.nix`), then repeat steps 1 to 4.
- When done, exit the `oarsub` shell (or `oardel <job_id>`) to release the
  nodes. They are reimaged before the next user, so each deployment starts from
  a clean slate.

## Path B: NixOS Compose

The composition lives in [`nxc/default.nix`](nxc/default.nix) and is exposed
through the flake at `.#legacyPackages.x86_64-linux.nxc`, one attribute per
`composition::<flavor>` pair. This repo skips the usual `nxc init` scaffolding,
so every `nxc` command takes `-d .` to treat the repo root as its environment
directory (build state lands in `./build/`), and the build command names the
composition file and flake attribute explicitly.

Enter the dev shell first. It provides `nxc` itself plus `qemu` and `vde2` for
the local VM flavor:

```sh
nix develop --accept-flake-config
```

### 1. Iterate locally with the `vm` flavor

```sh
nxc -d . build -N '.#legacyPackages.x86_64-linux.nxc' \
    -f vm -C composition::vm nxc/default.nix
nxc -d . start       # boot the composition in local VMs
nxc -d . connect     # ssh into a role (tab per node)
nxc -d . stop        # tear the VMs down
```

Flag cheat-sheet:

- `-d .`: environment directory (state goes to `./build/`)
- `-N`: flake attribute _namespace_ the compositions live under
- `-f`: flavor to build (`nxc -d . build ... -F` lists available flavors)
- `-C composition::vm`: which `composition::flavor` pair to build (`-L` lists
  the valid combinations)

`nxc start`, `connect`, and `stop` pick up the most recent build under
`./build/`, so they work without extra flags. Other local flavors (`docker`,
`nspawn`, `vm-ramdisk`) work the same way, just swap the `-f` and `-C` values.

### 2. Deploy the same composition to Grid'5000

Run these where both `nxc` and the Grid'5000 tools are available, which in
practice means the site frontend. Everything is pre-cached for the summer
school, so ask us if Nix setup on the frontend gives you trouble:

```sh
# build the deployable image flavor
nxc -d . build -N '.#legacyPackages.x86_64-linux.nxc' \
    -f g5k-image -C composition::g5k-image nxc/default.nix

# reserve nodes (deploy job type, one host per role)
oarsub -I -t deploy -l host=1,walltime=1:00:00

# deploy (nxc runs kadeploy3 under the hood) and connect
nxc -d . start -m $OAR_NODEFILE
nxc -d . connect
```

Exactly the same `nxc/default.nix` you tested locally, only the flavor changed.
Note the `g5k-image` flavor needs the Nix store available on the nodes. The
`g5k-ramdisk` flavor boots all-in-memory instead (faster to redeploy, needs
enough RAM).

### 3. Grow the composition

The current composition is a single-role stub. Add roles (= nodes) in
[`nxc/default.nix`](nxc/default.nix):

```nix
composition.nodes = {
  server = { services.nginx.enable = true; };
  client = { };
};
```

Rebuild, and `nxc -d . connect server` drops you into that role, locally in a VM
or on a real Grid'5000 node, depending on the flavor you built.

## Resources

- [nixos-compose](https://github.com/oar-team/nixos-compose) and the
  [nxc tutorial](https://nixos-compose.gitlabpages.inria.fr/tuto-nxc/)
- [nixos-g5k-image](https://github.com/oar-team/nixos-g5k-image)
- [Grid'5000 Getting Started](https://www.grid5000.fr/w/Getting_Started)
