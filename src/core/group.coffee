nullGroupCtrl = {
  register:angular.noop
  remove:angular.noop
  attend:angular.noop
  unAttend:angular.noop
  get:angular.noop
  getConfig:angular.noop
  setConfig:angular.noop
}
module
.controller("qGroupCtrl",['$attrs',($attrs)->
  promiseCtrlList = []
  config = getAttributeConfig($attrs)
  unAttendList = []

  processQueue = (promiseCtrl)->
    temp = []
    for atd in unAttendList
      ctrl = atd.ctrl
      fn = atd.callback
      if !ctrl or ctrl is promiseCtrl
        promiseCtrl.attend(fn)
      else 
        temp.push atd
    unAttendList = temp

  @register = (qPromiseCtrl)->
    # qPromiseCtrl.setConfig(config)
    promiseCtrlList.push qPromiseCtrl
    processQueue(qPromiseCtrl)

  @remove = (ctrl)->
    r = null
    i = promiseCtrlList.indexOf(ctrl)
    #remove this node
    if i > -1 
      r = promiseCtrlList.splice(i,1)
    return r ;
  
  @attend = ( promiseCtrl,fn)->
    unless fn
      fn =  promiseCtrl
      promiseCtrl = @get()
    if promiseCtrl #maybe find ctrl by name
      promiseCtrl.attend(fn)
    else 
      unAttendList.push({ctrl:promiseCtrl,callback:fn})
  @unAttend = ( promiseCtrl,fn)->
    unless fn
      fn =  promiseCtrl
      promiseCtrl = @get()
    if promiseCtrl #maybe find ctrl by name
      promiseCtrl.unAttend(fn)

  @get = ()->
    return if promiseCtrlList.length then promiseCtrlList[promiseCtrlList.length - 1] else null
  @getConfig = ()->
    return config;
  @setConfig = (cf)->
    config = cf
  @
])
.directive("qGroup",[()->
  return {
    restrict: 'AC'
    require:"qGroup"
    controller:"qGroupCtrl"
    compile:(tElement,tAttrs)->
      #get attr config setting
      return (scope, element, attrs,qGroupCtrl) ->
        scope.qGroupCtrl = qGroupCtrl
  }
])
.directive("qInit",[()->
  config = {
    failed:{
      delay:-1
    }
    delay:0
  }
  return {
    require:["?qGroup",'qInit']
    controller:"qPromiseCtrl"
    link:(scope,element,attrs,ctrls)->
      groupCtrl = ctrls[0] || nullGroupCtrl
      promiseCtrl = ctrls[1]
      promiseCtrl.setConfig(config)
      groupCtrl.register promiseCtrl

      excute = ()->
        return if promiseCtrl.get()
        p = scope.$eval(attrs.qInit);
        unless angular.isPromise(p) 
          groupCtrl.remove(promiseCtrl)      
          return ;
        proxy = promiseCtrl.push p 
        proxy.loading(()->
          element.addClass("q-init")
        ).success(()->
          element.removeClass("q-init")
          groupCtrl.remove(promiseCtrl)
        ) .finally(promiseCtrl.pop)
        return ;
      excute()
      
      promiseCtrl.retry = excute
      return ;

  }
])
.directive("qRetry",[()->
  restrict:"A"
  require:"^qInit"
  priority:5
  link:(scope,element,attrs,qInitCtrl)->
    element.on('click',()->
      qInitCtrl.retry()
      return ;
    )
    return ;
])
.directive("qCloak",[()->
  restrict:"C"
  require:"^qGroup"
  link:(scope,element,attrs,groupCtrl)->

    groupCtrl.attend((promiseProxy)->
      promiseProxy.success(()->
        element.removeClass("q-cloak")
      )
    )
])