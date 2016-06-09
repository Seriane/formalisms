--XOR Operation

return function (Layer, xor_operation)

  local meta       =  Layer.key.meta
  local refines    =  Layer.key.refines
  local record     =  Layer.require "cosy/formalism/data.record"
  local collection =  Layer.require "cosy/formalism/data.collection"
  local logical_operation  = Layer.require "cosy/formalism/operation.logical_operation"

  xor_operation [refines] = {
    logical_operation,
  }

  xor_operation.operands [meta][collection].minimum = 2
  xor_operation.operands [meta][collection].maximum = math.huge
  xor_operation [meta][record].operator.value = "XOR"
  
  return xor_operation
end
