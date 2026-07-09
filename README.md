# -verilog-aegis-microgrid-controller
Deterministic FSM-based Virtual PLC for Microgrid Frequency Stability using Verilog.

# Aegis Microgrid Controller

## Overview
A Verilog-based Virtual PLC that maintains microgrid frequency stability using an FSM, RoCoF monitoring, ESS control, load shedding, and blackout detection.

## Features
- Grid Frequency Monitoring
- RoCoF Calculation
- FSM-Based Control
- ESS Dispatch
- Battery SoC Monitoring
- Load Shedding
- Automatic Recovery
- Blackout Detection

## Special Features
- **Grid Recovery Cooldown:** Enforces a 5-second cooldown after ESS dispatch or load shedding.
- **Crisis Burst Auto-Lock:** Enters Defensive Mode if 5 instability events occur within 10 seconds and requires manual reset.

## Repository Contents
- `aegis_controller.v` – Top module implementing the core controller features.
- `tb_aegis_controller.v` – Testbench for the top module.
- `aegis_controller_behav.png` – Simulation waveform of the core controller.
- `aegis_grid_controller.v` – Implementation of the special features.
- `tb_aegis_grid.v` – Testbench for the special features.
- `aegis_controller_SF_behav.png` – Simulation waveform for the special features.

## Tools
- Xilinx Vivado

## Hardware Description Language (HDL)
- Verilog HDL

## Author
**R Rithika**
