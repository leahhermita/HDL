# Lab 02: Logic Gates and Truth Tables

## Objective

Implement common logic gates and verify every output with a complete truth table.

## Theory

Logic gates are the building blocks of digital circuits. Verilog bitwise operators map naturally to gates: `&`, `|`, `~`, `^`, `~^`, `~&`, and `~|`.

## Commands

```bash
iverilog -o sim.out logic_gates.v tb_logic_gates.v
vvp sim.out
code lab02_logic_gates.vcd
# fallbacks:
surfer lab02_logic_gates.vcd
gtkwave lab02_logic_gates.vcd
```

## Waveform Checklist

- Add `a`, `b`, `and_y`, `or_y`, `not_a_y`, `xor_y`, `xnor_y`, `nand_y`, and `nor_y`.
- Confirm all four input combinations appear.
- Match each waveform output to the printed truth table.

## Challenge

XNOR is useful for equality checking because it outputs `1` when both inputs are the same (`00` or `11`) and `0` when they are different (`01` or `10`).
