return function (Layer, nipta)

  local refines = Layer.key.refines
  local meta = Layer.key.meta

  local record = Layer.require "cosy/formalism/data.record"
  local collection = Layer.require "cosy/formalism/data.collection"
  local pta = Layer.require "cosy/formalism/automaton/timed_automaton/parametric_timed_automaton"
  local ipta = Layer.require "cosy/formalism/automaton/timed_automaton/parametric_timed_automaton/IMITATOR_parametric_timed_automaton"
  local pta_ref = Layer.reference (pta)
  local action = Layer.require "cosy/formalism/action"
  local number = Layer.require "cosy/formalism/literal.number"
  local boolean_operation_constraints = Layer.require "cosy/formalism/NIPTA/operation/boolean_operation"

  nipta [refines] = {
    record,
  }
  nipta.iptas = {
    [refines] = {
      collection,
    },
    [meta] = {
      [collection] = {
        value_type = ipta
      }
    }
  }

  nipta.actions = {
    [refines] = {
      collection,
    },
    [meta] = {
      value_type = action,
    }
  }

  nipta.states = {
    [refines] = {
      collection,
    },
    [meta] = {
      value_type = pta_ref [meta].state_type,
    }
  }

  nipta.parameters = {
    [refines] = {
      collection,
    },
    [meta] = {
      value_type = pta_ref [meta].parameter_type
    }
  }

  nipta.clocks = {
    [refines] = {
      collection,
    },
    [meta] = {
      value_type = pta_ref [meta].clock_type
    }
  }

  nipta.discrete_variables = {
    [refines] = {
      collection,
    },
    [meta] = {
      value_type = number,
    }
  }
  nipta [meta].constraints_type = boolean_operation_constraints
  nipta.constraints = {
    [refines] = {
      boolean_operation_constraints,
    }
  }

end
