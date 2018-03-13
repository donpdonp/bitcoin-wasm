Build the script/interpreter part of the bitcoin code base for webasm.

## status
2018-Mar-13 All opcode are supported except OP_CHECKSIG (openssl/ecdsa libs are not ported to webasm yet)

## build
```bash
bitcoin-wasm $ make
emcc -s 'EXPORTED_FUNCTIONS...
-rw-rw-r-- 1 donp donp 636982 Mar  5 14:13 build/bridge.wasm
```

## run in node

The run.js file loads a script containing 1, 2, OP_ADD operation. This pushes
two values to the stack, then runs OP_ADD. The resulting stack is the result
of the ADD.

```bash
bitcoin-wasm $ make node
cd build; node ../run.js
loading bridge.wasm
compiling script: [ '1', '2', 'OP_ADD' ]
stringCompile 3 opcode strings 
#0 1 (0x1) number
#1 2 (0x2) number
#2 93 OP_ADD opcode
script opcount: 3 hex: 0101010293
input script compiled to:  1 2 OP_ADD
scriptRun #0 begin
scriptRun GOOD
stacktoChar memcopy row 0 len 1
script SUCCESS
Uint8Array [ 3 ]
```

## run in a browser

bridge.js is loaded as any other .js file in an html script tag. it will expect
bridge.wasm to exist at the same path. 

