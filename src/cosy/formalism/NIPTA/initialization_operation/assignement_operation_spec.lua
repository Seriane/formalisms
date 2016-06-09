--These lines are required to correctly run tests.

if #setmetatable ({}, { __len = function () return 1 end }) ~= 1 then
  require "compat52"
end

require "busted.runner" ()
----

local Layer = require "layeredata"

describe ("Formalism operation.assignment_operation", function ()

  it ("can be loaded", function ()
    local _ = Layer.require "cosy/formalism/operation.assignment_operation"
  end)

  it ("assign more than maximum number of operands", function ()
    
    local record = Layer.require "cosy/formalism/data.record"

    local assignment_operation = Layer.require "cosy/formalism/operation.assignment_operation"
    local number = Layer.require "cosy/formalism/literal.number"
    local collection = Layer.require "cosy/formalism/data.collection"

    local layer = Layer.new{}
    local number_instance1 = Layer.new{}
    local number_instance2 = Layer.new{}
    local number_instance3 = Layer.new{}

    number_instance1 [Layer.key.refines] = {number}
    number_instance1.value=1

    number_instance2 [Layer.key.refines] = {number}
    number_instance2.value=2

    number_instance3 [Layer.key.refines] = {number}
    number_instance3.value=3

    assignment_operation[Layer.key.meta][record].operands_type = number
    assignment_operation.operands[Layer.key.meta][collection].value_type = number
    
    layer [Layer.key.refines] = {assignment_operation}
    layer.operands = {number_instance1, number_instance2, number_instance3}
    
    Layer.Proxy.check_all (layer)
    assert.is_not_nil ( next ( Layer.messages ) )

  end)
  it ("assign less than minimum number of operands", function ()
    
    local record = Layer.require "cosy/formalism/data.record"

    local assignment_operation = Layer.require "cosy/formalism/operation.assignment_operation"
    local number = Layer.require "cosy/formalism/literal.number"
    local collection  = Layer.require "cosy/formalism/data.collection"

    local layer = Layer.new{}
    local number_instance1 = Layer.new{}

    number_instance1 [Layer.key.refines] = {number}
    number_instance1.value=1

    assignment_operation[Layer.key.meta][record].operands_type = number
    assignment_operation.operands[Layer.key.meta][collection].value_type = number
    
    layer [Layer.key.refines] = {assignment_operation}
    layer.operands = {number_instance1}
    
    Layer.Proxy.check_all (layer)
    assert.is_not_nil ( next ( Layer.messages ) )
  
  end)
  it ("assign good type of operands", function ()
    
     local record = Layer.require "cosy/formalism/data.record"

    local assignment_operation = Layer.require "cosy/formalism/operation.assignment_operation"
    local number = Layer.require "cosy/formalism/literal.number"
    local collection = Layer.require "cosy/formalism/data.collection"
    
    local layer = Layer.new{}

    local number_instance1 = Layer.new{}
    local number_instance2 = Layer.new{}

    number_instance1 [Layer.key.refines] = {string}
    number_instance1.value=1

    number_instance2 [Layer.key.refines] = {string}
    number_instance2.value=2

    assignment_operation[Layer.key.meta][record].operands_type = number
    assignment_operation.operands[Layer.key.meta][collection].value_type = number
    
    layer [Layer.key.refines] = {assignment_operation}
    layer.operands = {number_instance1,number_instance2}
    
    Layer.Proxy.check_all (layer)
    assert.is_nil ( next ( Layer.messages ) )

  end)
  it ("assign bad type of operands", function ()
    
    local record = Layer.require "cosy/formalism/data.record"

    local assignment_operation = Layer.require "cosy/formalism/operation.assignment_operation"
    local number = Layer.require "cosy/formalism/literal.number"
    local string = Layer.require "cosy/formalism/literal.string"
    local collection = Layer.require "cosy/formalism/data.collection"
    local layer = Layer.new{}

    local string_instance1 = Layer.new{}
    local string_instance2 = Layer.new{}

    string_instance1 [Layer.key.refines] = {string}
    string_instance1.value="s1"

    string_instance2 [Layer.key.refines] = {string}
    string_instance2.value="s2"

    assignment_operation[Layer.key.meta][record].operands_type = number
    assignment_operation.operands[Layer.key.meta][collection].value_type = number
    
    layer [Layer.key.refines] = {assignment_operation}
    layer.operands = {string_instance1,string_instance2}
    
    Layer.Proxy.check_all (layer)
    assert.is_not_nil ( next ( Layer.messages ) )
  end)

end)
