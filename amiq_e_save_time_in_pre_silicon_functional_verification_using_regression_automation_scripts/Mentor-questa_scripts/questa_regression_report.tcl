#!/usr/bin/tclsh

#/***********************************************************************
#* Copyright (2015) AMIQ Consulting
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#*    http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#*
#* MODULE:      BLOG
#* PROJECT:     Save Time in Pre-Silicon Functional Verification Using Regression Automation Scripts
#* Description: This is a code snippet from the Blog article mentioned on PROJECT
#*              This file analyzes the regression and creates an email with data from regression
#* Link:        https://www.amiq.com/consulting/2014/07/04/save-time-in-pre-silicon-functional-verification-using-regression-automation-scripts
#***********************************************************************/

# Proc that parses a transcript file in order to extract the test name, the seed and the error message IDs
proc parse_transcript {transcript} {

	set tfp [open $transcript r]
	set tdata [read $tfp]
	close $tfp
	set data [split $tdata "\n"]

	# Get test name
	foreach line $data {
		set result [regexp -all -inline {\+UVM_TESTNAME=([a-zA-Z0-9_]+)} $line]
		if {$result!=""} {
			set uvm_test_name [lindex $result 1]
			break
		}
	}

	# Get error IDs
	set uvm_err_ids {}
	foreach line $data {
		set result [regexp -all -inline {\#\s(UVM_ERROR|UVM_FATAL)\s@\s[0-9]+\s\[([a-zA-Z0-9_]+)\]} $line]
		if {$result!=""} {
			lappend uvm_err_ids [list [lindex $result 1] [lindex $result 2]]
		} elseif {[regexp -all -inline {\*\*\s(Fatal|Error):\s(.*)$} $line] != ""} {
			set result [regexp -all -inline {\*\*\s(Fatal|Error):\s(.*)$} $line]
			if {$result!=""} {
				lappend uvm_err_ids [list [lindex $result 1] [lindex $result 2]]
			}
		} elseif {[regexp -all -inline {Break key hit} $line] != ""} {
			set result [regexp -all -inline {(Break key hit)} $line]
			if {$result!=""} {
				lappend uvm_err_ids [list [lindex $result 0] [lindex $result 1]]
			}
		}
	}
	
	# Get test seed
	foreach line $data {
		set result [regexp -all -inline {^\#\sSv_Seed\s=\s([0-9]+)} $line]
		if {$result!=""} {
			set uvm_test_seed [lindex $result 1]
			break
		} else {
			set result [regexp -all -inline {sv_seed\s([0-9]+)} $line]
			if {$result!=""} {
				set uvm_test_seed [lindex $result 1]
				break
			}
		}
	}
	
	set uvm_last_err_id [lindex [lindex $uvm_err_ids end] 1]
	
        if { $uvm_last_err_id!={} } {
        	set test_status "Failed"
        } else {
        	set test_status "Passed"
        }
	
	return [list $uvm_test_name $uvm_test_seed $test_status $uvm_last_err_id $uvm_err_ids]
}



# Set main regression folder(e.g. eth_regression) - where all regressions lie
set folder [lindex $argv 0]
set sim_location "$folder/my_run/setup~DEFAULT_SETUP/all_simulations"
set test_results {}
set test_failures {}

# Get regression name
set regr_name [lindex [split $folder "/"] end]

puts "Top folder is : $folder"

puts "questa_regression_report.tcl : Parsing transcript files..."
foreach sim_folder [glob  -directory $sim_location -type d Sim*] {
	set transcript "$sim_folder/execScript.log"
	set test_data [parse_transcript $transcript]
	set test_status [lindex $test_data 2]
        if {$test_status=="Failed"} {
        	set err_id [lindex $test_data 3]
        	lappend test_failures [lindex $test_data 3]
	}
    	lappend  test_results $test_data
}
puts "questa_regression_report.tcl : Processing test resutls..."
# Make a list of unique last error IDs
set test_failures [lsort -unique $test_failures]
puts "Unique list of failures  : \n$test_failures"
puts "questa_regression_report.tcl : Writing regression report..."
set regr_rpt [open "regr_rpt.txt" w]
set passed_count 0
set failed_count 0
set total_tests [llength $test_results]
foreach test_run $test_results {
	if {[lindex $test_run 2]=="Passed"} {
		set passed_count  [expr $passed_count+1]
	} else { 
		set failed_count [expr $failed_count+1]
	}
}

puts $regr_rpt "This is the status for regression $folder\n"

puts $regr_rpt "TOTAL tests run: [llength $test_results]"
puts $regr_rpt "PASSED: $passed_count"
puts $regr_rpt "FAILED: $failed_count"
puts $regr_rpt " "

puts $regr_rpt "Location of simulation folders : $sim_location"

# For each unique error message
puts $regr_rpt "The following FAIL GROUPS have been detected : "
puts $regr_rpt " "
set err_stats {}
foreach err_id $test_failures {
	set count 0
	set err_id_fails {}
	foreach test_run $test_results {
		if {[lindex $test_run 2]=="Failed"} {
			if {[lindex $test_run 3]==$err_id} { 
				set count [expr $count+1] 
				lappend err_id_fails [list [lindex $test_run 0] [lindex $test_run 1]]
			}
		}
	}
	
	lappend err_stats [list $err_id $count $err_id_fails]

}

set err_stats [lsort -decreasing -integer -index 1 $err_stats]

foreach err_stat $err_stats {
	set err_id [lindex $err_stat 0]
	set count [lindex $err_stat 1]
	set err_id_fails [lindex $err_stat 2]
	puts $regr_rpt "* $err_id : $count/$total_tests"
	set i 0
	foreach fail $err_id_fails {
		set i [expr $i+1]
		if {$i>3} break
		puts $regr_rpt "** UVM_TESTNAME=[lindex $fail 0] SEED=[lindex $fail 1]"
	}
	puts $regr_rpt " "
}	

puts $regr_rpt " "
puts $regr_rpt "The following CS was used : \n"
puts $regr_rpt "########### CS-BEGIN ####### \n"
puts $regr_rpt [exec cleartool catcs]
puts $regr_rpt "########### CS-END ######### \n"
puts $regr_rpt "PAY ATTENTION!!! : The following files were checked out from view <[exec cleartool pwv -short]>: \n"
puts $regr_rpt [exec cleartool lsco -avobs -cview]

close $regr_rpt

# Send email
puts "reg_rep.tcl : Sending email..."

set mail_recipients "recipients@company.com"
set mail_subject "\[PROJECT\]\[REGRESSION\]$regr_name"
exec /bin/mail -s $mail_subject $mail_recipients < regr_rpt.txt

puts "reg_rep.tcl : Done."

