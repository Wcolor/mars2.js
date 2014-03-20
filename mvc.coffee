 define (require,exports,module)->
   #基础类,提供抽象层面的一些实现 
   singleton = require './singleton'
   enumberable = require './enumberable'

   observer = require './observer'
   class Base
     @extend:(modules...)->
      for module in modules
        for v,k of module
          @[v] = k
     @include:(modules...)->
      for module in modules
        for v,k of module
          @::[v] = k
   #控制层类 
   #@extend Base
   class Controller extends Base
     @extend singleton 
     _use_routes:()->
       unless @routes
         return false

       current_action = null

       url = window.location.href
       for route,action of @routes
         if route is 'default'
           continue
         reg = new RegExp(route)
         result =  reg.exec url
         #如果满足条件，那么直接进行初始化执行
         if result  
           current_action =  action
           break

       unless current_action?
         current_action = @routes['default']


       require ['controllers/'+current_action],(action_method)->
         action_method.init()




   #server层 
   #@extend Base
   class Service extends Base
     @include observer
     @extend singleton
     #检查回执数据是否正常
     #@param data[Object] 接口返回数据处理
     accept:(data)->
       if data.code is 0 or data.code is '0'
         return data.response
       else
         #error_message = if @_error[data.code] then @_error[data.code] else @_error['default']
         #throw new Error(error_message)
         throw new Error(data.msg)
   #模型 
   #@extend Service 
   class Model extends Service 
     constructor:(attributes)->
       unless @_attr?
         @_attr = {}
       for k,v of attributes
         @_attr[k] = v

     #@example
     #model.attr(name)
     #model.attr(name,value);
     #model.attr(obj)
     attr:(key,value)->
       if(typeof key == 'object')
         for k,v of key
           @_attr[k] = v
         return true
       if value?
         @_attr[key] = value
         return @
       else
         return @_attr[key]
     #保存对象
     save:()->
        if @_attr.id?  
          @update()
          return true
        else
          $.ajax
            type:'post'
            url:@base_url
            dataType:'json'
            data:@_attr
            context:@
            success:(data)->
              response = @accept data
              @notify 'model:saved',response
     #更新一个对象
     update:()->
       data = 
         '_method':'put'
       for k,v of @_attr
         data[k] = v

       $.ajax
         type:"post"
         url:@base_url+'/'+@_attr.id
         data:data
         context:@
         success:(data)->
           response = @accept data
           @notify 'model:saved',response
           @notify 'model:updated',response
     #删除对象
     delete:()->
       data = 
         '_method':"delete"
       for k,v of @_attr
         data[k] = v
       $.ajax
         type:'post'
         url:@base_url+'/'+@_attr.id
         data:data
         context:@
         success:(data)->
           response = @accept data
           @notify 'model:deleted',response
   #视图层
   #@extends Base
   class View extends Base
     @extend singleton
     @include observer
     constructor:()->

   #集合，model查询后的返回功能
   #
   class Collection extends Base
     @include enumberable
     constructor:(data)->
       unless @_collection.splice?
         throw new Error('Illegal Parameter For Collection')
       @_collection = data
     #@protected 
     #基础循环函数，被enumberable包调用
     _each:(iterator,context)->
       for v in @_collection
         iterator.apply context,v
   exports = 
     Controller:Controller
     Model:Model
     View:View
     Service:Service








