module.directive('qStatusLoading',[()->
  return { 
    restrict: 'A'
    require:"^qGroup"
    compile:(tElement,tAttr)->
      cls = tAttr['qStatusLoading']
      return (scope,element,attrs,groupCtrl)->
        
        return unless cls 

        onPromise = (promiseProxy)->
          promiseProxy.loading(()->
            element.addClass(cls)
          ).ready(()->
            element.removeClass(cls)
          )
        groupCtrl.attend(onPromise)
        scope.$on("#$destroy",()->
          promiseCtrl.unAttend(onPromise)
        )
  }
])

  module.directive('qStatusSuccess',[()->
    return { 
      restrict: 'A'
      require:"^qGroup"
      compile:(tElement,tAttr)->
        cls = tAttr['qStatusLoading']
        return (scope,element,attrs,groupCtrl)->
          
          return unless cls 

          onPromise = (promiseProxy)->
            promiseProxy.loading(()->
              element.addClass(cls)
            ).ready(()->
              element.removeClass(cls)
            )
          groupCtrl.attend(onPromise)
          scope.$on("#$destroy",()->
            promiseCtrl.unAttend(onPromise)
          )
    }
  ])