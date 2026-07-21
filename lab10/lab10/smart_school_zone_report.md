# Smart School-Zone Traffic Controller Design Report

## Problem Statement

Traditional traffic-light controllers use fixed timing even during school hours or pedestrian crossing activity. This design improves a basic intersection controller by adding school-mode timing, pedestrian crossing support, walk countdown output, flashing-yellow inactive mode, and safe reset behavior.

## Objectives

- Control main-road and side-road traffic lights.
- Support normal mode and school mode.
- Accept and latch pedestrian crossing requests.
- Provide a walk signal with countdown timing.
- Guarantee safe state transitions.
- Return immediately to a safe state on reset.

## FSM State Diagram

```text
Reset
  |
  v
S0 Main Green
  |
  v
S1 Main Yellow
  |
  v
S2 Side Green
  |---- no ped_request/pending ----> S3 Side Yellow
  |
  |---- ped_request/pending -------> S4 Walk
                                      |
                                      v
S3 Side Yellow <----------------------
  |
  v
S0 Main Green
```

When `flash_mode = 1` and `school_mode = 0`, the controller overrides the normal FSM outputs with flashing yellow on the main road, red on the side road, walk off, and countdown zero.

## State Table

| State | Main Light | Side Light | Walk | Normal Duration | School Duration | Next State |
|---|---|---|---|---:|---:|---|
| S0 Main Green | Green | Red | Off | 10 s | 8 s | S1 |
| S1 Main Yellow | Yellow | Red | Off | 3 s | 3 s | S2 |
| S2 Side Green | Red | Green | Off | 8 s | 10 s | S4 if request, else S3 |
| S4 Walk | Red | Red | On | 5 s countdown | 8 s countdown | S3 |
| S3 Side Yellow | Red | Yellow | Off | 3 s | 3 s | S0 |

## Timing Explanation

The simulation treats each positive clock edge as one timing tick. In normal mode, main green lasts 10 ticks, main yellow 3 ticks, side green 8 ticks, and side yellow 3 ticks. In school mode, main green is shortened to 8 ticks and side green is extended to 10 ticks. Pedestrian requests are latched and served only after the controller reaches the safe crossing point after side green. The school walk countdown displays 8, 7, 6, 5, 4, 3, 2, 1, then 0.

## Simulation Results

The testbench verifies:

- Reset operation.
- Normal traffic cycle.
- School mode timing.
- Flashing yellow mode.
- Pedestrian request handling.
- Walk countdown.
- Reset during side green.
- Multiple pedestrian requests during one walk service.
- Safety rule that main and side roads are never green simultaneously.

Final terminal result:

```text
=== SIMULATION PASSED: all smart school-zone controller checks succeeded ===
```

Generated waveform file:

```text
smart_school_zone.vcd
```

## Waveform Observations

- After reset, `main_light = GREEN`, `side_light = RED`, `walk_light = 0`, and `countdown = 0`.
- In normal mode, the output sequence is main green, main yellow, side green, side yellow, then back to main green.
- In school mode, main green is shorter and side green is longer than normal mode.
- With a pedestrian request, the request is not served during yellow. It is latched and served after side green.
- During the walk state, both traffic lights are red, `walk_light = 1`, and `countdown` decreases to zero.
- During flashing mode, the main road alternates yellow/off while the side road remains red.

## Guide Questions

1. Why is an FSM appropriate for this controller?
   An FSM is appropriate because the controller has a fixed set of operating states, deterministic transitions, and outputs that depend on the current state and mode inputs.

2. How is safety maintained?
   Main and side roads are never green together, yellow states occur before changing vehicle right-of-way, walk is enabled only when both roads are red, and reset returns to main green with side red.

3. How does school mode change behavior?
   School mode shortens main-road green timing, extends side-road green timing, and gives pedestrians the longer 8-second walk countdown.

4. How are pedestrian requests handled?
   A request is latched, the current safe traffic sequence finishes, and the walk state is entered after side green. Requests during the current walk state do not restart the walk countdown.

5. What does flashing yellow mode represent?
   It represents inactive school periods outside school hours. The main road receives a caution indication while the side road stays red.
