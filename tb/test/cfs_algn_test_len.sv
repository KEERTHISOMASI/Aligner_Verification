`ifndef CFS_ALGN_TEST_LEN_SV
`define CFS_ALGN_TEST_LEN_SV

class cfs_algn_test_len extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_len)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_algn_virtual_sequence_rx_ok rx_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_md_sequence_length8 resp_seq;
    cfs_algn_virtual_sequence_reg_reads read_seq;
    cfs_md_sequence_length7 resp_seq1;
    cfs_md_sequence_length5 resp_seq2;
    cfs_md_sequence_length4 resp_seq3;
    cfs_algn_virtual_sequence_rx_size4_offset0 seq;
    cfs_md_sequence_slave_response_forever tx_unblock_seq;
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
    // Step 0: Start slave response sequence
    fork
      resp_seq = cfs_md_sequence_length8::type_id::create("resp_seq");
      resp_seq.start(env.md_tx_agent.sequencer);
    join_none
    // Step 1: Register setup
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 3: Send RX packet after clock is resumed
    //for (int i = 0; i < 15; i++) begin
    rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
    rx_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_seq.randomize());
    rx_seq.start(env.virtual_sequencer);
    //end
    #(100ns);
    vif = env.env_config.get_vif();
    repeat (2) @(posedge vif.clk);

    // Step 3: Read CTRL before stall
    //env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //`uvm_info("CLK_TEST", $sformatf("CTRL before stall: 0x%0h", ctrl_val), UVM_MEDIUM)


    #(30ns);

    // Optional: Try reading CTRL during stall (may hang if DUT is frozen)
    //env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //`uvm_info("CLK_TEST", $sformatf("CTRL during stall: 0x%0h", ctrl_val), UVM_MEDIUM)



    ////env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    //env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    repeat (20) @(posedge vif.clk);

    // Step 6: Send RX packet after clock is resumed
    for (int i = 0; i < 2; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    fork
      resp_seq1 = cfs_md_sequence_length7::type_id::create("resp_seq");
      resp_seq1.start(env.md_tx_agent.sequencer);
    join_none

    #(20ns) repeat (20) @(posedge vif.clk);
    for (int i = 0; i < 15; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end
    repeat (40) @(posedge vif.clk);

    for (int i = 0; i < 2; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    repeat (20) @(posedge vif.clk);
    #(20ns)
    fork
      resp_seq2 = cfs_md_sequence_length5::type_id::create("resp_seq");
      resp_seq2.start(env.md_tx_agent.sequencer);
    join_none


    for (int i = 0; i < 4; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end
    #(20ns) repeat (30) @(posedge vif.clk);

    fork
      resp_seq3 = cfs_md_sequence_length4::type_id::create("resp_seq");
      resp_seq3.start(env.md_tx_agent.sequencer);
    join_none
    for (int i = 0; i < 2; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_ok::type_id::create("rx_seq_post_stall");
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end
    for (int i = 0; i < 2; i++) begin
      seq = cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create("rx_seq_post_stall");
      seq.set_sequencer(env.virtual_sequencer);
      void'(seq.randomize());
      seq.start(env.virtual_sequencer);
    end
    disable fork;
    fork
      begin
        tx_unblock_seq = cfs_md_sequence_slave_response_forever::type_id::create("tx_unblock_seq");
        tx_unblock_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    /*
    fork
      resp_seq1 = cfs_md_sequence_length7::type_id::create("resp_seq");
      resp_seq1.start(env.md_tx_agent.sequencer);
    join_none
*/
    // Step 7: Final check
    //env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    //env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    //env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);

    #(500ns);
    phase.drop_objection(this, "CLK_STALL_TEST_DONE");
  endtask

endclass

`endif
