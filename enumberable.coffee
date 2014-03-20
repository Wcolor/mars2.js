define ()->
  each=(iterator,context)->
    try
      @._each iterator,context
    catch e
      if e isnt 'break' then throw e

  each:each
