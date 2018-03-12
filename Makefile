# edit these directories
emsdk=../webasm/emsdk/ 
bitcoin_source = ../dogecoin/github
wabt = ../webasm/wabt-1.0.0/

bitcoin_client_major = $(shell perl -ne 'print if s/\#define\s+CLIENT_VERSION_MAJOR\s+(\d+)/\1/' $(bitcoin_source)/src/clientversion.h )
bitcoin_client_minor = $(shell perl -ne 'print if s/\#define\s+CLIENT_VERSION_MINOR\s+(\d+)/\1/' $(bitcoin_source)/src/clientversion.h )
bitcoin_client_revision = $(shell perl -ne 'print if s/\#define\s+CLIENT_VERSION_REVISION\s+(\d+)/\1/' $(bitcoin_source)/src/clientversion.h )

# project name
ifneq (,$(wildcard $(bitcoin_source)/src/dogecoin.h))
  project_name = dogecoin
else ifneq (,$(wildcard $(bitcoin_source)/src/bitcoin.h))
  project_name = bitcoin
else
  project_name = unknown
endif

project_full_name = $(project_name) $(bitcoin_client_major).$(bitcoin_client_minor).$(bitcoin_client_revision)

# files from bitcoin
bitcoin_files = script/interpreter.cpp script/script.cpp script/script_error.cpp crypto/ripemd160.cpp crypto/sha1.cpp crypto/sha256.cpp primitives/transaction.cpp arith_uint256.cpp eccryptoverify.cpp uint256.cpp utilstrencodings.cpp 
bitcoin_files_full = $(addprefix $(bitcoin_source)/src/, $(bitcoin_files))

# bridge functions
exports = 'EXPORTED_FUNCTIONS=["_scriptRun","_scriptToString", "_stringCompile", "_decompile", "_version", "_byteCompile"]'
export_extras = 'EXTRA_EXPORTED_RUNTIME_METHODS=["cwrap","ccall", "writeAsciiToMemory", "writeArrayToMemory", "Pointer_stringify", "getValue"]'

# misc
build = ./build

all: build $(build)/$(project_name).wasm

#emscripten
$(build)/$(project_name).wasm: src/*.cpp
	@echo building for $(project_full_name)
	emcc -s $(exports) -s $(export_extras) -s WASM=1 -D PROJECT_NAME="\"$(project_full_name)\"" -I$(bitcoin_source)/src -o $(build)/$(project_name).js $(bitcoin_files_full) $^
	ls -l $(build)/$(project_name)* 

build:
	mkdir $(build)

clean:
	rm -f $(build)/*.o $(build)/*.wasm $(build)/*.wast $(build)/*.js $(build)/*.map

node:
	cd build; node ../run.js
