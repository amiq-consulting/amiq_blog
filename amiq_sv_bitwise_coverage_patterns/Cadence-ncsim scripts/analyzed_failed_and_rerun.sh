#!/bin/sh

REGRESSION_ID=`echo ${BRUN_SESSION_DIR} | sed -e 's/.*regression\/\(.*\)$/\1/g'`
FILE_PATH=${BRUN_SESSION_DIR}/${REGRESSION_ID}_reg_ended.txt
CLEARCASE_VIEW_NAME=`cleartool pwv | grep "Set view" |sed -e 's/^Set view: \(.*$\)/\1/g'`
SAVE_REPORT_LOCATION=/proj

RECIPIENT=email@domain.com

echo "Create analysis ecom file..."

cat > ${BRUN_SESSION_DIR}/do_analysis.ecom << EOF
-- load analyzer sources
load ${ANALYZER_DIR_ENV_VAR}/vm_analyzer.e
-- do emanager setup 
setup
-- load the current session vsof
var current_session:vm_vsof = vm_manager.read_session("${BRUN_VSOF}");
-- do analysis, and if there are failures, dump vsif
var vfile:string=current_session.dump_status_mail("${FILE_PATH}","${BRUN_VSOF}");
if (current_session.collect_failure_groups()) { current_session.create_debug_vsif("${BRUN_SESSION_DIR}"); };

EOF

cd ${VM_FOLDER_ENV_VAR}

echo "Start the analysis..."

cat > ${FILE_PATH} <<EOCAT
Subject:[PROJECT] [BLOCK] [REGRESSION ENDED] [${PROJ}] ${REGRESSION_ID} 
MIME-Version: 1.0
Content-Type: text/html
Content-Disposition: inline
<html>
<body>
<P>
EOCAT

emanager -b -c " @${BRUN_SESSION_DIR}/do_analysis.ecom"

cleartool catcs > temp.txt
sed -e 's/$/\<BR\>/g' temp.txt >> ${FILE_PATH}

cat >> ${FILE_PATH} <<EOCAT
</P><P>
<B>PAY ATTENTION!</B> The following files are checked-out in the view &lt; ${CLEARCASE_VIEW_NAME} &gt; where the regression has been started:<BR>
EOCAT

cleartool lsco -me -cview -avobs | grep /vobs/asic > temp.txt
sed -e 's/$/\<BR\>/g' temp.txt >> ${FILE_PATH}
echo "<BR>" >>  ${FILE_PATH}
echo "<B>SPECMAN_PATH</B> is set to: ${SPECMAN_PATH} <BR>" | sed -e 's/:/:\<BR\>/g' >> ${FILE_PATH}

cat >> ${FILE_PATH} <<EOCAT
</P>
<DIV ALIGN=CENTER>
<P>
<<< ---------------------------------------------------------------------------------- >>> <BR>
<<< THIS IS AN AUTOMATED MAIL SENT BY THE REGRESSION SCRIPT >>> <BR>
<<< ---------------------------------------------------------------------------------- >>> <BR>
</P>
</DIV>
</body>
</html>
EOCAT

cat ${FILE_PATH} | sendmail ${RECIPIENT}

#save the report in a specific location
cp ${FILE_PATH} ${SAVE_REPORT_LOCATION}

emanager -p "start_session -vsif ${BRUN_SESSION_DIR}/rerun_failures_with_wave_dump.vsif" &

exit 0