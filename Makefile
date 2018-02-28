# edit these directories
emsdk=../webasm/emsdk/ 
bitcoin_source = ../dogecoin/github
wabt = ../webasm/wabt-1.0.0/

# files from bitcoin
bitcoin_files = script/interpreter.cpp script/script.cpp script/script_error.cpp crypto/ripemd160.cpp crypto/sha1.cpp crypto/sha256.cpp primitives/transaction.cpp arith_uint256.cpp eccryptoverify.cpp uint256.cpp utilstrencodings.cpp 
bitcoin_files_full = $(addprefix $(bitcoin_source)/src/, $(bitcoin_files))

# bridge functions
exports = 'EXPORTED_FUNCTIONS=["_jsgo","_scriptToString", "_stringCompile"]'
export_extras = 'EXTRA_EXPORTED_RUNTIME_METHODS=["cwrap","ccall", "writeAsciiToMemory", "writeArrayToMemory"]'

# misc
build = ./build

all: build bridge.js

#emscripten
bridge.js: src/*.cpp
	emcc -s $(exports) -s $(export_extras) -s WASM=1 -I$(bitcoin_source)/src -o build/$@ $(bitcoin_files_full) $^
	ls -l build/$(@:.js=.wasm)

build:
	mkdir $(build)
clean:
	rm -f $(build)/*.o $(build)/*.wasm $(build)/*.wast $(build)/*.js $(build)/*.map

