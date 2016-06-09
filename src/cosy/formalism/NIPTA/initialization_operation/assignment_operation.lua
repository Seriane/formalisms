--Assignment Operation

return function (Layer, assignment_operation)

  local meta       =  Layer.key.meta
  local refines    =  Layer.key.refines
  local collection =  Layer.require "cosy/formalism/data.collection"
  local record =  Layer.require "cosy/formalism/data.record"
  local boolean_operation  = Layer.require "cosy/formalism/boolean_operation"

  assignment_operation [refines] = {
     boolean_operation,
  }

 assignment_operation.operands[meta][collection].minimum = 2
 assignment_operation.operands[meta][collection].maximum = 2
 assignment_operation[meta][record].operator.value = "="
  
  return assignment_operation

end
