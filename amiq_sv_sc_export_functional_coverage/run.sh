#!/bin/sh

export UVM_ML_HOME=`sn_root`/tools/methodology/UVM/CDNS-1.2-ML
export PROJECT_HOME=`pwd`

irun -f run.options
