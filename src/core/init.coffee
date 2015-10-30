qInitDirective = ['defaultOption',(defaultOption)->
  dfInitOptions = angular.copy(defaultOption)
  dfInitOptions.failed = -1
  return {
    restrict: 'A'
    controller:"ControlCtrl"
    priority:1000
    require:['?^qInitOptions','qInit']
    link:(scope, element, attrs,ctrls)->
      console.log 'q init'
      lastPromise = null

      options = if ctrls[0] and ctrls[0].$options then ctrls[0].$options else dfInitOptions
      control = ctrls[1]
      control.setOption(options)

      onPromise = (promise)->
        lastPromise = proxy = control.handlePromise(promise)
        proxy.loading(()->
          element.addClass('q-init').addClass(Q_CLASS)
        ).success(()->
          element.removeClass("q-init").removeClass(Q_CLASS)
        ).finally(()->
          lastPromise = null
        )
        return

      excute = ()->
        return false if lastPromise

        result = scope.$eval(attrs.qInit)
        unless angular.isPromise(result)
          return true
        onPromise(result)
        return true

      excute()

      control.run = excute
  }
]