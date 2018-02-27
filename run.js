var Module = require('./build/bridge.js')

Module['onRuntimeInitialized'] = onRuntimeInitialized;
function onRuntimeInitialized() {
  var ops = ["OP_RETURN", "OP_DO"]
  var strBufArr = ops.map(function(s){ 
    var b = Module._malloc(s.length+1); 
    Module.writeAsciiToMemory(s, b);
    return b } );
  var heapBytes = _arrayToHeap(new Uint32Array(strBufArr));
  //Module.ccall('stringCompile', 'boolean', ['array', 'number'], [strbufarr, 1])
  Module.ccall('stringCompile', 'boolean', ['number', 'number'], [heapBytes.byteOffset, ops.length])
}

function _arrayToHeap(typedArray){
  var numBytes = typedArray.length * typedArray.BYTES_PER_ELEMENT;
  var ptr = Module._malloc(numBytes);
  var heapBytes = new Uint8Array(Module.HEAPU8.buffer, ptr, numBytes);
  heapBytes.set(new Uint8Array(typedArray.buffer));
  return heapBytes;
}
