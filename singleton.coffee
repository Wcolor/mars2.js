#@author bertwang
#@mixin
#@example
# page = PageController.instance()
#
define ()->
  instance = (args...)->
    unless @_instance?
      @_instance = new @(args...)
    return @_instance

  instance:instance
