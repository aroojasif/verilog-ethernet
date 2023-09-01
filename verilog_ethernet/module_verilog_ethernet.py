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

    def get_scoped_constraints(self, files_include=None, files_avoid=None, **kwargs):
        constraints = super().get_scoped_constraints(files_include, files_avoid, **kwargs)

        # Use myy_phy_if.tcl only in implementation.  In synthesis Vivavdo
        # 2023.1 throws a cell not found error.
        mii_phy_if_constraint = next(c for c in constraints if c.file.name == 'mii_phy_if.tcl')
        mii_phy_if_constraint.used_in = "impl"

        return constraints

if __name__ == "__main__":
    m = Module(path=Path(), library_name='verilog_ethernet')
