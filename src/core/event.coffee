module
.constant("qEventConfig",{
  animate:true
})

LOADING_CLASS = 'q-loading'
SUCCESS_CLASS = 'q-success'
FAILED_CLASS = 'q-failed'

eventAnimate = (proxy,element)->
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

getDirectiveName = (event)->
  n = event[0].toUpperCase()
  event = event.substr(1)
  return "q#{n}#{event}"

createEventDirective = (eventName)->
  directiveName = getDirectiveName(eventName)
  module.directive(directiveName,['$parse','qEventConfig',($parse,qEventConfig)->
    return {
      restrict: 'A'
      require:["?^qGroup",directiveName] 
      controller:"qPromiseCtrl"
      compile:(tElement,tAttrs)->
        fn = $parse(tAttrs[directiveName])
        #get attr config 
        config = getAttributeConfig(tAttrs)
        isAnimate = qEventConfig.animate
        return (scope, element, attrs,ctrls) ->
          qGroupCtrl = ctrls[0]
          qPromiseCtrl = ctrls[1]
          
          if qGroupCtrl
            qGroupCtrl.register qPromiseCtrl
            qPromiseCtrl.setConfig(qGroupCtrl.getConfig(),config)
          else 
            qPromiseCtrl.setConfig(config)
          element.on(eventName,(event)->
            return if qPromiseCtrl.get()

            callback = ()->
              return fn(scope, {$event:event})
            pm = scope.$apply(callback);

            return unless angular.isPromise(pm)

            proxy = qPromiseCtrl.push(pm)
            if isAnimate
              eventAnimate(proxy,element)
            proxy.finally(qPromiseCtrl.pop)
          )
          scope.$on("$destroy",()->
            if qGroupCtrl
              qGroupCtrl.remove qPromiseCtrl
          )
    }
  ])

for eventName in ['click','submit']
  createEventDirective(eventName)