extern "C" {

struct stackout {
  bool success;
  int len;
  char** stack;
};

stackout* bigStack;

const opcodetype opStringToOpCode(char* opName);
void encodeOp(CScript* c, char* opcodeName);
std::vector<CScript> scripts;
bool is_digits(const std::string &str);
int digitCheck(char ch);
void printStack(std::vector<std::vector<unsigned char> > stack) ;
stackout* stackToCharArray(std::vector<std::vector<unsigned char> > stack);
int scriptCount(CScript c);

}

