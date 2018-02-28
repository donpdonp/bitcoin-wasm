#include "script/script.h"
#include "script/script_error.h"
#include "script/sign.h"

#include "bridge.h"

extern "C" {

bool scriptRun(int idx)
{
  printf("scriptRun #%d begin\n", idx);
  CScript c = scripts.at(idx);
  //bool EvalScript(vector<vector<unsigned char> >& stack, const CScript& script, unsigned int flags, const BaseSignatureChecker& checker, ScriptError* serror)
  std::vector<std::vector<unsigned char> > stack;
  ScriptError error;
  CTransaction tx;
  int nIn = 0;
  const TransactionSignatureChecker& checker = TransactionSignatureChecker(&tx, nIn);
  bool retval = EvalScript(stack, c, SCRIPT_VERIFY_P2SH, checker, &error);
  if (retval == 0) {
      printf("scriptRun err: %s\n", ScriptErrorString(error));
  } else {
      printf("scriptRun GOOD\n");
  }
  printStack(stack);
  return retval;
}

void printStack(std::vector<std::vector<unsigned char> > stack) {
  printf("scriptRun stack size %d:\n", stack.size());
  for(std::vector<unsigned char>::size_type i = 0; i != stack.size(); i++) {
    std::vector<unsigned char> strvec = stack.at(i);
    std::string str(strvec.begin(), strvec.end());
    printf("scriptRun stack position #%d: %s %d\n", i, str.c_str(), str.c_str()[0]);
  }
}

const int stringCompile(char** opcodeNames, int len){
  printf("stringCompile %d opcode strings \n", len);
  CScript c = CScript();
  for(int i=0; i<len; i++) {
    char* opcodeName = opcodeNames[i];
    if(strlen(opcodeName) > 0) {
      opcodetype opcode = opStringToOpCode(opcodeName);
      if(opcode != OP_INVALIDOPCODE) {
        c << opcode;
        printf("#%d %s opcode\n", i, GetOpName(opcode));
      } else {
        std::string str(opcodeName);
        if (is_digits(str)) {
          int num = std::stoi(str);
          c << CScriptNum(num);
          printf("#%d %d number\n", i, num);
        } else {
          std::vector<unsigned char> vectorString;
          std::copy(str.begin(), str.end(), std::back_inserter(vectorString));
          c << vectorString;
          printf("#%d %s value\n", i, opcodeName);
        }
      }
    }
  }
  scripts.push_back(c);
  return scripts.size()-1;
}

const char* scriptToString(int idx)
{
    return scripts.at(idx).ToString().c_str();
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

bool is_digits(const std::string &str)
{
    return std::all_of(str.begin(), str.end(), ::isdigit); // C++11
}

}

