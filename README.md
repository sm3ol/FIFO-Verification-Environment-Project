# FIFO Verification Environment Project

This project implements a Universal Verification Methodology (UVM)-based verification environment for a First-In-First-Out (FIFO) module. The environment tests various aspects of FIFO functionality, including data integrity, reset behavior, and edge-case handling, ensuring the module's reliability and performance in different scenarios.

## Project Components

### RTL Design
1. **FIFO Design (`FIFO.sv`):**
   - Implements the core FIFO logic, including data enqueue and dequeue operations.
   - Supports parameterized depth and width for flexible configurations.

2. **Top-Level Module (`FIFO_top.sv`):**
   - Integrates the FIFO module with external interfaces for simulation and verification.

### UVM Components
1. **Agent (`FIFO_agent.sv`):**
   - Encapsulates the driver, monitor, and sequencer for reusable verification logic.

2. **Configuration (`FIFO_config.sv`):**
   - Defines configurable parameters such as data width, depth, and reset values.

3. **Driver (`FIFO_driver.sv`):**
   - Drives stimuli into the FIFO DUT based on sequence items.

4. **Monitor (`FIFO_monitor.sv`):**
   - Observes and reports signals from the DUT, providing real-time feedback to the scoreboard.

5. **Sequencer (`FIFO_sequencer.sv`):**
   - Manages the sequence of operations, interacting with the driver to apply test scenarios.

6. **Sequence Items (`FIFO_seq_item.sv`):**
   - Defines the transactions or data items passed between the sequencer and driver.

7. **Main Sequence (`FIFO_main_sequence.sv`):**
   - Implements the primary test scenarios for the FIFO.

8. **Reset Sequence (`FIFO_reset_sequence.sv`):**
   - Tests the reset behavior and ensures the DUT returns to a valid state.

9. **Environment (`FIFO_env.sv`):**
   - Integrates the agent, scoreboard, and other components into a cohesive environment.

10. **Scoreboard (`FIFO_scoreboard.sv`):**
    - Compares expected results with actual DUT outputs for validation.

### Shared Components
- **Interface (`FIFO_if.sv`):**
  - Provides a clean abstraction for connecting testbench components to the DUT.
- **Shared Package (`shared_package.sv`):**
  - Contains common definitions, enums, and utility functions.

### Testbench
- **Test Module (`FIFO_test.sv`):**
  - Top-level testbench that initializes and runs the UVM environment.

### Coverage
- **Coverage Module (`FIFO_coverage.sv`):**
  - Collects functional coverage metrics to evaluate the completeness of the testbench.

## Features
- UVM-based verification environment for a FIFO module.
- Parameterized design for customizable FIFO configurations.
- Comprehensive test scenarios, including:
  - Normal data operations.
  - Reset behavior.
  - Full and empty edge cases.
- Functional and code coverage for design validation.

## Getting Started

1. **Prerequisites:**
   - UVM-compatible simulation tools (e.g., ModelSim, VCS, or Riviera-PRO).
   - Basic understanding of UVM and SystemVerilog.

2. **Simulation Steps:**
   - Compile all design and testbench files.
   - Run the `FIFO_test.sv` module in your simulator.
   - Analyze the simulation results and waveform outputs.

3. **Customization:**
   - Adjust parameters in `FIFO_config.sv` for specific design configurations.
   - Add or modify sequences in `FIFO_main_sequence.sv` to test new scenarios.

## Future Enhancements
- Add support for advanced FIFO features like multi-clock domains.
- Extend coverage models for performance metrics.
- Implement assertions for improved verification quality.

