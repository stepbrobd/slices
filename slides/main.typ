#import "@preview/polylux:0.4.0": *

#let title = "Effortlessly reproducible experiments: NixOS Compose and Kadeploy on SLICES"
#let author = (
  "Yifei Sun",
  "Quentin Guilloteau",
  "Colin Regal-Mezin",
  "Olivier Richard",
)
#let date = datetime(year: 2026, month: 7, day: 9)

#set document(title: title, author: author, date: date)

// ---- palette ----
#let nix-blue = rgb("#5277c3")
#let nix-light = rgb("#7ebae4")
#let nxc-red = rgb("#e42313")
#let ink = rgb("#2b2b2b")
#let muted = rgb("#6b6b6b")
#let hairline = rgb("#d8d8de")
#let panel = rgb("#f4f4f7")

// ---- verdict marks (for comparison table) ----
#let yes = text(fill: rgb("#2e7d32"), weight: "bold")[#sym.checkmark]
#let no = text(fill: rgb("#c62828"), weight: "bold")[#sym.times]
#let meh = text(fill: rgb("#e08a00"), weight: "bold")[\~]

// ---- text + heading styles ----
#set text(size: 20pt, fill: ink)
#set par(justify: false, leading: 0.7em)
#show heading.where(level: 1): set text(size: 34pt, fill: nix-blue)
#show heading.where(level: 2): set text(size: 30pt, fill: nix-blue)
#show heading.where(level: 3): set text(
  size: 22pt,
  fill: muted,
  weight: "regular",
)
#show link: set text(fill: nix-blue)
#show raw.where(block: true): it => block(
  fill: panel,
  inset: 12pt,
  radius: 6pt,
  width: 100%,
  text(size: 15pt, it),
)
#show raw.where(block: false): it => box(
  fill: panel,
  inset: (x: 3pt),
  outset: (y: 3pt),
  radius: 3pt,
  text(size: 0.9em, it),
)

// ---- small helpers ----
#let eyebrow(txt, color: nix-blue) = text(
  size: 14pt,
  fill: color,
  weight: "bold",
)[#upper(txt)]
#let pill(txt, fg: white, bg: nix-blue) = box(
  fill: bg,
  inset: (x: 9pt, y: 4pt),
  radius: 999pt,
  text(size: 14pt, fill: fg, weight: "bold", txt),
)
#let arrow = text(size: 28pt, fill: muted)[#sym.arrow.r]
// a rounded node for the hand-rolled flow diagrams
#let node(head, sub, accent: nix-blue) = box(
  fill: white,
  stroke: 1.5pt + accent,
  radius: 8pt,
  inset: 12pt,
  width: 200pt,
)[
  #text(fill: accent, weight: "bold", size: 20pt, head) \
  #text(size: 15pt, fill: muted, sub)
]

#set page(paper: "presentation-16-9", margin: 2cm, footer: context [
  #set text(size: 12pt, fill: muted)
  #set align(horizon)
  #date.display("[month repr:long] [day padding:none], [year]")
  #h(1fr)
  #toolbox.slide-number / #toolbox.last-slide-number
])

// =====================================================================
// 1 - Title
// =====================================================================
#slide[
  #place(top + right, dx: 1cm, dy: -1cm, image("figs/nix.png", height: 3cm))

  = Effortlessly reproducible experiments:
  == _NixOS Compose and Kadeploy on #strike[SLICES] Grid'5000_

  #line(length: 100%, stroke: hairline)

  === SLICES-FR 2026 Summer School

  #v(1fr)

  #text(size: 18pt, author.join(", "))

  #text(size: 16pt, fill: muted, `<first>.<last>@inria.fr`)
]

// =====================================================================
// 2 - Roadmap
// =====================================================================
#slide[
  == Roadmap

  #grid(
    columns: (1fr, 1fr),
    gutter: 30pt,
    [
      #pill("~30 min", bg: nix-blue) *Mini-lecture + demo*
      - The reproducibility problem
      - Grid'5000, Kadeploy
      - What is Nix (DSL and FPM) and NixOS
      - Custom Kadeploy image vs NixOS Compose
    ],
    [
      #pill("~1 h", bg: nxc-red) *Hands-on*
      - Get a tutorial account
      - Reserve nodes with OAR
      - Build & deploy your own NixOS image
      - Run the same config with `nxc`
      - Open Q&A
    ],
  )

  #v(1fr)
  #align(center, text(size: 18pt, fill: muted)[
    Your takeaway: be able to *describe*, *build*, and *deploy* NixOS (or other OS) on G5K platforms
  ])
]

// =====================================================================
// 3 - The reproducibility problem
// =====================================================================
#slide[
  == The reproducibility problem

  What's "reproducible" (feat. ACM):

  #v(6pt)
  #grid(
    columns: (auto, 1fr),
    gutter: 14pt,
    row-gutter: 10pt,
    // TODO: check
    pill("1", bg: nix-blue),
    [*Reproducibility*: rerun the *exact* same experiment],

    pill("2", bg: nix-blue),
    [*Replicability*: rerun with different *parameters*],

    pill("3", bg: nix-blue),
    [*Repeatability*: rerun in a different *environment*],
  )

  #v(10pt)
  #align(
    center,
  )[#text(fill: nix-blue)[#sym.arrow.r] *Share the environment, plus how to rebuild and modify it.*]

  #v(10pt)
  #line(length: 100%, stroke: hairline)
  Usual tools stop short:
  - *Containers*: the `Dockerfile` still runs `apt update` / `curl` #sym.arrow.r drifts
  - *Environment modules*: cluster-specific, hard to modify or move
]

// =====================================================================
// 4 - The friction: laptop <-> cluster
// =====================================================================
#slide[
  == Two worlds, one experiment

  #align(center, image("figs/reduce_friction.png", height: 68%))

  #align(center, text(size: 18pt, fill: muted)[
    The gap between *"works on my laptop"* and *"runs on N nodes"* is where reproducibility dies.
  ])
]

// =====================================================================
// 5 - What good looks like
// =====================================================================
#slide[
  == What we actually want

  #grid(
    columns: (1fr, 1.05fr),
    gutter: 24pt,
    align: horizon,
    image("figs/tri-way-compromise.png", width: 100%),
    [
      - *Reproducible*: same inputs
      - *Secure*: only the declared inputs get baked in
      - *Ephemeral*: spin up, run, and tear down, leaving the node clean

      #v(8pt)
      Both paths in this talk (the *custom Kadeploy image* and *NixOS Compose*) aim at this sweet spot.
    ],
  )
]

// =====================================================================
// 6 - Grid'5000
// =====================================================================
#slide[
  == Grid'5000

  Testbed (available nationwide) for *experiment-driven* computer science.

  - *Bare metal*: full *root* on the physical node
  - *Reconfigurable*: deploy your *own* operating system on the nodes
  - Built around three tools you'll use today:

  #v(14pt)
  #align(center, stack(
    dir: ltr,
    spacing: 16pt,
    node("OAR", "compute nodes reservation"),
    arrow,
    node("Kadeploy", "bring your own OS image"),
  ))
]

// =====================================================================
// 7 - Kadeploy
// =====================================================================
#slide[
  == Kadeploy: provision a whole OS

  #grid(
    columns: (1.15fr, 1fr),
    gutter: 24pt,
    [
      Give it a *system image*. It PXE-boots your nodes, writes the image to
      disk, and reboots them into *your* OS.

      - User managed environment: kernel, services, packages, etc.
    ],
    [
      #align(center, box(fill: panel, radius: 8pt, inset: 14pt, width: 100%)[
        #stack(
          spacing: 10pt,
          node("image", "one reproducible artifact", accent: nix-blue),
          text(size: 24pt, fill: muted)[#sym.arrow.b],
          text(size: 16pt)[N identical nodes],
        )
      ])
    ],
  )

  #v(6pt)
  #align(center)[#text(fill: nix-blue, weight: "bold")[
    The image is the unit of reproducibility #sym.arrow.r Nix ;)
  ]]
]

// =====================================================================
// 8 - Nix: the four things
// =====================================================================
#slide[
  == "Nix" is:

  #grid(
    columns: (1fr, 1fr),
    gutter: 18pt,
    row-gutter: 16pt,
    box(stroke: 1.2pt + hairline, radius: 8pt, inset: 12pt, width: 100%)[
      #text(fill: nix-blue, weight: "bold")[Nix: the language] \
      #text(
        size: 16pt,
        fill: muted,
      )[a lazy, functional DSL (#sym.approx JSON + #sym.lambda)]
    ],
    box(stroke: 1.2pt + hairline, radius: 8pt, inset: 12pt, width: 100%)[
      #text(fill: nix-blue, weight: "bold")[Nix: the package manager] \
      #text(size: 16pt, fill: muted)[builds packages in sandbox]
    ],

    box(stroke: 1.2pt + hairline, radius: 8pt, inset: 12pt, width: 100%)[
      #text(fill: nix-blue, weight: "bold")[nixpkgs] \
      #text(
        size: 16pt,
        fill: muted,
      )[monorepo of build recipes + binary cache]
    ],
    box(stroke: 1.2pt + hairline, radius: 8pt, inset: 12pt, width: 100%)[
      #text(fill: nix-blue, weight: "bold")[NixOS] \
      #text(
        size: 16pt,
        fill: muted,
      )[Linux distro]
    ],
  )

  #v(10pt)
  #align(center)[#text(
    fill: nix-blue,
  )[Pin the nixpkgs commit #sym.arrow.r everyone rebuilds from the same environment.]]
]

// =====================================================================
// 9 - Nix in one idea
// =====================================================================
#slide[
  == Nix in one idea

  #grid(
    columns: (1fr, 1fr),
    gutter: 24pt,
    align: horizon,
    [
      A derivation is a *function of its inputs*.

      - *Realization of the derivation* (build) run sealed off from the network and any ambient state
      - Inputs are *content-addressed* into `/nix/store`
      - Same inputs #sym.arrow.r same output (usually)

      #v(6pt)
      #text(
        fill: nix-blue,
        weight: "bold",
      )[Pinning inputs = time-travel to an exact environment.]
    ],
    image("figs/snapshots.png", width: 100%),
  )
]

// =====================================================================
// 10 - NixOS = declarative whole system
// =====================================================================
#slide[
  == NixOS

  Kernel, services, packages, and users live in declarative files.

  This *is* your experiment environment:

  ```nix
  { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ vim git ];

    services.openssh.enable = true;

    nix.settings.substituters = [ "https://cache.ysun.co" ];
  }
  ```

  #text(size: 17pt, fill: muted)[
    Compose these *modules* to describe exactly the machine your experiment needs.
  ]
]

// =====================================================================
// 11 - The fork in the road (decision table)
// =====================================================================
#slide[
  == Onto the nodes

  #v(4pt)
  #set text(size: 17pt)
  #table(
    columns: (1.5fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    stroke: 0.5pt + hairline,
    inset: 9pt,
    fill: (_, row) => if row == 0 { panel },
    table.header([], [*Official image*], [*Custom image*], [*NixOS Compose*]),
    [Environment as code], no, yes, yes,
    [Test locally first],
    no,
    meh,
    [#yes #text(size: 13pt, fill: muted)[docker/vm]],

    [Multi-node support], meh, meh, [#yes built-in],
    [Needs NFS store on g5k], no, no, [#meh depends on flavor],
    [Rebuild after deploy?],
    [likely],
    [no need but you can],
    [depends on flavor],

    [Best for], [quick start], [production runs], [iterating on setups],
  )
]

// =====================================================================
// 12 - Path A header / modules
// =====================================================================
#slide[
  #eyebrow("Path A: Kadeploy", color: nix-blue)
  == Bring your own configuration

  A NixOS *module* is function returning system options, which you compose:

  ```nix
  # modules/base.nix (shared across every image)
  { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ vim nushell ];
    services.nginx.enable = true;
    services.postgresql.enable = true;
    services.prometheus.exporters.postgres.enable = true;
  }
  ```

  - Keep reusable pieces (`base`, networking, experiments) as small modules
  - `nixpkgs` comes with a lot of tested modules, add what your experiment needs
]

// =====================================================================
// 13 - Path A: build the image
// =====================================================================
#slide[
  #eyebrow("Path A: Kadeploy", color: nix-blue)
  == Build your custom image

  Your config + `nixos-g5k-image` #sym.arrow.r a Kadeploy-ready tarball:

  ```sh
  git clone https://github.com/stepbrobd/slices
  cd slices
  nix build .#kadeploy
  ```

  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      *What comes out*
      - a `g5k-image` closure, ready for `kaenv`
      - fully described by your flake
    ],
    [
      *Note*
      - Consider using the cache (see readme)
      - Ask if encounter problems
    ],
  )
]

// =====================================================================
// 14 - Path A: reserve nodes
// =====================================================================
#slide[
  #eyebrow("Path A: Kadeploy", color: nix-blue)
  == Reserve nodes with OAR

  Ask OAR for a compute node with the *deploy* job type:

  ```sh
  oarsub -I -t deploy -l host=1,walltime=1:00:00
  ```

  - `-I` #sym.arrow.r interactive shell on the frontend once granted
  - `-t deploy` #sym.arrow.r you may reprovision the OS (required for Kadeploy)
  - `-l host=1,walltime=...` #sym.arrow.r how many nodes, for how long

  #v(6pt)
  #text(size: 17pt, fill: muted)[`$OAR_NODEFILE` now lists the nodes you own]
]

// =====================================================================
// 15 - Path A: deploy
// =====================================================================
#slide[
  #eyebrow("Path A: Kadeploy", color: nix-blue)
  == Deploy to real machines

  Push the built image to the site frontend:

  ```sh
  kadeploy3 -a ~/g5k-image/nixos-x86_64-linux.yaml -f $OAR_NODEFILE # -M
  ```

  - `-a` #sym.arrow.r your image (environment description)
  - `-f` #sym.arrow.r the nodes from your OAR reservation (can be ignored)
  - `-M` #sym.arrow.r in case of multi-node reservation

  #v(8pt)
  #align(center, text(fill: nix-blue, weight: "bold")[
    #sym.arrow.r Kadeploy mini OS
    #sym.arrow.r disk formatting
    #sym.arrow.r kexec
    #sym.arrow.r post install (network setup, hardware hacks, etc.)
    #sym.arrow.r your OS
  ])
]

// =====================================================================
// 16 - Path B: NixOS Compose intro
// =====================================================================
#slide[
  #eyebrow("Path B: NixOS Compose", color: nxc-red)
  == One definition, many flavors

  Describe the *distributed* environment *once*. `nxc` builds it for wherever
  you're running:

  #v(12pt)
  #align(center, stack(
    dir: ltr,
    spacing: 18pt,
    node("composition.nix", "roles, services, relationships", accent: nxc-red),
    arrow,
    grid(
      columns: (auto, auto),
      align: (right + horizon, left + horizon),
      column-gutter: 12pt,
      row-gutter: 12pt,
      text(size: 15pt, fill: muted)[*local*],
      stack(
        dir: ltr,
        spacing: 8pt,
        pill("docker", bg: nix-blue),
        pill("nspawn", bg: nix-blue),
        pill("vm", bg: nix-blue),
        pill("vm-ramdisk", bg: nix-blue),
      ),

      text(size: 15pt, fill: muted)[*Grid'5000*],
      stack(
        dir: ltr,
        spacing: 8pt,
        pill("g5k-image", bg: nxc-red),
        pill("g5k-nfs-store", bg: nxc-red),
        pill("g5k-ramdisk", bg: nxc-red),
      ),
    ),
  ))

  #v(12pt)
  #align(center, text(size: 17pt, fill: muted)[
    One flavor per target: containers & VMs to *iterate locally*, `g5k-*` to *deploy*.
  ])
]

// =====================================================================
// 17 - Path B: vm flavor locally
// =====================================================================
#slide[
  #eyebrow("Path B: NixOS Compose", color: nxc-red)
  == Try it locally: the `vm` flavor

  Iterate on your laptop before touching the cluster:

  ```sh
  nxc -d . build -N '.#legacyPackages.x86_64-linux.nxc' \
      -f vm -C composition::vm nxc/default.nix
  nxc -d . start       # boot the composition
  nxc -d . connect     # ssh into the roles
  ```

  - Same `composition.nix` you'll deploy to g5k
  - Fast feedback loop: iterate on your laptop, saving reserved nodes for the real run
  - `docker` flavor is even lighter for pure-software setups
]

// =====================================================================
// 18 - Path B: on g5k
// =====================================================================
#slide[
  #eyebrow("Path B: NixOS Compose", color: nxc-red)
  == Same config, now on Grid'5000

  Swap the flavor, reserve, and deploy, all from one composition:

  ```sh
  nxc -d . build -N '.#legacyPackages.x86_64-linux.nxc' \
      -f g5k-image -C composition::g5k-image nxc/default.nix
  oarsub -I -t deploy -l host=1,walltime=1:00:00
  nxc -d . start -m $OAR_NODEFILE  # kadeploy under the hood
  nxc -d . connect                 # into the deployed roles
  ```

  #text(size: 17pt, fill: muted)[
    `nxc` invokes Kadeploy for you
  ]
]

// =====================================================================
// 19 - Path B: caveats
// =====================================================================
#slide[
  #eyebrow("Path B: NixOS Compose", color: nxc-red)
  == Know the trade-offs

  #grid(
    columns: (1fr, 1fr),
    gutter: 24pt,
    align: horizon,
    [
      - Needs an *NFS store* on g5k to share the closure across nodes
      - Pinned to a nixpkgs release, with *breaking changes* across versions (e.g. systemd)
      - Powerful for *distributed* experiments, though heavier than a single custom image

      #v(6pt)
      #text(
        fill: nxc-red,
        weight: "bold",
      )[Match the `nxc` release to your nixpkgs (currently outdated).]
    ],
    image("figs/linked_to_anecosystem.png", width: 100%),
  )
]

// =====================================================================
// 20 - Demo
// =====================================================================
#slide[
  #align(center + horizon)[
    #image("figs/nxc.png", height: 2.2cm)
    #v(10pt)
    #text(size: 40pt, fill: nix-blue, weight: "bold")[Live demo]
    #v(6pt)
    #text(size: 20pt, fill: muted)[
      build #sym.arrow.r reserve #sym.arrow.r deploy #sym.arrow.r connect
    ]
  ]
]

// =====================================================================
// 21 - Hands-on + resources
// =====================================================================
#slide[
  == Your turn

  `https://github.com/stepbrobd/slices`

  #grid(
    columns: (1fr, 1fr),
    gutter: 30pt,
    [
      *In the next hour*
      + Grab a tutorial account
      + Reserve a node with OAR
      + Build & deploy a NixOS image
      + Re-run it with `nxc`

      #v(4pt)
      Everything is *pre-cached*, so ask us anything.
    ],
    [
      *Resources*
      - Repo & modules: _this session's repo_
      - `nixos-compose`: #link("https://github.com/oar-team/nixos-compose")[github.com/oar-team/nixos-compose]
      - `nixos-g5k-image`: #link("https://github.com/oar-team/nixos-g5k-image")[github.com/oar-team/nixos-g5k-image]
      - nxc tutorial: #link("https://nixos-compose.gitlabpages.inria.fr/tuto-nxc/")[tuto-nxc]
    ],
  )

  #v(1fr)
  #align(center, text(
    size: 22pt,
    fill: nix-blue,
    weight: "bold",
  )[Questions?])
  #align(center, text(size: 15pt, fill: muted, author.join(", ")))
]
