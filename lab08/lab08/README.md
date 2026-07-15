# Lab 08: Shift Registers and Serial Data

## Objective

Build a 4-bit shift register with parallel load, serial input, and selectable shift direction.

## Theory

Shift registers move data one bit at a time. They are used in serial communication, data delay, and bit manipulation circuits.

## Commands

```bash
cd lab08
iverilog -o sim.out shift_register.v tb_shift_register.v
vvp sim.out
code lab08_shift_register.vcd
# fallbacks:
surfer lab08_shift_register.vcd
gtkwave lab08_shift_register.vcd
```

## Waveform Checklist

- Confirm `load` copies `parallel_in` into `q`.
- Confirm `direction = 0` shifts `serial_in` into the left side.
- Confirm `direction = 1` shifts `serial_in` into the right side.
- Confirm `serial_out` shows the bit leaving the selected output side.

## Challenge

Done: `direction = 0` shifts right, and `direction = 1` shifts left.
