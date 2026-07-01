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

#set text(size: 20pt)

#set page(paper: "presentation-16-9", margin: 2cm, footer: context [
  #set text(size: 12pt)
  #set align(horizon)
  #date.display("[month repr:long] [day padding:none], [year]")
  #h(1fr)
  #toolbox.slide-number / #toolbox.last-slide-number
])

#slide[
  = Effortlessly reproducible experiments:
  == _NixOS Compose and Kadeploy on #strike[SLICES] Grid'5000_

  #line(length: 100%)

  === École d'été SLICES-FR 2026

  #v(1fr)

  #author.join(", ")

  `<first>.<last>@inria.fr`
]

#slide[
  == Grid'5000


]

#slide[
  == Kadeploy


]

#slide[
  == Nix/NixOS
]

#slide[
  == NixOS Compose


]

#slide[
  == Kadeploy: machine reservation with OAR3
]

#slide[
  == Kadeploy: BYO-configuration

  // talk a bit about nixos modules
]

#slide[
  == Kadeploy: building your custom image


]

#slide[
  == Kadeploy: deploy to real machines
]

#slide[
  == NixOS Compose
]
