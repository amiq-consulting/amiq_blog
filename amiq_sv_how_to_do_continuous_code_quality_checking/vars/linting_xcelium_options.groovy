def call(){
    sh 'source /apps/source.apps ; verissimo.sh -cmd $PROJ_HOME/sim/xcelium.options -ruleset $PROJ_HOME/.dvt/utils/lint/internship_lint_aesthetic_rules.xml -waivers $PROJ_HOME/.dvt/utils/lint/verissimo_waivers.xml -gen_txt_report -gen_html_report -include_html_code -gen_custom_report /proj/vmngr/dvci/CustomReport.txt.ftl'
}
