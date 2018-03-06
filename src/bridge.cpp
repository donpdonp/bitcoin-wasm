#include "config/bitcoin-config.h"
#include "script/script.h"
#include "script/script_error.h"
#include "script/sign.h"
#include "utilstrencodings.h"

#include "bridge.h"

extern "C" {

stackout* 
scriptRun(int idx)
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
      printf("scriptRun FAIL: %s\n", ScriptErrorString(error));
  } else {
      printf("scriptRun GOOD\n");
  }
  stackout* stackRun = stackToCharArray(stack);
  stackRun->success = retval;
  return stackRun;
}


stackout* 
stackToCharArray(std::vector<std::vector<unsigned char> > stack) 
{
  stackout* bigStack = (stackout*)malloc(sizeof(stackout));
  int size = stack.size();
  bigStack->stack = (char**)malloc(sizeof(char*)*size);
  bigStack->len = size;
  for(std::vector<unsigned char>::size_type i = 0; i != size; i++) {
    std::vector<unsigned char> strvec = stack.at(i);
    bigStack->stack[i] = strvecToSizedCharPtr(&strvec);
  }
  return bigStack;
}

char* 
strvecToSizedCharPtr(std::vector<unsigned char>* strvec) {
  uint8_t vsize = strvec->size();
  char* c_copy = new char[vsize + 1];
  memcpy(c_copy+1, (char*)strvec->data(), vsize );
  c_copy[0] = vsize;
  return c_copy;
}

const int 
stringCompile(char** opcodeNames, int len)
{
  printf("stringCompile %d opcode strings \n", len);
  CScript c = CScript();
  for(int i=0; i<len; i++) {
    char* opcodeName = opcodeNames[i];
    printf("#%d encoding %s \n", i, opcodeName);
    encodeOp(&c, opcodeName);
  }
  printf("script opcount: %d hex: %s\n", scriptCount(c), HexStr(c).c_str());
  scripts.push_back(c);
  return scripts.size()-1;
}

void 
encodeOp(CScript* c, char* opcodeName) 
{
  if(strlen(opcodeName) > 0) {
    if(strlen(opcodeName) >= 2 && opcodeName[0] == 'O' && opcodeName[1] == 'P') {
      opcodetype opcode = opStringToOpCode(opcodeName);
      if(opcode != OP_INVALIDOPCODE) {
        *c << opcode;
        printf("%x %s opcode\n", opcode, GetOpName(opcode));
      } else {
        printf("%s BAD opcode\n", opcodeName);
      }
    } else if (strlen(opcodeName) > 10 && opcodeName[0] == '0' && opcodeName[1] == 'X') { // more than 4 bytes is a data value
      std::vector<unsigned char> byteString;
      for(int i=2; i < strlen(opcodeName); i+=2) {
        char minichar[5] = "0x";
        minichar[2] = opcodeName[i];
        minichar[3] = opcodeName[i+1];
        minichar[4] = 0;
        char c = (char)std::stoi(minichar, 0, 16);
        byteString.push_back(c);
      }
      *c << byteString;
      printf("%s value (datalen %d)\n", opcodeName, (sizeof opcodeName[0]));
    } else {
      std::string str(opcodeName);
      int num = std::stoi(str, 0, 0);
      *c << CScriptNum(num);
      printf("%d (0x%x) number\n", num, num);
    }
  }
}

codeout*
decompile(int idx) {
  CScript c = scripts.at(idx);
  codeout* code = (codeout*)malloc(sizeof(codeout));
  code->len = scriptCount(c);
  code->lines = (char**)malloc(sizeof(char*)*code->len);
  CScript::const_iterator pc = c.begin();
  opcodetype opcode;
  std::vector<unsigned char> vch;
  for (int i=0; pc < c.end(); i++) {
    if (!c.GetOp(pc, opcode, vch)) {
      printf("Script.GetOp err\n");
    } else {
      std::reverse(vch.begin(), vch.end());
      vch.push_back(opcode);
      std::reverse(vch.begin(), vch.end());
      code->lines[i] = strvecToSizedCharPtr(&vch);
    }
  }
  return code;
}

const char* 
scriptToString(int idx)
{
    return scripts.at(idx).ToString().c_str();
}

const 
opcodetype opStringToOpCode(char* opName) 
{
  for(int i=0; i <= 0xff; i++) {
    opcodetype opcode = (opcodetype)i;
    const char* maybeName = GetOpName(opcode);
    if(strcmp(opName, maybeName) == 0) {
      return opcode;
    }
  }
  return OP_INVALIDOPCODE;
}

bool 
is_digits(const std::string &str)
{
  return std::all_of(str.begin(), str.end(), digitCheck ); // C++11
}

int 
digitCheck(char ch) {
  return ::isdigit(ch) || ch == '-';
}

int 
scriptCount(CScript c) 
{
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

const char* version() {
  std::string str;
/*
  str += "v";
  str += std::to_string(CLIENT_VERSION_MAJOR);
  str += ".";
  str += std::to_string(CLIENT_VERSION_MINOR);
  str += ".";
  str += std::to_string(CLIENT_VERSION_REVISION);
  str += ".";
  str += std::to_string(CLIENT_VERSION_BUILD);
  return str.c_str();
*/
  return PACKAGE_VERSION;
}

}

