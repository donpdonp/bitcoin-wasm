extern "C" {

struct stackout {
  int len;
  char** stack;
};


const opcodetype opStringToOpCode(char* opName);
std::vector<CScript> scripts;
bool is_digits(const std::string &str);
void printStack(std::vector<std::vector<unsigned char> > stack) ;
stackout* stackToCharArray(std::vector<std::vector<unsigned char> > stack);

}

