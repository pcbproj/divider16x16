derive_pll_clocks

derive_clock_uncertainty

create_clock -name clk -period 20 [get_ports clk]

# описание сигнала wr_valid для защелкивания данных в divider16x16b
create_generated_clock -name wr_valid -source [get_ports {clk}] -divide_by 100000 -duty_cycle 20.000 [get_nets {pulse_gen|Output}]

#set_false_path -from [get_clocks {clk}] -to [get_clocks {wr_valid}]

set_clock_groups -logically_exclusive -group [get_clocks {clk}] -group [get_clocks {wr_valid}]
