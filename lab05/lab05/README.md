# Lab 05: Comparators and ALU Basics

## Objective

Build a 4-bit comparator and a small arithmetic logic unit.

## Theory

An ALU performs selected arithmetic and logic operations. Control signals choose the operation, while flags describe the result.

## Commands

```bash
iverilog -o sim.out compare_alu.v tb_compare_alu.v
vvp sim.out
code lab05_compare_alu.vcd
# fallbacks:
surfer lab05_compare_alu.vcd
gtkwave lab05_compare_alu.vcd
```

## Waveform Checklist

- Watch `op` and confirm the ALU result changes by selected operation.
- Compare `eq`, `gt`, and `lt` with `a` and `b`.
- Check the `zero` flag when the ALU result is `0000`.

## Challenge

Add a bitwise NOT operation for input `a`.
