console.log('loading bridge.wasm')
var Module = require('./build/bridge.js')

var op_codes = ["1", "2", "OP_ADD"]

Module['onRuntimeInitialized'] = onRuntimeInitialized;

function onRuntimeInitialized() {
  console.log('compiling script:', op_codes)
  var strBufArr = op_codes.map(function(s){ 
    var b = Module._malloc(s.length+1); 
    Module.writeAsciiToMemory(s, b);
    return b } )
  var heapBytes = _arrayToHeap(new Uint32Array(strBufArr))
  var idx = Module.ccall('stringCompile', 'number', ['number', 'number'], [heapBytes.byteOffset, op_codes.length])
  var scriptStr = Module.ccall('scriptToString', 'string', ['number'], [idx])
  console.log('input script compiled to: ', scriptStr)
  var struct = Module.ccall('scriptRun', 'number', ['number'], [idx])
  var result = extractStack(struct)
  console.log('script', result.success ? "SUCCESS" : "FAIL")
  result.stack.forEach(row => { console.log(row) } )
}

function extractStack(struct) {
  var result = {}
  result.success = Module.getValue(struct, 'i8') ? true : false
  var len = Module.getValue(struct+4, 'i64')
  result.stack = []
  var charheap = Module.getValue(struct+8, '*')
  for(var i=0; i<len; i++){ 
    var rowheap = Module.getValue(charheap+(4*i), '*')
    var stkrowlen = Module.getValue(rowheap, 'i8')
    var stkrow = new Uint8Array(Module.HEAPU8.buffer, rowheap+1, stkrowlen);
    result.stack.push(stkrow)
  }
  return result
}

function _arrayToHeap(typedArray){
  var numBytes = typedArray.length * typedArray.BYTES_PER_ELEMENT;
  var ptr = Module._malloc(numBytes);
  var heapBytes = new Uint8Array(Module.HEAPU8.buffer, ptr, numBytes);
  heapBytes.set(new Uint8Array(typedArray.buffer));
  return heapBytes;
}
