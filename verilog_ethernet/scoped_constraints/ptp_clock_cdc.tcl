# Copyright (c) 2019-2021 Alex Forencich
# Copyright (c) 2020 Nico De Simone
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# PTP timestamp capture module

puts "Inserting timing constraints for ptp_clock_cdc instances"

# get clock periods
set input_clk [get_clocks -of_objects [get_pins "src_sync_reg_reg/C"]]
set output_clk [get_clocks -of_objects [get_pins "dest_sync_reg_reg/C"]]

set input_clk_period [if {[llength $input_clk]} {get_property -min PERIOD $input_clk} {expr 1.0}]
set output_clk_period [if {[llength $output_clk]} {get_property -min PERIOD $output_clk} {expr 1.0}]

# timestamp synchronization
set_property ASYNC_REG TRUE [get_cells -hier -regexp ".*/ts_(s|ns|fns|step)_sync_reg_reg(\\\[\\d+\\\])?"]

if {[llength [get_cells "src_ts_s_capt_reg_reg[*]"]]} {
    set_max_delay -from [get_cells "src_ts_s_capt_reg_reg[*]"] -to [get_cells "ts_s_sync_reg_reg[*]"] -datapath_only $output_clk_period
    set_bus_skew  -from [get_cells "src_ts_s_capt_reg_reg[*]"] -to [get_cells "ts_s_sync_reg_reg[*]"] $input_clk_period
}

set_max_delay -from [get_cells "src_ts_ns_capt_reg_reg[*]"] -to [get_cells "ts_ns_sync_reg_reg[*]"] -datapath_only $output_clk_period
set_bus_skew  -from [get_cells "src_ts_ns_capt_reg_reg[*]"] -to [get_cells "ts_ns_sync_reg_reg[*]"] $input_clk_period

set_max_delay -from [get_cells "src_ts_fns_capt_reg_reg[*]"] -to [get_cells "ts_fns_sync_reg_reg[*]"] -datapath_only $output_clk_period
set_bus_skew  -from [get_cells "src_ts_fns_capt_reg_reg[*]"] -to [get_cells "ts_fns_sync_reg_reg[*]"] $input_clk_period

if {[llength [get_cells "src_ts_step_capt_reg_reg"]]} {
    set_max_delay -from [get_cells "src_ts_step_capt_reg_reg"] -to [get_cells "ts_step_sync_reg_reg"] -datapath_only $output_clk_period
    set_bus_skew  -from [get_cells "src_ts_step_capt_reg_reg"] -to [get_cells "ts_step_sync_reg_reg"] $input_clk_period
}

# sample clock
set sync_ffs [get_cells -quiet -hier -regexp ".*/src_sync_sample_sync\[12\]_reg_reg"]

if {[llength $sync_ffs]} {
    set_property ASYNC_REG TRUE $sync_ffs

    set_max_delay -from [get_cells "src_sync_reg_reg"] -to [get_cells "src_sync_sample_sync1_reg_reg"] -datapath_only $input_clk_period
}

set sync_ffs [get_cells -quiet -hier -regexp ".*/dest_sync_sample_sync\[12\]_reg_reg"]

if {[llength $sync_ffs]} {
    set_property ASYNC_REG TRUE $sync_ffs

    set_max_delay -from [get_cells "dest_sync_reg_reg"] -to [get_cells "dest_sync_sample_sync1_reg_reg"] -datapath_only $output_clk_period
}

# sample update sync
set sync_ffs [get_cells -quiet -hier -regexp ".*/sample_update_sync\[123\]_reg_reg"]

if {[llength $sync_ffs]} {
    set_property ASYNC_REG TRUE $sync_ffs

    set src_clk [get_clocks -of_objects [get_pins "sample_update_reg_reg/C"]]

    set src_clk_period [if {[llength $src_clk]} {get_property -min PERIOD $src_clk} {expr 1.0}]

    set_max_delay -from [get_cells "sample_update_reg_reg"] -to [get_cells "sample_update_sync1_reg_reg"] -datapath_only $src_clk_period

    set_max_delay -from [get_cells "sample_acc_out_reg_reg[*]"] -to [get_cells sample_acc_sync_reg_reg[*]] -datapath_only $src_clk_period
    set_bus_skew  -from [get_cells "sample_acc_out_reg_reg[*]"] -to [get_cells sample_acc_sync_reg_reg[*]] $output_clk_period
}

# no sample clock
set sync_ffs [get_cells -quiet -hier -regexp ".*/src_sync_sync\[12\]_reg_reg"]

if {[llength $sync_ffs]} {
    set_property ASYNC_REG TRUE $sync_ffs

    set_max_delay -from [get_cells "src_sync_reg_reg"] -to [get_cells "src_sync_sync1_reg_reg"] -datapath_only $input_clk_period
}
