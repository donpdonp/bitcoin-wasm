#include "script/script.h"
#include "script/script_error.h"
#include "script/sign.h"

extern "C" {

bool jsgo()
{
    printf("jsgo start\n");
    CScript c = CScript() << OP_RETURN;
    //bool EvalScript(vector<vector<unsigned char> >& stack, const CScript& script, unsigned int flags, const BaseSignatureChecker& checker, ScriptError* serror)
    std::vector<std::vector<unsigned char> > stack;
    ScriptError error;
    CTransaction tx;
    int nIn = 0;
    const TransactionSignatureChecker& checker = TransactionSignatureChecker(&tx, nIn);
    bool retval = EvalScript(stack, c, SCRIPT_VERIFY_P2SH, checker, &error);
    if (retval == 0) {
        printf("jsgo err: %s\n", ScriptErrorString(error));
    } else {
        printf("jsgo GOOD\n");
    }
    return retval;
}

const opcodetype** stringCompile(char** opcodes, int len){
  printf("stringCompile %d op:%d len:%d \n", sizeof(char*), opcodes, len);
  opcodetype opcodebytes[] = { OP_RETURN };
  for(int i=0; i<len; i++) {
    char* opcode = opcodes[i];
    printf("stringCompile %d %s\n", i, opcode);
  }
  //return &opcodebytes;
}

const char* scriptToString()
{
    CScript c = CScript();
    c << OP_RETURN;
    return c.ToString().c_str();
}

}

