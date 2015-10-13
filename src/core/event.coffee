module
.constant("qEventConfig",{
  animate:true
})
.constant("qClass",{
  loading:'q-loading'
  success:'q-success'
  failed:'q-failed'
})
.directive('qClick',['$parse','qClass','qEventConfig',($parse,qClass,qEventConfig)->
  return {
    restrict: 'A'
    require:["?^qGroup","qClick"] 
    controller:"qPromiseCtrl"
    compile:(tElement,tAttrs)->
      fn = $parse(tAttrs["qClick"])
      #get attr config 
      config = {
        delay:tAttrs['delay']
        failed:{
          delay:tAttrs['failed']
        }
        success:{
          delay:tAttrs['success']
        }
        loading:{
          delay:tAttrs['loading']
        }
      }
      isAnimate = qEventConfig.animate
      return (scope, element, attrs,ctrls) ->
        qGroupCtrl = ctrls[0]
        qPromiseCtrl = ctrls[1]
        
        if qGroupCtrl
          qGroupCtrl.register qPromiseCtrl

        qPromiseCtrl.setConfig config

        element.on('click',(event)->
          return if qPromiseCtrl.get()

          callback = ()->
            return fn(scope, {$event:event});
          pm = scope.$apply(callback);

          return unless angular.isPromise(pm)

          proxy = qPromiseCtrl.push(pm)
          if isAnimate
            proxy.loading(()->
              element.removeClass("#{qClass.success} #{qClass.failed}").addClass(qClass.loading)
            ).ready(()->
              element.removeClass(qClass.loading)
            ).success(()->
              element.addClass(qClass.success)
            ).failed(()->
              element.addClass(qClass.failed)
            ).finish(()->
              element.removeClass("#{qClass.success} #{qClass.failed}")
            )
          proxy.finally(qPromiseCtrl.pop)
        )
        scope.$on("$destroy",()->
          if qGroupCtrl
            qGroupCtrl.remove qPromiseCtrl
        )
  }
])