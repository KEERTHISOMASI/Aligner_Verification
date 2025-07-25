///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_test_pkg.sv
// Author:      Cristian Florin Slav
// Date:        2023-06-27
// Description: Test package.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_TEST_PKG_SV
`define CFS_ALGN_TEST_PKG_SV 

`include "uvm_macros.svh"
`include "../env/cfs_algn_pkg.sv"

package cfs_algn_test_pkg;
  import uvm_pkg::*;
  import cfs_algn_pkg::*;
  import cfs_apb_pkg::*;
  import cfs_md_pkg::*;

  `include "cfs_algn_test_defines.sv"
  `include "cfs_algn_test_base.sv"
  `include "cfs_algn_test_reg_access.sv"
  `include "cfs_algn_test_random.sv"


  ///////////////////Control Tests//////////////
  `include "cfs_algn_test_clr_1write1.sv"
  `include "cfs_algn_test_1reg_access.sv"
  `include "cfs_algn_test_1fifo_lvls.sv"

  /////////////////// Data Test///////////////
  `include "cfs_algn_2data_algn.sv"
  `include "cfs_algn_2_legal_illegal_conf_data_algn.sv"
  `include "cfs_algn_test_2_controller_storage.sv"
  `include "cfs_algn_test_2_back_pressure_control.sv"

  ////////////////Interrupt Tests////////////////
  `include "cfs_algn_test_3_interrupt.sv"


  //////errors////////
  `include "cfs_algn_test_4_write_to_ro_n_read_to_wo.sv"
  //manual apb tests included below
  `include "../test/apb_tests/cfs_algn_apb_tests_mapped_unmapped.sv"


  ///////reset/////////
  `include "cfs_algn_test_5_reset.sv"
  `include "cfs_algn_test_5_clk_stall_behaviour.sv"

  //////////////////////just to hit coverage/////////////////////////
  // `include "cfs_algn_test_apb_len_delay.sv"
  //`include "cfs_algn_test_size_offset_cross.sv"
  `include "cfs_algn_test_size_offset_cross_reset.sv"
  `include "cfs_algn_test_reset_apb_access.sv"
  `include "cfs_algn_md_tests_target_length.sv"
  `include "cfs_algn_test_len.sv"
  `include "cfs_algn_test_split_cross_cover_directed.sv"
  `include "cfs_algn_test_ctrl4_off0_two_pkts.sv"
  `include "cfs_algn_test_split_cover_directed.sv"
  `include "cfs_algn_test_split_legal_combinations.sv"
  `include "cfs_algn_test_back_pressure_control_prdata.sv"
  `include "cfs_algn_test_rx_control.sv"
  `include "cfs_algn_test_rx_ready.sv"
  `include "cfs_algn_test_just_interrupts.sv"
  `include "cfs_algn_test_max_drp.sv"
  `include "cfs_algn_fif0_empty.sv"
  `include "cfs_algn_test_ctrl.sv"
  //manual md tests included below cfs_algn_test_rx_ready
  `include "../test/md_tests/cfs_algn_md_tests_random_traffic.sv"
  `include "../test/md_tests/cfs_algn_md_tests_cnt_drop.sv"
  `include "../test/cfs_algn_test_size_offset_cross_reset_rand.sv"
endpackage

`endif
