module
.controller("qPromiseCtrl",['PromiseProxy',(PromiseProxy)->
  lastPromise = null
  config = null
  
  listener = []

  @setConfig = ()->
    config = PromiseProxy.extendConfig(arguments)
  @getConfig = ()->
    return config
  @get = ()->
    return lastPromise
  @pop = ()->
    l = lastPromise
    lastPromise = null
    return l
  @push = (promise)->
    lastPromise = PromiseProxy.$new(promise,config)
    nextTick(()->
      emit(lastPromise)
    )
    
    return lastPromise
  
  emit = (promiseProxy)->
    for l in listener
      l(promiseProxy)

  @attend = (fn)->
    listener.push fn
  @unAttend = (fn)->
    r = null
    i = listener.indexOf(fn)
    #remove this node
    if i > -1 
      r = listener.splice(i,1)
    return r ;
  @
])