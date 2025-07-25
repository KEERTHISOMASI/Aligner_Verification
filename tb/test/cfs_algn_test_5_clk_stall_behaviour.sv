




`ifndef CFS_ALGN_TEST_5_CLK_STALL_BEHAVIOUR_SV
`define CFS_ALGN_TEST_5_CLK_STALL_BEHAVIOUR_SV

class cfs_algn_test_5_clk_stall_behaviour extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_5_clk_stall_behaviour)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_algn_virtual_sequence_rx_ok rx_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_reads read_seq;

    virtual cfs_algn_if vif;
    uvm_reg_data_t ctrl_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irq_val;
    uvm_reg_data_t irqen_val;

    uvm_status_e status;
    int clk_yes;
    logic clk_no;
    phase.raise_objection(this, "CLK_STALL_TEST_START");
    #(50ns);

    // Get VIF for clock sync
    vif = env.env_config.get_vif();
    if (!uvm_config_db#(virtual cfs_algn_if)::get(null, "uvm_test_top.env", "vif", vif)) begin
      `uvm_fatal("CLOCK_TEST", "Failed to get aligner VIF from config DB")
    end
    // Step 0: Start slave response sequence
    fork
      resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
      resp_seq.start(env.md_tx_agent.sequencer);
    join_none

    // Step 1: Register setup
    //cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    // cfg_seq.set_sequencer(env.virtual_sequencer);
    //cfg_seq.start(env.virtual_sequencer);

    // Step 3: Send RX packet after clock is resumed
    //for (int i = 0; i < 15; i++) begin
    rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
    rx_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_seq.randomize());
    rx_seq.start(env.virtual_sequencer);
    //end
    #(100ns);
    repeat (2) @(posedge vif.clk);

    // Step 3: Read CTRL before stall
    //env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //`uvm_info("CLK_TEST", $sformatf("CTRL before stall: 0x%0h", ctrl_val), UVM_MEDIUM)

    // Step 4: Stall clock using uvm_hdl_force:w
    clk_no = 1'b0;
    `uvm_info("CLK_TEST", "Forcing clock low (simulate stall)", UVM_MEDIUM)
    clk_yes = uvm_hdl_force("testbench.clk", clk_no);
    if (!clk_yes) `uvm_fatal("CLK_FORCE", "Failed to force clock")
    `uvm_info("CLK_RELEASE", $sformatf("successfully released clock"), UVM_MEDIUM)


    #(30ns);

    // Optional: Try reading CTRL during stall (may hang if DUT is frozen)
    //env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //`uvm_info("CLK_TEST", $sformatf("CTRL during stall: 0x%0h", ctrl_val), UVM_MEDIUM)

    // Step 5: Release clock
    `uvm_info("CLK_TEST", "Releasing clock", UVM_MEDIUM)
    clk_yes = uvm_hdl_release("testbench.clk");
    if (!clk_yes) `uvm_fatal("CLK_TEST", "Failed to release clock")
    #(100ns);



    ////env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    //env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    //env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    if (!clk_yes) `uvm_fatal("CLK_TEST", "Failed to release clock")

    `uvm_info("CLK_TEST", $sformatf("successfully released clock"), UVM_MEDIUM)

    repeat (20) @(posedge vif.clk);

    // Step 6: Send RX packet after clock is resumed
    //for (int i = 0; i < 15; i++) begin
    rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
    rx_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_seq.randomize());
    rx_seq.start(env.virtual_sequencer);
    //end
    repeat (20) @(posedge vif.clk);


    // Step 7: Final check
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);

    #(100ns);
    phase.drop_objection(this, "CLK_STALL_TEST_DONE");
  endtask

endclass

`endif
