# GNU-make-based build framework

## Features

Modular, multi core, multi target (here called flavor), building of library trees and apps.

The base packages have been developed during my time at the Freescale Multi Media IP team,
with a focus on complex firmware builds for deeply embedded heterogeneous cores.

## Status

Currently I am puzzling together the pieces that have been open sourced in 2016 by Freescale / NXP

There are 3 examples that are working already

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

- `multicore` shows how to create build classes for heterogeneous cores. here we are building
  2 apps simultanously from partially overlapping and partially individual sources. one could
  be an embedded firmware, and the other one the driver on the host. In this example gcc is
  used for both "cores". Its just a demo, not of real practical use.
