#include "script/script.h"
#include "script/script_error.h"
#include "script/sign.h"
#include "utilstrencodings.h"

#include "bridge.h"

extern "C" {

stackout* bigStack;

stackout* scriptRun(int idx)
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
  return stackToCharArray(stack);
}


stackout* stackToCharArray(std::vector<std::vector<unsigned char> > stack) {
  bigStack = (stackout*)malloc(sizeof(stackout));
  int size = stack.size();
  bigStack->stack = (char**)malloc(sizeof(char*)*size);
  bigStack->len = size;
  for(std::vector<unsigned char>::size_type i = 0; i != size; i++) {
    std::vector<unsigned char> strvec = stack.at(i);
    int vsize = strvec.size();
    char* c_copy = new char[vsize + 1];
    memcpy(c_copy, (char*)strvec.data(), vsize );
    c_copy[vsize] = '\0';
    bigStack->stack[i] = (char*)c_copy;
  }
  return bigStack;
}

void printStack(std::vector<std::vector<unsigned char> > stack) {
  printf("scriptRun stack size %d:\n", stack.size());
  for(std::vector<unsigned char>::size_type i = 0; i != stack.size(); i++) {
    std::vector<unsigned char> strvec = stack.at(i);
    std::string str(strvec.begin(), strvec.end());
    char* strline = (char*)str.c_str();
    printf("scriptRun stack position #%d: heap:%d %s %d\n", i, (int)strline, strline, strline[0]);
  }
}

const int stringCompile(char** opcodeNames, int len){
  printf("stringCompile %d opcode strings \n", len);
  CScript c = CScript();
  for(int i=0; i<len; i++) {
    char* opcodeName = opcodeNames[i];
    if(strlen(opcodeName) > 0) {
      if(strlen(opcodeName) > 2 && opcodeName[0] == 'O' && opcodeName[1] == 'P') {
        opcodetype opcode = opStringToOpCode(opcodeName);
        if(opcode != OP_INVALIDOPCODE) {
          c << opcode;
          printf("#%d %x %s opcode\n", i, opcode, GetOpName(opcode));
        } else {
          printf("#%d %s BAD opcode\n", i, opcodeName);
        }
      } else {
        std::string str(opcodeName);
        if (is_digits(str)) { // use a CScriptNum for signed 32-bit numbers
          int num = std::stoi(str);
          c << CScriptNum(num);
          printf("#%d %d (0x%x) number\n", i, num, num);
        } else {
          std::vector<unsigned char> vectorString;
          std::copy(str.begin(), str.end(), std::back_inserter(vectorString));
          c << vectorString;
          printf("#%d %x value (datalen %d)\n", i, opcodeName[0], (sizeof opcodeName[0]));
        }
      }
    }
    printf("#%d script opcount: %d hex: %s\n", i, scriptCount(c), HexStr(c).c_str());
  }
  printf("final script opcount: %d hex: %s\n", scriptCount(c), HexStr(c).c_str());
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

int scriptCount(CScript c) {
  int count = 0;
  CScript::const_iterator pc = c.begin();
  opcodetype opcode;
  std::vector<unsigned char> vch;

  while (pc < c.end()) {
    if (!c.GetOp(pc, opcode, vch)) {
      return -1;
    } else {
      count += 1;
    }
    if (0 <= opcode && opcode <= OP_PUSHDATA4) {
    }
  }
  return count;
}

}

