--Addition Operation

return function (Layer, addition_operation)

  local meta       =  Layer.key.meta
  local refines    =  Layer.key.refines
  local record =  Layer.require "cosy/formalism/data.record"
  local arithmetic_operation  = Layer.require "cosy/formalism/operation.arithmetic_operation"
  local collection  = Layer.require "cosy/formalism/data.collection"
  
  addition_operation [refines] = {
    arithmetic_operation,
  }

  addition_operation.operands [meta][collection].minimum = 2
  addition_operation.operands [meta][collection].maximum = math.huge
  addition_operation [meta][record].operator.value = "ADD"
  
  return addition_operation
end
