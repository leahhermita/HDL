# Lab 04: Multiplexers and Decoders

## Objective

Use `case` statements to build a 4-to-1 multiplexer and a 2-to-4 decoder.

## Theory

A multiplexer selects one input from many. A decoder activates one output line based on a binary input. These circuits are common in datapaths and control logic.

## Commands

```bash
iverilog -o sim.out mux_decoder.v tb_mux_decoder.v
vvp sim.out
code lab04_mux_decoder.vcd
# fallbacks:
surfer lab04_mux_decoder.vcd
gtkwave lab04_mux_decoder.vcd
```

## Waveform Checklist

- Confirm `mux_y` follows the input selected by `sel`.
- Confirm only one decoder output bit is high when `enable` is high.
- Confirm all decoder outputs are zero when `enable` is low.

## Challenge

Create an 8-to-1 multiplexer using a 3-bit select input.

The `mux8to1` module in `mux_decoder.v` uses a `case` statement to select one
bit from an 8-bit `data` input based on the 3-bit `sel` value. The testbench
checks all eight select values.
