#include "script/script.h"
#include "script/script_error.h"
#include "script/sign.h"

extern "C" {

const opcodetype opStringToOpCode(char* opName);

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

const CScript* stringCompile(char** opcodeNames, int len){
  printf("stringCompile %d op:%d len:%d \n", sizeof(char*), (int)opcodeNames, len);
  //opcodetype opcodebytes[] = { OP_RETURN };
  CScript c = CScript();
  for(int i=0; i<len; i++) {
    char* opcodeName = opcodeNames[i];
    opcodetype opcode = opStringToOpCode(opcodeName);
    if(opcode != OP_INVALIDOPCODE) {
      c << opcode;
      printf("#%d %s ADDED\n", i, opcodeName);
    } else {
      printf("#%d %s invalid\n", i, opcodeName);
    }
  }
  return &c;
}

const char* scriptToString()
{
    CScript c = CScript();
    c << OP_RETURN;
    return c.ToString().c_str();
}

const opcodetype opStringToOpCode(char* opName) {
  for(int i=0; i <= 0xff; i++) {
    opcodetype opcode = (opcodetype)i;
    const char* maybeName = GetOpName(opcode);
    if(strcmp(opName, maybeName) == 0) {
      return opcode;
    }
  }
  return OP_INVALIDOPCODE;
}

}

