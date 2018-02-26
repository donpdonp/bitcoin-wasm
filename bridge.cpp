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

const char* jstr()
{
    CScript c = CScript();
    c << OP_RETURN;
    return c.ToString().c_str();
}

}

