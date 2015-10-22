PromiseProxyService = ['$q','$exceptionHandler',($q,$exceptionHandler)->
  listenPromise = (promise,proxy)->
    finallyFn = (delay)->
      proxy.$$state.isComplete = true
      proxy.$$state.status =  if delay >= 0 then 0 else 1
      proxy.$$state.value = resultStatus
      processQueue(proxy.$$state)

    config = proxy.config

    startTime = endTime = new Date()
    timeline = 0
    promise.finally(()->
      endTime = new Date()
      timeline = endTime - startTime
    ).then(()->
      completePromise(proxy.deferred,true,config.success - timeline)
    ,()->
      completePromise(proxy.deferred,false,config.failed - timeline)
    )
    proxy.$$state.status = 0
    processQueue(proxy.$$state)
    resultStatus = null
    proxy.promise.finally(()->
      # call ready
      proxy.$$state.status = 1
      processQueue(proxy.$$state)
    ).then(()->
      proxy.$$state.status = 2
      resultStatus = proxy.$$state.value = true
      return resultStatus
    ).catch(()->
      proxy.$$state.status = 3
      resultStatus = proxy.$$state.value = false
      return resultStatus
    ).finally(()->
      processQueue(proxy.$$state)
    ).finally(()->
      delay = if resultStatus then config['success'] else config['failed']
      if delay > 0
        nextTick(finallyFn,delay)
      else
        finallyFn(delay)
    )
  makePromise = (deferred,resolved,value)->
    return unless deferred
    if resolved
      deferred.resolve(value)
    else
      deferred.reject(value)
    return
  processQueue = ($$state)->
    value = $$state.value
    status = $$state.status
    list = if $$state.isComplete then $$state.complete[status] else $$state.pending[status]

    for fn in list
      try
        value = fn(value)
      catch e
        $exceptionHandler(e)
        # break;
    return ($$state.value = value)

  completePromise = (deferred,resolved,delay)->
    if delay > 0
      nextTick(()->
        makePromise(deferred,resolved)
      ,delay)
    else
      makePromise(deferred,resolved)
    return

  class PromiseProxy
    constructor:(promise,config)->
      @$$state = {
        status:-1
        isComplete:false
        pending:[[],[],[],[]]
        complete:[[],[]]
      }
      @config = config
      @deferred = $q.defer()
      @promise = @deferred.promise
      self = @
      nextTick(()->
        listenPromise(promise,self)
      )
      return @
    then:(onLoading,onReady,onSuccess,onFailded)->
      for arg,i in arguments
        if i > 3
          break
        if arg
          @$$state.pending[i].push(arg)
      if(!@$$state.isComplete and !(arguments.length < @$$state.status ) and (fn = arguments[@$$state.status]))
        nextTick(fn)
      @
    thenF:(onFinish,onUnFinish)->
      for arg,i in arguments
        if i > 2
          break
        if arg
          @$$state.complete[i].push arg
      if(@$$state.isComplete and !(arguments.length < @$$state.status ) and (fn = arguments[@$$state.status]))
        nextTick(fn)
      @
    #status is 0
    loading:(fn)->
      @then(fn)
    #status is 1
    ready:(fn)->
      @then(null,fn)
    #status is 2
    success:(fn)->
      @then(null,null,fn)
    #status is 3
    failed:(fn)->
      @then(null,null,null,fn)

    #status is 1,isComplete is true
    finish:(fn)->
      @thenF(fn)
    #status is 2,isComplete is true
    unFinish:(fn)->
      @thenF(null,fn)
    #status is
    "finally":(fn)->
      @thenF(fn,fn)
      
  return PromiseProxy
]