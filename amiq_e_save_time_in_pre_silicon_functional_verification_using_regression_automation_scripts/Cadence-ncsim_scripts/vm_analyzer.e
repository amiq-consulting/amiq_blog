/***********************************************************************
* Copyright (2015) AMIQ Consulting
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* MODULE:      BLOG
* PROJECT:     Save Time in Pre-Silicon Functional Verification Using Regression Automation Scripts
* Description: This is a code snippet from the Blog article mentioned on PROJECT
*              This file analyzes the regression and creates an email with data from regression
* Link:        https://www.amiq.com/consulting/2014/07/04/save-time-in-pre-silicon-functional-verification-using-regression-automation-scripts
***********************************************************************/

<'

struct batch_dump_waves_rerun_scheme like vm_rerun_scheme{
	get_name() : string is {
		return "BATCH_DUMP_WAVES";
	};

	finalize_session(session: vm_vsif, orig_session: vm_vsof) is {
		var attr := vm_manager.get_attribute_by_name("post_session_script");
		orig_session.set_attribute_value(attr, "");	
	};

	finalize_test(test: vm_test, orig_run: vm_run) is {
		var attr := vm_manager.get_attribute_by_name("sim_init_file");
		orig_run.set_attribute_value(attr, "$ENV(WAVE_DUMP_DIR_ENV_VAR)/wave_dump.tcl");		
	};

	copy_session_attribute(attr: vm_attribute, orig_session: vm_vsof) : bool  is {
		result = TRUE;
	};
	copy_run_attribute(attr: vm_attribute, orig_run:vm_run) : bool is {
		result = TRUE;
	};
};
extend vm_manager {
	setup() is also {
		register_rerun_scheme("BATCH_DUMP_WAVES", new batch_dump_waves_rerun_scheme);
	};
};

struct vm_failure_group_s {
	!kind : string;
	!lof_runs : list of vm_run;
	sort_by_min_cpu_time() is {
		var vana : list of vm_run;
		vana = lof_runs.sort(convert_to_uint(it));
		lof_runs = vana;
	};
	convert_to_uint(arg : vm_run): uint is {
		var my_cpu_time: vm_attribute = vm_manager.get_attribute_by_name("cpu_time"); // Get the Run Id.
		if (arg.get_attribute_value(my_cpu_time) == "") {
			return 0;
		} else {
			return arg.get_attribute_value(my_cpu_time).as_a(uint);
		};
	};
	
	dump_text() : list of string is {
		result.add("");
	};
};


struct run_info_s {
	!test_name : string;
	!seed : string;
	!cpu_time : string;
	!failure_kind : string;
	!first_failure_description : string;
	!run_id : string;
	!first_failure_time : string;
};

//extending the session container
extend vm_vsof {
	!lof_failure_group : list of vm_failure_group_s;
	!to_debug : vm_failure_group_s;
	!passing_tests : list of run_info_s;
	!failing_tests : list of run_info_s;
	!unfinished_tests : list of run_info_s;
	
	write_to_file(ex_file: string, text:string) is {
		var m_file: file;
		m_file = files.open(ex_file, "a", "Text file");--open file for appending
		files.write(m_file, text);
		files.close(m_file);
	};
	
	cpu_time_string_to_time(inp:string):string is {
		if (inp == ""){
			return inp;
		};
		var mtime : uint = inp.as_a(uint);
		
		mtime = mtime/1000; -- get rid of miliseconds
		
		result = appendf("%dh:%dm:%ds", mtime/3600, (mtime%3600)/60, mtime%60);
	};
	
	dump_status_mail(file_path : string, vsof:string):string is {
		var status_mail : string = "Hi team!<BR><BR>Here is the status of the regression:<BR>";
		var count_fail : uint;
		var list_of_runs: list of vm_run = get_runs();
		var number_of_runs : uint = list_of_runs.size();
		
		var my_run_id: vm_attribute= vm_manager.get_attribute_by_name("run_id"); // Get the Run Id.
		var run_status_attr: vm_attribute = vm_manager.get_attribute_by_name("job_status"); // Get the job status
		var top_file_attribute: vm_attribute= vm_manager.get_attribute_by_name("top_files"); // Get the Run Id.
		var seed_attribute : vm_attribute = vm_manager.get_attribute_by_name("seed");
		var cpu_time_attribute : vm_attribute = vm_manager.get_attribute_by_name("cpu_time");
		var kind_attribute : vm_attribute = vm_manager.get_attribute_by_name("first_failure_kind");
		var first_failure_description_attribute : vm_attribute = vm_manager.get_attribute_by_name("first_failure_description");
		var first_failure_attribute : vm_attribute = vm_manager.get_attribute_by_name("first_failure_time");
		
		var run_status: string= "";
		var id: string= "";
		var vfailkind : string = ""; 
		var fgi : int = UNDEF;

		for each (run) in list_of_runs {
			run_status= run.get_attribute_value(run_status_attr);
			
			var vtest : run_info_s = new;
			vtest.test_name = run.get_attribute_value(top_file_attribute);
			vtest.seed = run.get_attribute_value(seed_attribute);
			vtest.cpu_time = run.get_attribute_value(cpu_time_attribute);
			vtest.failure_kind = run.get_attribute_value(kind_attribute);
			vtest.first_failure_description = run.get_attribute_value(first_failure_description_attribute);
			vtest.run_id = run.get_attribute_value(my_run_id);
			vtest.first_failure_time = run.get_attribute_value(first_failure_attribute);
			if run_status == "finished" {
				if (run.get_status() == "failed") {
					failing_tests.add(vtest);
					var first_fail : vm_failure;
					first_fail = run.get_first_failure();
					vfailkind = first_fail.get_value("kind");
					if (not lof_failure_group.has(it.kind == vfailkind)) {
						var vfg : vm_failure_group_s = new;
						vfg.kind = vfailkind;
						lof_failure_group.add(vfg);
					};
					fgi = lof_failure_group.first_index(it.kind == vfailkind);
					lof_failure_group[fgi].lof_runs.add(run);
					
				} else if (run.get_status() == "passed") {
					passing_tests.add(vtest);
				};
			} else {
				unfinished_tests.add(vtest);
			};
		};
		
		status_mail = appendf("%s</P><P><B>TOTAL tests run: %d</B><BR>",status_mail,number_of_runs);
		status_mail = appendf("%s<B>PASSED: %d</B><BR>",status_mail, passing_tests.size());
		status_mail = appendf("%s<B>FAILED: %d</B><BR><BR>",status_mail, failing_tests.size());
		status_mail = appendf("%s<B>FAILURE GROUPS: %d</B><BR><BR>",status_mail, lof_failure_group.size());
		status_mail = appendf("%s<B>VSOF</B>: %s<BR><BR></P><P>",status_mail, vsof);
		
//		if (passing_tests.size()!=0){
//			status_mail = appendf("%sPASSED tests:<BR><BR>",status_mail);
//		};
//		for each (test) in passing_tests {
//			status_mail = appendf("%s%s (seed=%s) (CPU_time=%s)<BR>",status_mail, test.test_name, test.seed, test.cpu_time);
//		};
		
		if (unfinished_tests.size()!=0){
			status_mail = appendf("%s</P><P><B>UNFINISHED</B> tests: [(%d/%d)]<BR><BR>",status_mail, unfinished_tests.size(), number_of_runs);
		};
		for each (test) in unfinished_tests {
			status_mail = appendf("%s%s (seed=%s) (CPU_time=%s)<BR>First failure description:%s<BR>",
			status_mail, test.test_name, test.seed, cpu_time_string_to_time(test.cpu_time), test.first_failure_description);
		};
		
		lof_failure_group = lof_failure_group.sort(it.lof_runs.size());
		lof_failure_group = lof_failure_group.reverse();
		
		for each (fg) in lof_failure_group {
			fg.sort_by_min_cpu_time();
			var kind := fg.lof_runs[0].get_attribute_value(kind_attribute);
			status_mail = appendf("%s</P><P><B>FAIL GROUP %d:</B>[(%d/%d)] %s <BR>",status_mail, index+1, fg.lof_runs.size(), number_of_runs, kind);
			
			var lof_runs := fg.lof_runs;
			var lof_testcases : list of string;
			for each (run) in lof_runs {
				lof_testcases.add(run.get_attribute_value(top_file_attribute));
			};
			lof_testcases = lof_testcases.sort(it);
			lof_testcases = lof_testcases.unique(it);
			
			for i from 0 to min(2, fg.lof_runs.size()-1) {
				var seed_no := fg.lof_runs[i].get_attribute_value(seed_attribute);
				var top := fg.lof_runs[i].get_attribute_value(top_file_attribute);
				var cpu_time := fg.lof_runs[i].get_attribute_value(cpu_time_attribute);
				var first_failure_time := fg.lof_runs[i].get_attribute_value(first_failure_attribute);
				
				status_mail = appendf("%s%s - seed %s (first_failure_time:%s) (CPU_time: %s)<BR>",
				status_mail, top, seed_no, first_failure_time, cpu_time_string_to_time(cpu_time));
			};
			status_mail = appendf("%sFailing Testcases:<BR>",status_mail);
			for each (tc) in lof_testcases {
				status_mail = appendf("%s%s<BR>",status_mail, tc);
			};
		};
		
		status_mail = appendf("%s\n\n</P><P><B>CONFIG SPEC</B>:<BR>",status_mail);
		
		write_to_file(file_path,status_mail);
		return file_path;
	};

	// This method analyzes the entire regression to find out runs which have failed.
	collect_failure_groups() : bool is {
		var run_status: string= "";
		var id: string= "";
		var vfailkind : string = ""; 
		var fgi : int = UNDEF;
		var my_vsof : vm_vsof;


		var my_run_id: vm_attribute= vm_manager.get_attribute_by_name("run_id"); // Get the Run Id.
		var run_status_attr: vm_attribute = vm_manager.get_attribute_by_name("job_status"); // Get the job status
		var list_of_runs: list of vm_run = get_runs();

		for each (run) in list_of_runs {
			run_status= run.get_attribute_value(run_status_attr);

			id = run.get_attribute_value(my_run_id);
			if run_status == "finished" {
				if (run.get_status() == "failed") {
					var fail : vm_failure;
					fail = run.get_first_failure();
					vfailkind = fail.get_value("kind");
					if (not lof_failure_group.has(it.kind == vfailkind)) {
						var vfg : vm_failure_group_s = new;
						vfg.kind = vfailkind;
						lof_failure_group.add(vfg);
					};
					fgi = lof_failure_group.first_index(it.kind == vfailkind);
					lof_failure_group[fgi].lof_runs.add(run);
				};
			};
		};
		return (not lof_failure_group.is_empty());
	};

	create_debug_vsif(apath : string) is {
		to_debug = new;
		for each (fg) in lof_failure_group {
			fg.sort_by_min_cpu_time();
			to_debug.lof_runs.add(fg.lof_runs[0]);
		};
		var vcontext : vm_context = vm_manager.create_context(to_debug.lof_runs.as_a(list of vm_attribute_container), "First_Failures");
		vcontext.create_rerun_vsif(append(apath, "/rerun_failures_with_wave_dump.vsif"), vm_manager.obtain_rerun_scheme("BATCH_DUMP_WAVES"));
		vcontext.create_rerun_vsif(append(apath, "/rerun_failures_with_wave_dump.vsif"), vm_manager.obtain_rerun_scheme("BATCH_DUMP_WAVES"));
	};
};


'>


