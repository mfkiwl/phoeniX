MODULE=phoeniX_Testbench
WARNING_OPTIONS=-Wno-UNOPTFLAT

verilator $WARNING_OPTIONS ${MODULE}.v --top $MODULE -IModules --trace --timing --binary -j 4
make -C obj_dir -f V${MODULE}.mk V${MODULE}
./obj_dir/V${MODULE}
rm -rf ./obj_dir