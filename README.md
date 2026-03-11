![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Verilog Project Template

- [Read the documentation for project](docs/info.md)

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Set up your Verilog project

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an existing Tiny Tapeout project, check out our [online info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Adapt the testbench to your design. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [LibreLane](https://www.zerotoasiccourse.com/terminology/librelane/).

## Enable GitHub actions to build the results page

- [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
  - Bluesky [@tinytapeout.com](https://bsky.app/profile/tinytapeout.com)

# Project Specification: Simon

## How it works

This is an implementation for a basic memory game using buttons and lights. The game operates as follows:
- On startup, all of the LEDS are on. This indicates the chip is on and in its initialization state.
- When any button is pressed, a pseudorandom LED is lit up. It will stay lit until any button is pressed.
- The LEDs turn off and the game waits for player input. If the correct button is pressed, the LEDs show a new pattern with one new light prepended to the start.
- This cycle continues until the player loses, to a maximum of 16 cycles.
- Playing beyond 16 cycles is undefined behavior, but from testing seems to simply result in a loss.

## How to test

In hardware the chip would be tested by just playing the game. 
To test in simulation, I created a simple python script that just plays the game normally, then tested cases where the player wins and loses at different points in the game. Simply run that python script to observe the game in practice.

Simulation notes:
- It is known that pressing multiple buttons at the same time always counts as the correct input. However, this is not practically possible for a real player given any reasonable clock speed.
- The behavior for rapid changes in input is undefined, but again, it is unlikely a human player could change the button presses at a rate faster than 25 thousand times per second
- Human players are also unlikely to have the precision to manipulate the pseudo-random number generator, so a simple counter is probably enough.

## External hardware

This project assumes the usage of some PMOD buttons and LED outputs for the gameplay. The input and output signals are active-high, but that can be changed fairly easily by changing the code to invert the btnX\_UNSAFE and LedX signals.

All inputs are buffered to ensure synchronicity and prevent metastability, and all of the logic operates on positive edge detection, so the latency and button held time should not matter.
