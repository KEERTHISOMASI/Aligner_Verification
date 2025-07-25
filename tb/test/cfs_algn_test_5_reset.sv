`ifndef CFS_ALGN_TEST_5_RESET_SV
`define CFS_ALGN_TEST_5_RESET_SV

class cfs_algn_test_5_reset extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_test_5_reset)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  int in;
  virtual cfs_apb_if vif;
  cfs_algn_vif vif_algn;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual cfs_apb_if)::get(
            null, "uvm_test_top.env.apb_agent", "vif", vif
        )) begin
      `uvm_fatal("NO_VIF", "Unable to get APB_if from config DB")
    end
    if (!uvm_config_db#(virtual cfs_algn_if)::get(null, "uvm_test_top.env", "vif", vif_algn)) begin
      `uvm_fatal("NO_ALGN_VIF", "Unable to get cfs_algn_if from config DB")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    // super.run_phase(phase);
    cfs_algn_virtual_sequence_reg_config reg_config_seq;
    cfs_algn_virtual_sequence_rx_ok legal_rx_seq, legal_rx_seq1;
    cfs_algn_virtual_sequence_rx_err rx_err_seq;
    cfs_algn_virtual_sequence_reg_reads reg_read_seq;
    cfs_md_sequence_slave_response_forever resp_seq;
    process resp_proc;
    phase.raise_objection(this, "TEST_START");


    #(100ns);

    // Step 0: Fork slave response forever
    fork
      resp_proc = process::self();
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Register Configuration
    reg_config_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("reg_config_seq");
    reg_config_seq.set_sequencer(env.virtual_sequencer);
    reg_config_seq.start(env.virtual_sequencer);

    // Legal RX stream
    begin
      for (int i = 0; i < 5; i++) begin
        legal_rx_seq =
            cfs_algn_virtual_sequence_rx_ok::type_id::create($sformatf("legal_rx_%0d", i));
        legal_rx_seq.set_sequencer(env.virtual_sequencer);
        void'(legal_rx_seq.randomize());
        legal_rx_seq.start(env.virtual_sequencer);
        $display("--------------count===%0d---------------------", in);
        in++;
      end
    end

    // Illegal RX stream
    begin
      for (int i = 0; i < 6; i++) begin
        rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_%0d", i));
        rx_err_seq.set_sequencer(env.virtual_sequencer);
        void'(rx_err_seq.randomize());
        rx_err_seq.start(env.virtual_sequencer);
        $display("--------------count===%0d---------------------", in);
        in++;

      end
    end

    // Reset sequence after 10 cycles
    repeat (10) @(posedge vif_algn.clk);

    `uvm_info(get_type_name(), "Asserting reset...", UVM_MEDIUM)
    vif.preset_n <= 0;
    resp_proc.kill();
    $display(
        "-------------------------------Asserting reset..-------------------------------------",
        in);


    // fork
    //  begin
    //  for (int i = 0; i < 5; i++)
    begin
      $display(
          "--------------count===%0d sent-----------------and ----data in middle of reset---------------------",
          in);
      legal_rx_seq1 = cfs_algn_virtual_sequence_rx_ok::type_id::create($sformatf("legal_rx_"));
      legal_rx_seq1.set_sequencer(env.virtual_sequencer);
      void'(legal_rx_seq1.randomize());
      legal_rx_seq1.start(env.virtual_sequencer);
      $display(
          "--------------count===%0d-----------------and ----data in middle of reset---------------------",
          in);
      in++;


    end
    // end
    //join_none
    repeat (2) @(posedge vif_algn.clk);
    vif.preset_n <= 1;
    `uvm_info(get_type_name(), "Deasserted reset.", UVM_MEDIUM)
    $display(
        "------------------------------Deasserting reset..-------------------------------------");

    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq_after_reset");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none
    // Step 3: Register reads after reset
    repeat (5) @(posedge vif_algn.clk);

    // reg_read_seq = cfs_algn_virtual_sequence_reg_reads::type_id::create("reg_read_seq");
    // reg_read_seq.set_sequencer(env.virtual_sequencer);
    // reg_read_seq.start(env.virtual_sequencer);
    #(100ns);
    phase.drop_objection(this);
  endtask

endclass

`endif  // CFS_ALGN_TEST_5_RESET_SV
