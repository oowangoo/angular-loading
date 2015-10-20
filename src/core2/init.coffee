qInitDirective = [()->
  return {
    restrict: 'A'
    controller:"ControlCtrl"
    require:['qOptions','qInit']
    link:(scope, element, attrs,ctrls)->
      lastPromise = null

      qOptions = ctrls[0]
      control = ctrls[1]
      control.setOption(qOptions)

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

        result = scope.$eval(attrs.qInit);
        unless angular.isPromise(result)
          return true
        onPromise(result)
        return true

      excute()

      control.run = excute
  }
]