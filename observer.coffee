define ()->
  #获得这个对象的类型
  #@param[Object] obj 当前对象 
  #@return {string} 对象类型 
  _get_type = (obj) ->
    if obj is undefined or obj is null
      return String obj
    class_type = 
      '[object Boolean]': 'boolean'
      '[object Number]': 'number'
      '[object String]': 'string'
      '[object Function]': 'function'
      '[object Array]': 'array'
      '[object Date]': 'date'
      '[object RegExp]': 'regexp'
      '[object Object]': 'object'
    return class_type[Object.prototype.toString.call(obj)]
  #深度复制array
  _deep_copy_array=(source)->
    target = []
    for item,index in source
      if _get_type(item) is 'array'
        target[index] = _deep_copy_array item
      else if _get_type(item) is 'object'
        target[index] = _deep_copy_object item
      else
        target[index] = item
    return target
  #深度拷贝对象 
  _deep_copy_object=(source)->
    target={}
    for key,item of source
      if _get_type(item) is 'array'
        target[key] = _deep_copy_array item
      else if _get_type(item) is 'object'
        target[key] = _deep_copy_object item
      else
        target[key] = item
    return target

  #深度复制功能
  _deep_copy = (source)->
    if _get_type(source) is 'array'
      return _deep_copy_array source
    else if _get_type(souce) is 'object'
      return _deep_copy_object source
    else return source

  #初始化规则
  __init_observer = ()->
    unless @__publish_handler?
      @__publish_handler = {}
      @__published={}
    @
  #发出事件相应
  #@param [String] notice 通知名称 
  #@param [Object] data 通知数据  
  #@param [Boolean] deep_copy 是否对数据复制 
  #@params [this] 当前对象实例
  notify = (notice,data,deep_copy=false)->
    @__init_observer()



    if deep_copy 
      data = _deep_copy data

    #暂存历史数据
    #store notice data for history use
    @__published[notice] = data
    unless @__publish_handler[notice]?
      @__publish_handler[notice] = []

    functions = @__publish_handler[notice]
    for fn in functions
      if deep_copy
        data = _deep_copy data
      fn(data)
    @
  #添加监听规则
  #@param [String] notice 通知名称 
  #@param [Function] handler 处理函数
  #@param [Boolean] use_history 是否使用历史数据（已经发生过，异步触发)
  #@return this
  add_observer=(notice,handler,use_history)->
    @.__init_observer()
    if use_history and @.__published[notice]
      handler(@.__published[notice])
      return @

    unless @.__publish_handler[notice]? then @.__publish_handler[notice]=[]

    @.__publish_handler[notice].push handler
    @
  #取消监听某个通知名称的某个处理方式
  #@param [String] notice 通知名称
  #@param [Function] handler 通知处理 
  #@return this
  remove_observer=(notice,handler)->
    @__init_observer()
    unless @__publish_handler[notice]
      return @

    index = @__publish_handler[notice].indexOf handler
    if index>-1
      @__publish_handler[notice].splice(index,1)
    @


  #返回值 
  __init_observer:__init_observer
  notify:notify
  add_observer:add_observer
  remove_observer:remove_observer
  trigger:notify
  on:add_observer
  off:remove_observer

