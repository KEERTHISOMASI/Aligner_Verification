
`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_RX_EXCLUDE_SIZE4_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_RX_EXCLUDE_SIZE4_SV

class cfs_algn_virtual_sequence_rx_exclude_size4 extends cfs_algn_virtual_sequence_rx;

  // Aligner data width in bits
  local int unsigned algn_data_width;

  // Constraints to force size = 4
  constraint fixed_size_offset {
    seq.item.data.size() != 4;
    // Optional legality constraint (safety)
    (seq.item.data.size() + seq.item.offset) <= (algn_data_width / 8);
  }

  constraint legal_data {
    seq.item.data.size() > 0;
    seq.item.data.size() <= algn_data_width / 8;
    seq.item.offset < algn_data_width / 8;
    seq.item.data.size() + seq.item.offset <= algn_data_width / 8;
  }

  `uvm_object_utils(cfs_algn_virtual_sequence_rx_exclude_size4)

  function new(string name = "");
    super.new(name);
  endfunction

  function void pre_randomize();
    super.pre_randomize();
    algn_data_width = p_sequencer.model.env_config.get_algn_data_width();
  endfunction

endclass

`endif
