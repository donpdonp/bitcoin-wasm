var Module = require('./build/bridge.js')

Module['onRuntimeInitialized'] = onRuntimeInitialized;
function onRuntimeInitialized() {
  var ops = ["OP_RETURN"]
  var strbufarr = ops.map(function(s){ 
    var b = Module._malloc(s.length+1); 
    Module.writeAsciiToMemory(s, b);
    return b } );
  var ptrbuf = Module._malloc(ops.length*4)
  Module.writeArrayToMemory(strbufarr, ptrbuf)
  //Module.ccall('stringCompile', 'boolean', ['number', 'number'], [ptrbuf, ops.length])
  //Module.ccall('stringCompile', 'boolean', ['array', 'number'], [strbufarr, 1])
  Module.ccall('stringCompile', 'boolean', ['array', 'number'], [ops, 1])
}

