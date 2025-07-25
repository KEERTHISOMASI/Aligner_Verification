
`ifndef CFS_ALGN_MD_TESTS_TARGET_LENGTH_SV
`define CFS_ALGN_MD_TESTS_TARGET_LENGTH_SV

class cfs_algn_md_tests_target_length extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_md_tests_target_length)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config       cfg_seq;
    cfs_md_sequence_slave_response_forever     resp_seq;
    cfs_algn_virtual_sequence_rx_exclude_size4 rx_delay_seq1;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_delay_seq;
    cfs_md_sequence_length5                    tx_block5_seq;
    cfs_md_sequence_length8                    tx_block8_seq;
    cfs_md_sequence_length4                    tx_block4_seq;
    cfs_md_sequence_length7                    tx_block7_seq;


    virtual cfs_algn_if                        vif;
    uvm_status_e                               status;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();

    // Now this comes AFTER all declarations
    // Step 0: Block TX side with a 4-byte transaction
    //
    // Step 0: Fork SLAVE_RESPONSE_FOREVER
    #(100ns);


    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none


    // Step 1: Configure registers (CTRL.SIZE = 2, OFFSET = 0)
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    env.model.reg_block.CTRL.write(status, 32'h00000002, UVM_FRONTDOOR);
    `uvm_info("TARGET_LENGTH", "Configured CTRL.SIZE = 2, OFFSET = 0", UVM_MEDIUM)
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);

    // Step 2: Send 2 RX packets with pre/post delays = 1
    for (int i = 0; i < 4; i++) begin
      rx_delay_seq = cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("data"));
      rx_delay_seq.set_sequencer(env.virtual_sequencer);
      rx_delay_seq.start(env.virtual_sequencer);
    end

    `uvm_info("TARGET_LENGTH", "2 RX packets sent with fixed delays", UVM_MEDIUM)

    // Step 3: Wait and then unblock TX ready
    #(10ns);
    //  disable fork;
    /*
    fork
      begin
        tx_block7_seq = cfs_md_sequence_length7::type_id::create("tx_block_seq");
        tx_block7_seq.start(env.md_tx_agent.sequencer);
      end
    join_none
    disable fork;

    `uvm_info("TARGET_LENGTH", "TX unblocked, ready to consume data", UVM_MEDIUM)
*/
    #(500ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif
