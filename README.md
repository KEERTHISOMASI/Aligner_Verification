# Aligner Module - UVM Verification

## Overview

This project verifies the **Aligner** RTL module using a UVM-based testbench. The Aligner is responsible for aligning unaligned input data based on configurable OFFSET and SIZE values, managing RX/TX FIFOs, handling APB register accesses, and asserting interrupts appropriately.

## Goals of Verification

- ✅ Functionally verify data alignment logic
- ✅ Validate all APB register accesses and field-level behaviors
- ✅ Ensure proper interrupt generation and clearing (`IRQ`, `IRQEN` registers)
- ✅ Detect and handle edge cases like FIFO overflows, reserved register accesses, invalid settings
- ✅ Confirm robust reset and back-pressure behavior
- ✅ Achieve **100% Functional Coverage** and **100% Code Coverage**
- ✅ Toggle each writable bit of APB-accessible registers to 1 and back to 0
- ✅ Ensure reserved fields are excluded from coverage collection
- ✅ Perform address-aware coverage on registers, sampling field-wise toggles

---

## UVM Testbench Architecture

```
Testbench
├── Test(s)
│   └── Config
├── Environment
│   ├── Virtual Sequencer
│   ├── Scoreboard
│   ├── Coverage
│   ├── Model (includes Register Model)
│   └── Predictor
├── Agents
│   ├── APB Agent (for Register Access)
│   ├── RX Agent (input data)
│   └── TX Agent (output data)
│       └── Each agent includes: Config, Interface, Driver, Monitor, Sequencer, Coverage
└── DUT (Aligner RTL)
```

---

## ✅ Testcases Implemented

- `cfs_algn_test_1reg_access.sv`
- `cfs_algn_test_3_interrupt.sv`
- `cfs_algn_test_max_drp.sv`
- `cfs_algn_test_split_cross_cover_directed.sv`
- `cfs_algn_test_reset_apb_access.sv`
- `cfs_algn_test_split_legal_combinations.sv`
- `cfs_algn_test_back_pressure_control_prdata.sv`
- ... *(30+ other tests for full functional coverage)*

---

## 🎬 Virtual Sequences

- `cfs_algn_virtual_sequence_rx_ok.sv`
- `cfs_algn_virtual_sequence_reg_status.sv`
- `cfs_algn_virtual_sequence_split_legal_combinations.sv`
- `cfs_algn_virtual_sequence_rx_comb.sv`
- `cfs_algn_virtual_sequence_reg_access_random.sv`
- `cfs_algn_virtual_sequence_reg_access_unmapped.sv`

---

## 📈 Coverage Components

### cover\_item (Functional coverage)

- Direction of APB access
- Response type
- Delay between accesses
- Transition and cross coverage (e.g., direction vs. response)

### cg\_interrupt (Interrupt field coverage)

```systemverilog
covergroup cg_interrupt @(posedge clk);
  coverpoint interrupt_reg[0] iff (interrupt_seen[0]) { bins toggle[] = {1, 0}; } // RX_FIFO_EMPTY
  coverpoint interrupt_reg[1] iff (interrupt_seen[1]) { bins toggle[] = {1, 0}; } // RX_FIFO_FULL
  coverpoint interrupt_reg[2] iff (interrupt_seen[2]) { bins toggle[] = {1, 0}; } // TX_FIFO_EMPTY
  coverpoint interrupt_reg[3] iff (interrupt_seen[3]) { bins toggle[] = {1, 0}; } // TX_FIFO_FULL
  coverpoint interrupt_reg[4] iff (interrupt_seen[4]) { bins toggle[] = {1, 0}; } // INTERRUPT_DONE
endgroup
```

### cover\_reset

Covers `psel` during reset to ensure no access is lost.

### Register Bit Toggle Coverage

- Toggled all bits of accessible registers (like `CTRL`, `STATUS`, `TEN`, `IRQ`, `IRQEN`) from 0→1→0
- Ensured reserved fields are masked in coverage
- Address-specific coverage samples fields only when accessed

---

## 🛠️ Build and Run

### Makefile Targets (in `sim/` folder)

```makefile
make comp       # Compile with coverage
make run        # Run simulation in CLI
make grun       # Run simulation in GUI
make report     # Merge and view HTML coverage
make regress    # Full regression with seed variations
make clean      # Cleanup
```

### Example Regression Flow

```bash
# Compile and run all listed tests
bash sim/regression.sh

# sim/regressions/regress_list.txt holds the test list:
cfs_algn_test_1reg_access
cfs_algn_test_3_interrupt
...
```

---

## 📊 Coverage Reports

- All coverage (.ucdb) dumped in `sim/ucdb/`
- Reports merged via:

```bash
make report
# Opens HTML coverage summary in browser
```

---

## 📂 Directory Structure

```
.
├── rtl/                    # Aligner RTL
├── testbench/
│   ├── tests/              # All test cases
│   ├── sequences/          # Virtual sequences
│   ├── env/                # UVM Environment
│   ├── agents/             # APB, RX, TX agents
│   ├── top/                # Testbench wrapper
│   └── sim/
│     ├── Makefile            # Build + regression
│     ├── regression.sh       # Shell script for regression
│     ├── toggle_exclude.do   # Dead code exclusion
│     ├── regressions/        # Test lists
│     ├── ucdb/               # Coverage dumps
│     └── logs/               # Simulation logs
```

---

## 🏁 Results

- ✅ 100% **Functional Coverage**
- ✅ 100% **Code Coverage** (rest justified via `toggle_exclude.do`)
- ✅ All writable register bits toggled
- ✅ Reserved bits safely excluded
- 🧪 All corner cases and error scenarios tested
- 🧵 Modular, scalable UVM testbench

---

## 📧 Contact

**Keerthi Sree Somasi**\
Aligner Verification Project | VLSI Design Verification Intern\
Feel free to open issues or reach out for collaboration!

---

