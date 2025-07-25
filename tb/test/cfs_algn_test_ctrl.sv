
`ifndef CFS_ALGN_TEST_CTRL_SV
`define CFS_ALGN_TEST_CTRL_SV

class cfs_algn_test_ctrl extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_test_ctrl)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_seq40;
    cfs_md_sequence_md_tx_ready_zero txzero_seq;
    cfs_algn_virtual_sequence_rx_size1 rx_seq1;
     cfs_algn_vif vif;

    uvm_reg_data_t irqen_val;
    uvm_reg_data_t control_val;
    uvm_reg_data_t status_val;

    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 1: Start back-pressure simulation from DUT by blocking MD_TX_READY signal
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none


    // Step 2: Configure DUT registers using register config virtual sequence
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 3: Enable all interrupt sources
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;  // Enable all IRQ bits
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("IRQEN_UPDATE", $sformatf("IRQEN updated: 0x%0h", irqen_val), UVM_MEDIUM)

    // Step 4: Manually configure CTRL register with offset=2, size=2 to initiate aligner
    env.model.reg_block.CTRL.write(status, 32'h0000202, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);
    `uvm_info("CTRL_WRITE", $sformatf("CTRL register value: 0x%0h", control_val), UVM_MEDIUM)

    // Step 5: Wait for stabilization
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);
   
    rx_seq1 =
          cfs_algn_virtual_sequence_rx_size1::type_id::create($sformatf("rx_size1"));
      rx_seq1.set_sequencer(env.virtual_sequencer);
      void'(rx_seq1.randomize());
      rx_seq1.start(env.virtual_sequencer);


#(30ns);

      rx_seq40 =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size4_" ));
      rx_seq40.set_sequencer(env.virtual_sequencer);
      void'(rx_seq40.randomize());
      rx_seq40.start(env.virtual_sequencer);


    // Step 6: Send 11 RX packets with size=4 and offset=0
    for (int i = 0; i < 8; i++) begin
      rx_seq40 =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size4_%0d", i));
      rx_seq40.set_sequencer(env.virtual_sequencer);
      void'(rx_seq40.randomize());
      rx_seq40.start(env.virtual_sequencer);

      #(20ns);
       rx_seq1 =
          cfs_algn_virtual_sequence_rx_size1::type_id::create($sformatf("rx_size1"));
      rx_seq1.set_sequencer(env.virtual_sequencer);
      void'(rx_seq1.randomize());
      rx_seq1.start(env.virtual_sequencer);


    end

    repeat (5) @(posedge vif.clk);
   // env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);

  


    // Optional wait for all transactions and scoreboard to settle
    #(5000ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif
