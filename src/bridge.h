extern "C" {

const opcodetype opStringToOpCode(char* opName);
std::vector<CScript> scripts;
bool is_digits(const std::string &str);
void printStack(std::vector<std::vector<unsigned char> > stack) ;

}

