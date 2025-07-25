
`ifndef CFS_ALGN_TEST_JUST_INTERRUPTS
`define CFS_ALGN_TEST_JUST_INTERRUPTS
class cfs_algn_test_just_interrupts extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_just_interrupts)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq;
    //cfs_algn_virtual_sequence_rx_ok rx_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 data_40seq;
    cfs_algn_virtual_sequence_reg_reads reg_read_seq;

    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t cnt_val;
    uvm_reg_data_t clr_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irq_val;

    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 0: Fork SLAVE_RESPONSE_FOREVER
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // enabling all interrupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;  // MAX_DROP
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    #(30ns);
    // `uvm_info("TEST_INTERRUPT", $sformatf("IRQEN updated: 0x%0h", irqen_val),
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    //           UVM_MEDIUM)  //ensure irqen_val[4]=1

    // Step 2: Manual CTRL config - offset 0 size 1 

    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, cnt_val, UVM_FRONTDOOR);

    // Step 3: wait
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);
    `uvm_info("TEST_INTERRUPT", $sformatf("CTRL register value: 0x%0h ", cnt_val), UVM_MEDIUM)
    $display("----------------------------------------------------------------------------");
    $display("------------------Starting RX illegal  ------------------");
    $display("----------------------------------------------------------------------------");
    // sending 258 illegal data from rx
    for (int i = 0; i < 258; i++) begin
      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_size1_%0d", i));

      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());

      rx_err_seq.set_sequencer(env.virtual_sequencer);
      rx_err_seq.start(env.virtual_sequencer);
    end



    // Step 4: Send 30 RX packets of size4 offset0 
    for (int i = 0; i < 30; i++) begin
      data_40seq =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_%0d", i));

      data_40seq.set_sequencer(env.virtual_sequencer);
      void'(data_40seq.randomize());

      data_40seq.set_sequencer(env.virtual_sequencer);
      data_40seq.start(env.virtual_sequencer);
      `uvm_info("TEST_INTERRUPT", $sformatf("sending rx for size 4 and offset 0"), UVM_MEDIUM)
      //if (vif.irq == 1) `uvm_info("TEST_INTERRUPT", $sformatf("intrrupt irq=1"), UVM_MEDIUM)
      //if (vif.irq == 0) `uvm_info("TEST_INTERRUPT", $sformatf("intrrupt irq=0"), UVM_MEDIUM)

    end
    //env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);

    repeat (50) @(posedge vif.clk);




    //wait time 
    repeat (500) @(posedge vif.clk);

    //reading register
    //  reg_read_seq = cfs_algn_virtual_sequence_reg_reads::type_id::create("reg_read_seq");
    // reg_read_seq.set_sequencer(env.virtual_sequencer);
    //reg_read_seq.start(env.virtual_sequencer);



    #(100ns);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    irq_val = 32'h000000ff;  // MAX_DROP
    env.model.reg_block.IRQ.write(status, irq_val, UVM_FRONTDOOR);
    #(40ns) env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);

    #(100ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif
