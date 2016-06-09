return function (Layer, timed_automaton, ref)
  
  local lpeg               = require "lpeg"
  local path=    "cosy/formalism/automaton/timed_automaton"
  local prefix = "cosy/formalism/automaton/timed_automaton/" 
  
  local meta               = Layer.key.meta
  local checks             = Layer.key.checks
  local refines            = Layer.key.refines

  local collection         = Layer.require "cosy/formalism/data.collection"
  local record             = Layer.require "cosy/formalism/data.record"
  local automaton          = Layer.require "cosy/formalism/automaton"

  local identifier         = Layer.require (path .. "/literal.identifier")

  local literal = Layer.require (path .. "/literal")
  local boolean_f    = Layer.require (path .. "/literal.bool")     
  local string_f    =  Layer.require (path .. "/literal.string")
  local number_f    =  Layer.require (path .. "/literal.number")
 
  local operation = Layer.require (path .. "/operation")

  local boolean_operation = Layer.require (path .. "/operation/boolean_operation")


  local operands_arithmetic_type = Layer.require (path .. "/operation/operands_arithmetic_type")
  local operands_relational_type = Layer.require (path .. "/operation/operands_relational_type")

  local multiplication_operation = Layer.require (path .. "/operation/multiplication_operation")
  local division_operation = Layer.require (path .. "/operation/division_operation")

  local addition_operation = Layer.require (path .. "/operation/addition_operation")
  local and_operation = Layer.require (path .. "/operation/and_operation")
  local different_operation = Layer.require (path .. "/operation/different_operation")
  local equal_operation = Layer.require (path .. "/operation/equal_operation")
  local inferiorequal_operation = Layer.require (path .. "/operation/inferiorequal_operation")
  local inferior_operation = Layer.require (path .. "/operation/inferior_operation")
  local nor_operation = Layer.require (path .. "/operation/nor_operation")
  local not_operation = Layer.require (path .. "/operation/not_operation")
 
  local or_operation = Layer.require (path .. "/operation/or_operation")
  local substraction_operation = Layer.require (path .. "/operation/substraction_operation")
  local superiorequal_operation = Layer.require (path .. "/operation/superiorequal_operation")
  local superior_operation = Layer.require (path .. "/operation/superior_operation")
  local xor_operation = Layer.require (path .. "/operation/xor_operation")


  timed_automaton [refines] = {
    automaton,
  }
  
--[[ 
-not refined because we are using a boolean_operation specific for timed_automaton (no need to inherit it).
-if we refine we will lose the tree structure of the operations.
]]--
  timed_automaton [meta].guard_type = boolean_operation

  timed_automaton [meta].state_type [meta] = {
    [record] = {
      invariant  = { value_type = ref [meta].guard_type},
    },
  }
  timed_automaton [meta].clock_type = {
    [refines] = {
      identifier,
      operands_arithmetic_type,
      operands_relational_type,
    },
  }
  timed_automaton.clocks = {
    [refines] = {
      collection,
    }
  }
  timed_automaton.clocks [meta] = {
    [collection] = {
      value_type = ref [meta].clock_type,
    },
  }
  timed_automaton [meta].transition_type [meta][record] = {
    guard = { value_type = ref [meta].guard_type},
    clock_function = {
      [refines] = {
        collection,
      },
    },
  }
  timed_automaton [meta].transition_type [meta][record].clock_function [meta][collection] = {
    value_type = ref[meta].clock_type,
    value_container = ref.clocks,
  }
  timed_automaton.states = {
    [meta] = {
      [collection] = {
        value_type = ref [meta].state_type,
      },
    },
  }
  timed_automaton.transitions = {
    [meta] = {
      [collection] = {
        value_type = ref [meta].transition_type,
      },
    },
  }
  timed_automaton.invariants = {
    [meta] = {
      [collection] = {
        value_type = ref [meta].guard_type,
      },
    },
  }

  multiplication_operation [checks][ prefix .. ".multiplication operands_type_constraints"] = function (proxy)
    if Layer.Proxy.has_meta (proxy) then
    	return
    end

    local count = 0
    for _,v in pairs (proxy.operands) do 
    	if( proxy [meta].clock_type <= v) then
    		count = count+1
    	end
        if(count == 2) then
        	Layer.coroutine.yied (prefix .. ".multiplication: cannot use more than one clock.invalid", {
      	      proxy = proxy,
      	      used = v,
      	    })  
        	break
        end
    end
  end

  division_operation [checks][ prefix .. ".division operands_type_constraints"] = function (proxy)
    if Layer.Proxy.has_meta (proxy) then
    	return
    end

    local count = 0
    for _,v in pairs (proxy.operands) do 
    	if( proxy [meta].clock_type <= v) then
    		count = count+1
    	end
        if(count == 2) then
        	Layer.coroutine.yied (prefix .. ".division: cannot use more than one clock.invalid", {
      	      proxy = proxy,
      	      used = v,
      	    })  
        	break
        end
    end
  end
  
--printer

timed_automaton [meta] = {
  [record] = {
    printer = {value_type = "function",},
    parser = {value_type = "function",},
  }
}


local function printer_term (expression,stack_fathers,string_expression)
  
  -- first call of the function
  -- We will init the stack_fathers and the string _expression

  if (expression ~= nil and (stack_fathers == nil and string_expression == nil)) then 
    stack_fathers = {}
    stack_fathers [#stack_fathers +1] = expression
    string_expression = "" .. expression.operator .. "("
    return printer_term(expression,stack_fathers,string_expression)

    
  elseif (expression ~= nil and (stack_fathers ~= nil and string_expression ~= nil)) then 
    local new_expression 
    local last_father = #stack_fathers

    stack_fathers[last_father].nb_operands_not_done = 0
    --We look if the last operation add all its operation 
    for _, operand_curr in pairs(stack_fathers[last_father].operands) do 
      --if there is an operation not treated yet 
      if( (literal <= operand_curr or operation <= operand_curr) and operand_curr.printer_done == nil) then
        stack_fathers[last_father].nb_operands_not_done = stack_fathers[last_father].nb_operands_not_done + 1
        if(stack_fathers[last_father].nb_operands_not_done == 1) then 
          operand_curr.printer_done = true
          new_expression = operand_curr
        end

      end
    end 

    
    if(stack_fathers[last_father].nb_operands_not_done > 0) then 
   
       -- if the operand is an operation, we add it in the stack and in the string then we will treat its operands

      --if (new_expression.operator) then   
      if (operation <= new_expression) then   
        stack_fathers [#stack_fathers +1] = new_expression
        string_expression = string_expression .. new_expression.operator .. "("
        return printer_term (new_expression,stack_fathers,string_expression)

      -- if it s a literal we just add it in the string
     --- elseif (new_expression.value ) then 
      elseif (literal <= new_expression ) then
    
        string_expression = string_expression .. tostring(new_expression.value)

        if (stack_fathers[last_father].nb_operands_not_done > 1) then string_expression = string_expression .. "," end

        return printer_term (expression,stack_fathers,string_expression)
      else
        print "Error : this is not a valid operand"
        return nil,nil,nil        
      end 


    else
        -- If we have done with this operation we unstack it from the stack_fathers and we close the string with a )
      stack_fathers [last_father] = nil
      string_expression = string_expression .. ")" 

      if ( stack_fathers[last_father-1] and stack_fathers[last_father-1].nb_operands_not_done > 1) then string_expression = string_expression .. "," end      


      --We clean all the entry we add for this function
      for _, operand_curr in pairs(expression.operands) do 
        operand_curr.nb_operands_not_done = nil 
        operand_curr.printer_done = nil
      end
      expression.nb_operands_not_done = nil     
      return printer_term (stack_fathers[last_father-1],stack_fathers,string_expression)
    end

  --We have end 
  else 
    return string_expression
  end

end 

--parser

local function parser (expression,instance)
  
  --verify the pattern of the expression
  local equalcount = lpeg.C {
    "Bool",
    Bool = (lpeg.V "Not" + lpeg.V"Logical" + lpeg.V "Relational") ,

    Not  = (lpeg.P"NOT(" * (lpeg.V "Bool" * (lpeg.P","^0)) * lpeg.P")") ,

    Logical = ((lpeg.P"AND(" + lpeg.P"OR(" + lpeg.P"NOR(" + lpeg.P"XOR(") * (lpeg.V "Bool" * (lpeg.P","^0))^2 * lpeg.P ")") ,

    Relational = ((lpeg.P"INF(" + lpeg.P"INFEQ(" + lpeg.P"EQ(" + lpeg.P"NOTEQ(" + lpeg.P"SUPEQ(" + lpeg.P"SUP(") * (lpeg.V "Operands_Relational" * (lpeg.P","^0))^2 * lpeg.P")") ,   
      Operands_Relational = (lpeg.V "Number"  + lpeg.V "Arithmetic" + lpeg.V "Relational"+ lpeg.V "Identifier"),

      Arithmetic = ((lpeg.P"ADD(" + lpeg.P"SUB(" + lpeg.P"MUL(" + lpeg.P"DIV(") * (lpeg.V "Operands_Arithmetic" * (lpeg.P","^0))^2 * lpeg.P")") ,
      Operands_Arithmetic = (lpeg.V "Number"  + lpeg.V "Arithmetic"+ lpeg.V "Identifier") ,

    Number = (lpeg.R "09"^1) ,
    Identifier = ((lpeg.R "az" + lpeg.R "AZ" + "_") * (lpeg.R "az" + lpeg.R "AZ" + "_" + "." + lpeg.R "09")^0) ,
  }

  --find the operands
  local opcount = lpeg.C {
    "OP",
    OP = (lpeg.V "Number" + lpeg.V "Operation" + lpeg.V "Identifier" + lpeg.V "String") * lpeg.P ","^0,
    Operation = lpeg.R "AZ"^1 * lpeg.P "(" * lpeg.V "OP"^1 * lpeg.P ")" ,
    Number = (lpeg.R "09"^1) ,
    Identifier = ((lpeg.R "az" + lpeg.R "AZ" + "_") * (lpeg.R "az" + lpeg.R "AZ" +"."+ "_" + lpeg.R "09")^0) ,
    String = lpeg.P "\"" *(lpeg.R "az" + lpeg.R "AZ" + "_" + lpeg.R "09")^1 * lpeg.P "\"",
  }
  --transform the expression to an instance 
  local function string_to_operation(patt,formalism_instance)

    local operand_type
    local operation_expression = lpeg.C{lpeg.R"AZ"^1* lpeg.P "("}
    local operation_string = operation_expression:match(patt)
    local oper
    local i = 1

    if operation_string ~= nil then

    --boolean
      if operation_string == "NOT(" then
        oper = Layer.new {}
        oper [refines] = {
              not_operation
            }
      --arithmetic
      elseif operation_string == "ADD(" then
        oper = Layer.new {}
        oper [refines] = {
              addition_operation
            }
        
      elseif operation_string == "SUB(" then
        oper = Layer.new {}
        oper [refines] = {
              substraction_operation
            }
      elseif operation_string == "MUL(" then
        oper = Layer.new {}
        oper [refines] = {
               multiplication_operation
            }
      elseif operation_string == "DIV(" then
        oper = Layer.new {}
        oper [refines] = {
               division_operation
            }

      --logical
      elseif operation_string == "AND(" then
        oper = Layer.new {}
        oper [refines] = {
               and_operation
            }
      elseif operation_string == "OR(" then
        oper = Layer.new {}
        oper [refines] = {
               or_operation
            }
      elseif operation_string == "XOR(" then
        oper = Layer.new {}
        oper [refines] = {
               xor_operation
            }
      elseif operation_string == "NOR(" then
       oper = Layer.new {}
       oper [refines] = {
              nor_operation
            }


    --relational
      elseif operation_string == "INF(" then
         oper = Layer.new{}
         oper [refines] = {
              inferior_operation
            }
      elseif operation_string == "INFEQ(" then
        oper = Layer.new {}
        oper [refines] = {
              inferiorequal_operation
            }
      elseif operation_string == "EQ(" then
        oper = Layer.new {}
        oper [refines] = {
              equal_operation
            }
      elseif operation_string == "NOTEQ(" then
        oper = Layer.new {}
        oper [refines] = {
              different_operation
            }
      elseif operation_string == "SUPEQ(" then
        oper = Layer.new {}
        oper [refines] = {
              superiorequal_operation
            }
      elseif operation_string == "SUP(" then
        oper = Layer.new{}
        oper [refines] = {
              superior_operation
            }
      end
      --get rid of the parenthesis
      oper.operator=string.sub (operation_string, 1, #operation_string-1)
    end
   --loop as long as you find operands
    while operation_string ~= nil do

      patt = string.sub (patt, #operation_string+1, #patt)
      operation_string = opcount:match(patt) 
      if operation_string ~= nil then
        --get rid of the commas and parenthesis
        while(string.sub (operation_string,1,1) == ',' or string.sub (operation_string, 1, 1) == ')') do
          operation_string = string.sub (operation_string, 1, #operation_string-1)
        end
        local return_value = string_to_operation (operation_string, instance)
        if(return_value.operator ~= nil or return_value.value ~= nil) then
         -- print(type(operation))
          oper.operands[i] = return_value
          i=i+1
        end
      end
    end
    --get rid of the commas and parenthesis
    while(string.sub (patt, #patt, #patt) == ',' or string.sub (patt, #patt, #patt) == ')') do
      patt = string.sub (patt, 1, #patt-1)
    end
   
    if #patt > 0 then
    --boolean
      operand_type = lpeg.P "true" + lpeg.P "false"
      if(operand_type:match (patt)) then  
        local bool = Layer.new {}
        bool [refines] = { boolean_f}
        if (patt == "true") then      
          bool.value = true
        else      
          bool.value = false
        end
        return bool
      end
    end
    --Identifier
    operand_type = ((lpeg.R "az" + lpeg.R "AZ" + "_") * (lpeg.R "az" + lpeg.R "AZ" + "_" +"."+ lpeg.R "09")^0)

      if(operand_type:match(patt) ~= nil) then
        --check if the formalism instance exists in the instance created
        local val = load("return function (instance)  return instance"..string.sub (patt,string.find (patt,"%."), #patt).." end")()
        val = val(formalism_instance)
        if(val) then
          return val
        end

      else
      --number
        operand_type = lpeg.R "09"^1
        if(operand_type:match(patt) ~= nil) then
          local tmp = Layer.new {}
          tmp [refines] = {
                number_f
               }
          tmp.value = tonumber(patt)
          return tmp
        end
      --String
        operand_type = lpeg.P "\"" * (lpeg.R "az" + lpeg.R "AZ" + "_" + lpeg.R "09")^1 * lpeg.P "\""
        if(operand_type:match(patt) ~= nil) then
          local tmp = Layer.new{}
          tmp[refines] = {string_f}
          tmp.value = patt
          return tmp
        end
      end

      return oper
    end
    if(equalcount:match(expression) ~= nil) then
      return  string_to_operation(expression, instance)
    end  
  end


  timed_automaton.parser = parser
  timed_automaton.printer = printer_term
  
  return timed_automaton
end

