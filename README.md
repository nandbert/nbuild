# GNU-make-based build framework

## Features

Modular, multi core, multi target (here called flavor), building of library trees and apps.

The base packages packages have been developed during my time at the Freescale Multi Media IP team,
with a focus on complex firmware builds for deeply embedded heterogeneous cores.

## Status

Currently I am puzzling together the pieces that have been open sourced in 2016 by Freescale / NXP

There are 2 examples that are working already

- `simple` contains the simplest possible Makefile for a Linux executable with one library
  ````
  cd examples/app/simple
  make run
  ````
  should do something. The `Makefile` contains some explanations.

- `multiflavor` shows how to build objects in different "flavors" from the same sources.
  Currently only a single flavor `o-linux` exists, new ones like e.g. `o-linux-debug` can be easily
  derived later.
  ````
  cd examples/app/multiflavor/o-linux
  make run
  ````
  should also work, here the settings and comments are in `examples/app/multiflavor/BUILD.mk`.
