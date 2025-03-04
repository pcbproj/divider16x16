radix -unsigned

add wave *
add wave sim:/divider16x16_tb/uut/up
add wave sim:/divider16x16_tb/uut/down
add wave sim:/divider16x16_tb/uut/temp
add wave sim:/divider16x16_tb/uut/b
add wave sim:/divider16x16_tb/uut/result
add wave sim:/divider16x16_tb/uut/rd_valid_tmp



view structure
view signals

run 10 us
