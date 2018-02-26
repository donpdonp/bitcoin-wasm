Build the script/interpreter part of the bitcoin code base for webasm.

## build
bitcoin-wasm $ make
emcc -s 'EXPORTED_FUNCTIONS...
-rw-rw-r-- 1 donp donp 7837573 Feb 26 16:20 build/bridge.wast

## run
bitcoin-wasm $ cd build
build $ node ../run.js


