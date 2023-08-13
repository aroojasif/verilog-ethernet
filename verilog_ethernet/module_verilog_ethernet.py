#!/usr/bin/env python3
#
# Copyright 2023 Nico De Simone.

from pathlib import Path
from tsfpga.module import BaseModule
from tsfpga.hdl_file import HdlFile

class Module(BaseModule):
    @property
    def synthesis_folders(self):
        """
        Synthesis/implementation source code files will be gathered from these folders.

        Return:
            list(pathlib.Path): Folder paths.
        """
        synthesis_folders = super().synthesis_folders
        synthesis_folders.append(
            self.path / "../rtl",
        )
        return synthesis_folders

    @property
    def sim_folders(self):
        """
        Synthesis/implementation source code files will be gathered from these folders.

        Return:
            list(pathlib.Path): Folder paths.
        """
        sim_folders = super().sim_folders
        sim_folders.append(
            self.path / "../tb",
        )
        return sim_folders


if __name__ == "__main__":
    m = Module(path=Path(), library_name='verilog_ethernet')
