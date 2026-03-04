# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.

    # My tests ======================================================

    await ClockCycles(dut.clk, 10)

    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)

    #try to fail
    dut._log.info("Pushing btnU once")
    #push btnU
    await FallingEdge(dut.clk)
    dut.ui_in.value = 0x01
    await FallingEdge(dut.clk)
    dut.ui_in.value = 0x00
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)

    if (dut.uo_out.value == 0x0F):
        dut._log.error("never left reset state")
        assert(1==0)

    dut._log.info("Pushing btnU until failure")

    while (dut.uo_out.value != 0x0F):
        #push btnU
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x01
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x00
        await FallingEdge(dut.clk)
        await FallingEdge(dut.clk)
        await FallingEdge(dut.clk)
        await FallingEdge(dut.clk)
    

    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    dut._log.info("Successfully lost the game. Now playing 5 rounds to win")

    if (dut.uo_out.value != 0x0f):
        dut._log.error("Not in reset state")
        assert(1 == 0)
    else:
        #push btnU
        dut.ui_in.value = 0x01
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x00
        await FallingEdge(dut.clk)


    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    for _ in range(16):
        pattern = list()
        while (dut.uo_out.value != 0x00):
            # print("Appending to pattern: ", hex(dut.uo_out.value))
            pattern.append(int(dut.uo_out.value))

            await FallingEdge(dut.clk)
            dut.ui_in.value = 0x01
            await FallingEdge(dut.clk)
            await FallingEdge(dut.clk)
            dut.ui_in.value = 0x00
            await FallingEdge(dut.clk)
            await FallingEdge(dut.clk)
            await FallingEdge(dut.clk)
            await FallingEdge(dut.clk)
        
        for j in range(10):
            await FallingEdge(dut.clk)
        print("\npattern is:")
        print(pattern)
        dut._log.info("Entered gameplay state")

        for my_input in pattern:
            await FallingEdge(dut.clk)
            dut.ui_in.value = int(my_input)
            # dut.ui_in.value = 0x01
            await FallingEdge(dut.clk)
            await FallingEdge(dut.clk)
            dut.ui_in.value = 0x00
            await FallingEdge(dut.clk)
            await FallingEdge(dut.clk)
            await FallingEdge(dut.clk)
            
        for j in range(10):
            await FallingEdge(dut.clk)

        if (dut.uo_out.value == 0x0f):
            dut._log.error("Lost unexpectedly")
            assert(1==0)


    dut._log.info("Successfully won 15 rounds")

    for _ in range(10):
        await FallingEdge(dut.clk)

    dut._log.info("Losing my streak")
    while (dut.uo_out.value != 0x0F):
        #push btnU
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x02
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x00
        await FallingEdge(dut.clk)
        await FallingEdge(dut.clk)
        await FallingEdge(dut.clk)
        await FallingEdge(dut.clk)

    for _ in range(10):
        await FallingEdge(dut.clk)