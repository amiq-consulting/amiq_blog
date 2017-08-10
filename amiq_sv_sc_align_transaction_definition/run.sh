#!/bin/sh

export UVM_ML_HOME=`sn_root`/tools/methodology/UVM/CDNS-1.2-ML
export PROJECT_HOME=`pwd`
rm -rf INCA_libs
irun -f run.options
