#!/bin/sh

CLEARCASE_VIEW_NAME=`cleartool pwv | grep "Set view" |sed -e 's/^Set view: \(.*$\)/\1/g'`
REGRESSION_ID=`echo ${BRUN_SESSION_DIR} | sed -e 's/.*regression\/\(.*\)$/\1/g'`
FILE_PATH=${BRUN_SESSION_DIR}/${REGRESSION_ID}_reg_started.txt
SAVE_REPORT_LOCATION=/proj

RECIPIENT=email@domain.com


cat > ${FILE_PATH} <<EOCAT
Subject:[PROJECT] [BLOCK] [REGRESSION STARTED] [${PROJ}] ${REGRESSION_ID} 
MIME-Version: 1.0
Content-Type: text/html
Content-Disposition: inline
<html>
<body>
<P>
Hi team! <BR>
</P>

<P>
We have just started the following regression: <BR>
${BRUN_VSOF}
</P>

<B>CONFIG SPEC used:</B> <BR>
<P>
EOCAT

cleartool catcs > temp.txt
sed -e 's/$/\<BR\>/g' temp.txt >> ${FILE_PATH}

cat >> ${FILE_PATH} <<EOCAT
</P><P>
<B>PAY ATTENTION!</B> The following files are checked-out in the view &lt; ${CLEARCASE_VIEW_NAME} &gt; where the regression has been started:<BR>
EOCAT

#find out the checked out files from the current view
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

#save the report in a configured location
cp ${FILE_PATH} ${SAVE_REPORT_LOCATION}

exit 0