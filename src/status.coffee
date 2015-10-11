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
        scope.$on("$destroy",()->
          groupCtrl.unAttend(onPromise)
        )
  }
])
createDirectie = (type)->
  directiveName = "qStatus#{type}"
  lowerType = type.toLowerCase()
  module.directive(directiveName,[()->
    return { 
      restrict: 'A'
      require:"^qGroup"
      compile:(tElement,tAttr)->
        cls = tAttr[directiveName]
        return (scope,element,attrs,groupCtrl)->
          
          return unless cls 

          onPromise = (promiseProxy)->
            promiseProxy[lowerType](()->
              element.addClass(cls)
            ).finish(()->
              element.removeClass(cls)
            )
          groupCtrl.attend(onPromise)
          scope.$on("$destroy",()->
            groupCtrl.unAttend(onPromise)
          )
    }
  ])

for t in ['Success','Failed']
  createDirectie(t)