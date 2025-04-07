#!/usr/bin/env python3

# Copyright 2025 Arooj Asif.

from pathlib import Path
from tsfpga.module import BaseModule
from tsfpga.hdl_file import HdlFile

class Module(BaseModule):
    def __init__(self):
        super().__init__(path=Path(__file__).parent.resolve(), library_name="verilog_ethernet")

    def get_synthesis_files(self, **kwargs):
        folders = [self.path.parent / "rtl"]

        files = [
            HdlFile(file_path)
            for file_path in self._get_file_list(
                    folders=folders, file_endings=(".vhd", ".vhdl", ".v")
            )
        ]
        print("Synthesis files:", [str(f.path) for f in files])
        return files

    def get_simulation_files(self, **kwargs):
        folders = [self.path.parent / "rtl", self.path.parent / "test"]
        return [
            HdlFile(file_path)
            for file_path in self._get_file_list(
                folders=folders, file_endings=(".vhd", ".vhdl", ".v")
            )
        ]

if __name__ == "__main__":
    m = Module()

    print("Synthesis files:")
    for f in m.get_synthesis_files():
        print(" →", f.path)

    print("Simulation files:")
    for f in m.get_simulation_files():
        print(" →", f.path)
