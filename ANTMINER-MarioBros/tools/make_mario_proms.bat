copy /b tma1-c-7f_g.7f + tma1-c-7e_g.7e + tma1-c-7d_g.7d cpu_rom1.bin

make_vhdl_prom cpu_rom1.bin cpu_rom1.vhd
make_vhdl_prom tma1-c-7c_g.7c cpu_rom2.vhd

make_vhdl_prom tma1-c-5p.5p adec_5p.vhd
make_vhdl_prom tma1-c-4p.4p clut_4p.vhd

make_vhdl_prom tma1-v-3f.3f gfx_3f.vhd
make_vhdl_prom tma1-v-3j.3j gfx_3j.vhd

make_vhdl_prom tma1-v-7m.7m obj_7m.vhd
make_vhdl_prom tma1-v-7n.7n obj_7n.vhd
make_vhdl_prom tma1-v-7p.7p obj_7p.vhd
make_vhdl_prom tma1-v-7s.7s obj_7s.vhd
make_vhdl_prom tma1-v-7t.7t obj_7t.vhd
make_vhdl_prom tma1-v-7u.7u obj_7u.vhd

make_vhdl_prom tma1-c-6k_e.6k snd_rom.vhd

pause