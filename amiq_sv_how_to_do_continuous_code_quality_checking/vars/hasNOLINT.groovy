def call(String commit){
    String commitMsg = ""
    List commitMsgPre = commit.split(" ")

    for(int i=1; i<commitMsgPre.size(); i++){
        if (commitMsgPre.getAt(i) == "NOLINT"){
            println('FOUND NOLINT')
            return true;
        }
    }
    return false;
}
