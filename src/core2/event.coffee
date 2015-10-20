qEventDirectives = {}

createEventDirective = (name)->
  directiveName = getDirectiveName(eventName)
  qEventDirectives[directiveName] = ['$parse',($parse)->
    return {
      restrict: 'A'
      controller:"ControlCtrl"
      require:['qOptions',directiveName]
      compile:(tElement,tAttrs)->
        fn = $parse(tAttrs[directiveName])
          
        return (scope, element, attrs,ctrls) ->
          lastPromise = null

          qOptions = ctrls[0]
          control = ctrls[1]
          control.setOption(qOptions)

          onPromise = (promise)->
            lastPromise = proxy = control.handlePromise(promise)
            proxy.loading(()->
              element.addClass(Q_CLASS)
            ).finish(()->
              element.removeClass(Q_CLASS)
            ).finally(()->
              lastPromise = null
            )
            eventAnimate(proxy)
            return proxy;

          excute = ()->
            return false if lastPromise

            callback = ()->
              return fn(scope, {$event:event})
            eventResult = scope.$apply(callback)

            return true unless angular.isPromise eventResult

            onPromise(eventResult)
            return true

          element.on(eventName,excute)

    }
  ]

for eventName in ['click','submit']
  createEventDirective(eventName)