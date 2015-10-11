###*
qConfig = {
  delay:number
  failed:
    delay:number
  loading:
    delay:number
  success:
    delay:number  
}
number 负数时不自动关闭,loading此设置无效
###
module.constant("qConfig",{
  delay:100
  failed:{
    delay:2000
  }
  loading:{}
  success:{
    delay:2000
  }
})

.service("PromiseProxy",['$timeout','$q','$exceptionHandler','qConfig',($timeout,$q,$exceptionHandler,qConfig)->
  _promiseNum = 1;
  getPromiseNum = ()->
    return _promiseNum++;

  extendConfig = ()->
    return qConfig if arguments.length < 1
    if arguments.length is 1 and angular.isArray(arguments[0])
      args = arguments[0]
    else 
      args = Array.prototype.slice.call(arguments)
    args.unshift(qConfig)
    config = extendOptions.apply(@,args)

    config.loading.delay = config.loading.delay || config.delay
    config.failed.delay = config.failed.delay || config.delay
    config.success.delay = config.success.delay || config.delay
    return config


  
  processQueue = ($$state)->
    value = $$state.value
    status = $$state.status
    list = if $$state.isComplete then $$state.complete[status] else $$state.pending[status]

    for fn in list
      try
        value = fn(value)
      catch e
        $exceptionHandler(e);
        # break;
    return ($$state.value = value)

  makePromise = (deferred,resolved,value)->
    return unless deferred
    if resolved 
      deferred.resolve(value)
    else 
      deferred.reject(value)
    return ;
  completePromise = (deferred,resolved,useTime,delay)->
    if useTime >= delay
      makePromise(deferred,resolved)
    else 
      nextTick(()->
        makePromise(deferred,resolved)
      ,delay - useTime)
    return ;
  class PromiseProxy 
    constructor:(tp,config)->
      @deferred =  $q.defer()
      @promise = @deferred.promise

      # @promise = tp
      @config = config
      @$$state = {}
      @$$state.status =  0 #@promise.$$state

      @$$state.pending = [[],[],[],[]]
      @$$state.complete = [[],[]]
      self = @
      nextTick(()->
        self.run(tp)
      )
      return @
    run:(promise)->
      self = @
      config = @config
      startTime = endTime = new Date();
      timeline = 0
      promise.finally(()->
        endTime = new Date();
        timeline = endTime - startTime
      ).then(()->
        completePromise(self.deferred,true,timeline,config.success.delay)
      ,()->
        completePromise(self.deferred,false,timeline,config.failed.delay)
      )
      #call loading 
      @$$state.status = 0
      
      processQueue(@$$state)
      rs = false
      @promise.finally(()->
        # call ready
        self.$$state.status = 1
        processQueue(self.$$state)
      ).then(()->
        # call success
        self.$$state.status = 2
        self.$$state.value = true
        processQueue(self.$$state)
        return (rs = true)
      ).catch(()->
        # call failed
        self.$$state.status = 3
        self.$$state.value = false
        processQueue(self.$$state)
        return false 
      ).finally(()->
        #set delay to call finish or unfinish
        delay = if rs then config.success.delay else config.failed.delay
        if delay > 0
          nextTick(()->
            self.$$state.isComplete = true
            self.$$state.status = 0 #call finish 
            self.$$state.value = rs
            processQueue(self.$$state)
          ,delay)
        else 
          self.$$state.isComplete = true
          self.$$state.status = 1 #call unfinish 
          self.$$state.value = rs
          processQueue(self.$$state)
      )
    then:(onLoading,onReady,onSuccess,onFailded)->
      for arg,i in arguments
        if i > 3
          break; 
        if arg 
          @$$state.pending[i].push(arg)

      if(!@$$state.isComplete and !(arguments.length < @$$state.status ) and (fn = arguments[@$$state.status]))
        nextTick(fn)
      return @

    "thenF":(onFinish,onUnFinish)->
      for arg,i in arguments
        if i > 2
          break;
        if arg
          @$$state.complete[i].push arg
      if(@$$state.isComplete and !(arguments.length < @$$state.status ) and (fn = arguments[@$$state.status]))
        nextTick(fn)
      @

    loading:(fn)-> #loading start 
      @then(fn)
    ready:(fn)-> # loading end ,has result
      @then(null,fn)
    success:(fn)-> # success
      @then(null,null,fn)
    failed:(fn)-># failed
      @then(null,null,null,fn)

    finish:(fn)->
      @thenF(fn)
    unfinish:(fn)->
      @thenF(null,fn)
    "finally":(fn)->
      @thenF(fn,fn)

  return {
    extendConfig
    $new:(tp,config)->
      return new PromiseProxy(tp,config)
  }
])