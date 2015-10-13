module
.controller("qGroupCtrl",[()->
  promiseCtrlList = []
  config = null
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
    qPromiseCtrl.setConfig(config)
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
    return promiseCtrlList[0]

  @setConfig = (cf)->
    ;
  @
])
.directive("qGroup",[()->
  return {
    restrict: 'AC'
    require:"qGroup"
    controller:"qGroupCtrl"
    compile:(tElement,tAttrs)->
      #get attr config setting
      config = {}
      return (scope, element, attrs,qGroupCtrl) ->
        qGroupCtrl.setConfig(config)
        scope.qGroupCtrl = qGroupCtrl
  }
])
.directive("qInit",[()->
  return {
    require:["qGroup",'qInit']
    controller:"qPromiseCtrl"
    link:(scope,element,attrs,ctrls)->
      groupCtrl = ctrls[0]
      promiseCtrl = ctrls[1]

      p = scope.$eval(attrs.qInit);
      return unless angular.isPromise(p)

      groupCtrl.register promiseCtrl
      proxy = promiseCtrl.push p 
      proxy.loading(()->
        element.addClass("q-init")
      ).ready(()->
        element.removeClass("q-init")
        groupCtrl.remove(promiseCtrl)
      )
  }
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