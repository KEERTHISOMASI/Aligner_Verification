
///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_test_size_offset_cross.sv
// Author:     KEERTHI SREE 
// Date:        2023-12-17
// Description: Random test
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_MD_TEST_SIZE_OFFSET_CROSS_SV
`define CFS_ALGN_MD_TEST_SIZE_OFFSET_CROSS_SV


class cfs_algn_test_size_offset_cross extends cfs_algn_test_base;


  `uvm_component_utils(cfs_algn_test_size_offset_cross)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_algn_virtual_sequence_rx_comb rx_comb_seq;
    cfs_md_sequence_slave_response_forever seq;
    cfs_algn_vif vif;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_DONE");

    #(10ns);

    fork
      begin
        seq = cfs_md_sequence_slave_response_forever::type_id::create("seq");
        seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // repeat (30) begin
    if (env.model.is_empty()) begin
      cfs_algn_virtual_sequence_reg_config seq1 = cfs_algn_virtual_sequence_reg_config::type_id::create(
          "seq1"
      );

      void'(seq1.randomize());

      seq1.start(env.virtual_sequencer);
    end

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);

    vif = env.env_config.get_vif();

    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end


    env.model.reg_block.CTRL.write(status, 32'h00000000,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 0 SIZE 0
    //env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);

    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end
    env.model.reg_block.CTRL.write(status, 32'h00000001,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 0 SIZE 1
    //env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);
    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end

    env.model.reg_block.CTRL.write(status, 32'h00000101,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 1 SIZE 1

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);

    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end


    env.model.reg_block.CTRL.write(status, 32'h00000201,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 2 SIZE 1

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);
    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end



    env.model.reg_block.CTRL.write(status, 32'h00000301,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 3 SIZE 1

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);
    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end


    env.model.reg_block.CTRL.write(status, 32'h00000002,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 0 SIZE 2

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);
    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end

    env.model.reg_block.CTRL.write(status, 32'h00000202,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 2 SIZE 2

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);
    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end



    env.model.reg_block.CTRL.write(status, 32'h00000203,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 2 SIZE 3

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);

    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end



    env.model.reg_block.CTRL.write(status, 32'h00000004,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 4 SIZE 0

    rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
    rx_comb_seq.set_sequencer(env.virtual_sequencer);
    rx_comb_seq.start(env.virtual_sequencer);
    while (env.model.is_empty()) begin
      @(posedge vif.clk);
    end




    #(500ns);

    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif
