return function (Layer, ipta, ref)

  local meta     = Layer.key.meta
  local refines  = Layer.key.refines
  
  local collection       = Layer.require "cosy/formalism/data.collection"
  local record           = Layer.require "cosy/formalism/data.record"
  local pta = Layer.require "cosy/formalism/automaton/timed_automaton/parametric_timed_automaton"
  local identifier = Layer.require "cosy/formalism/identifier"
  local assignment_operation = Layer.require "cosy/formalism/automaton/timed_automaton/operation/assignment_operation"
  local number = Layer.require "cosy/formalism/literal.number"

  ipta [refines] = {
    pta,
  }

  ipta.discrete_variables = {
    [refines] = {
    collection,
    },
    [meta] = {
      [collection] = {
        value_type=number,
      }
    }
  }

  ipta.li = {
    [refines] = {
      record,
    },
    [meta] = {
      value_type = ref[meta].state_type,
      value_container = ref[meta].states
    }
  }

  ipta [meta].discrete_assignement = {
    [refines] = {
      assignment_operation,
    },
  }

  ipta [meta].discrete_assignement[meta][record].operator_type = number

  ipta[meta].clock_type = {
  [refines] = {
    number,
  },
  [meta] = {
    [record] = {
      id = {
        [refines] = {
          identifier,
        }
      }
    }
  }
}

  ipta [meta].clock_assignement = {
    [refines] = {
      assignment_operation,
    },
  }
  
  ipta [meta].discrete_assignement[meta][record].operator_type = ref[meta].clock_type

  ipta [meta].transition_type [meta][record] = {
    discrete_function = {
      [refines] = {
        collection,
      },
      [meta] = {
        value_type=ref [meta].discrete_assignement
      }
    },
    urgent = {
      value_type="boolean",
    }
  }

  ipta [meta].state_type [meta][record] = {
    discrete_function = {
      [refines] = {
        collection,
      },
      [meta] = {
        value_type=ref [meta].discrete_assignement,
      }
    },
    clock_function = {
      [refines] = {
        collection,
      },
      [meta] = {
        value_type=ref [meta].clock_assignement,
      }
    },
    urgent = {
      value_type="boolean",
    }
  }

 ipta.stopwatches = {
   [refines] = {
    collection,
   },
   [meta] = {
    [collection] = {
     value_type=ref[meta].clock_type,
    }
  }
}

ipta[meta].parameter_type = {
  [refines] = {
    number,
  },
  [meta] = {
    [record] = {
      id = {
        [refines] = {
          identifier,
        }
      }
    }
  }
}

ipta.parameters[meta][collection].value_type=ref [meta].parameter_type

return ipta

end