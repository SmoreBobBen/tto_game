<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is an implementation for a basic memory game using buttons and lights. The game operates as follows:
- On startup, all of the LEDS are on. This indicates the chip is on and in its initialization state.
- When any button is pressed, a pseudorandom LED is lit up. It will stay lit until any button is pressed.
- The LEDs turn off and the game waits for player input. If the correct button is pressed, the LEDs show a new pattern with one new light prepended to the start. The pattern does not progress until the player presses any button.
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

This project assumes the usage of some PMOD buttons and LED outputs for the gameplay. The input and output signals are active-high, but that can be changed fairly easily by changing the code to invert the btnX_UNSAFE and LedX signals.

All inputs are buffered to ensure synchronicity and prevent metastability, and all of the logic operates on positive edge detection, so the latency and button held time should not matter.