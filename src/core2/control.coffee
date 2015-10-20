
ControlCtrl = ['$element','$attrs','$scope','PromiseProxy','defaultOption',(element,attrs,scope,PromiseProxy,defaultOption)->
  control = @
  @$name = attrs['qName']
  @$option = defaultOption

  groupCtrl = element.controller('group') || element.parent().controller('group') || nullGroupCtrl
  
  groupCtrl.$addControl(@)

  listener = []

  emit = (proxy)->
    for l in listener
      l(proxy)
    return 

  eventAnimate = (proxy)->
    proxy.loading(()->
      element.removeClass("#{SUCCESS_CLASS} #{FAILED_CLASS}").addClass(LOADING_CLASS)
    ).ready(()->
      element.removeClass(LOADING_CLASS)
    ).success(()->
      element.addClass(SUCCESS_CLASS)
    ).failed(()->
      element.addClass(FAILED_CLASS)
    ).finish(()->
      element.removeClass("#{SUCCESS_CLASS} #{FAILED_CLASS}")
    )
  @setOption = (@$option)->;

  @attend = (fn)->
    if angular.isFunction fn 
      listener.push fn
    return 

  @unAttend = (fn)->
    arrayRemove(listener,fn)
    return 

  @handlePromise = (promise)->
    proxy = new PromiseProxy(promise,@$option)
    if @$option.animate
      eventAnimate(proxy);
    emit(proxy);
    return proxy

  scope.$on("$destroy",()->
    groupCtrl.$removeControl(control)
  )
  return @
]