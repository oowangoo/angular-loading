
module.controller("qStatusCtrl",()->
  @cases = {}
  return @
)
module.directive('qStatus',[()->
  restrict: 'AC'
  controller:"qStatusCtrl"
  require:["^qGroup",'qStatus']
  link:(scope,element,attrs,ctrls)->
    element.addClass("q-status")
    groupCtrl = ctrls[0]
    statusCtrl = ctrls[1]

    selectedElement = []
    
    changeStatus = (status)->
      for ele in selectedElement
        ele.remove()
      selectedElement.length = 0
      if (selected = statusCtrl.cases[status] || statusCtrl.cases["Default"]) 
        for sel in selected
          selectedElement.push sel
          element.append(sel)
    onPromise = (promiseProxy)->
      promiseProxy.loading(()->
        changeStatus('Loading')
      ).ready().success(()->
        changeStatus('Success')
      ).failed(()->
        changeStatus('Failed')
      ).finish(()->
        changeStatus("Default")
      )
    changeStatus("Default")
    groupCtrl.attend(onPromise)
    scope.$on("$destroy",()->
      groupCtrl.unAttend(onPromise)
    )
])
onStart = (element,cls,rmCls)->
  if cls then element.addClass(cls)
  if rmCls then element.removeClass(rmCls)
  return ;
onEnd = (element,cls,rmCls)->
  if cls then element.removeClass(cls)
  if rmCls then element.addClass(rmCls)
  return ;
createStatusDirectie = (type)->
  directiveName = "qStatus#{type}"
  lowerType = type.toLowerCase()
  module.directive(directiveName,[()->
    return {
      restrict: 'AC'
      require:"^qStatus"
      link:(scope,element,attrs,statusCtrl)->
        statusCtrl.cases[type] = statusCtrl.cases[type] || []
        statusCtrl.cases[type].push(element)
        element.addClass(lowerType)
        element.remove()
    }
  ])
for t in ['Success','Failed','Loading','Default']
  createStatusDirectie(t)

# add class or remove class
# module.directive(directiveName,[()->
#   return { 
#     restrict: 'A'
#     require:"^qGroup"
#     priority:1
#     compile:(tElement,tAttr)->
#       cls = tAttr[directiveName] || tAttr['addClass']
#       rmCls = tAttr["rmClass"]
#       return (scope,element,attrs,groupCtrl)->
        
#         return if !cls and !rmCls

#         onPromise = (promiseProxy)->
#           promiseProxy[lowerType](()->
#             onStart(element,cls,rmCls)
#           )
#           if type is 'Loading'
#             mn = 'ready'
#           else 
#             mn = 'finish'
#           promiseProxy[mn](()->
#             onEnd(element,cls,rmCls)
#           )

#         groupCtrl.attend(onPromise)
#         scope.$on("$destroy",()->
#           groupCtrl.unAttend(onPromise)
#         )
#   }
# ])
# module.directive('qStatus',[()->
#     return { 
#       restrict: 'A'
#       require:"^qGroup"
#       priority:2
#       compile:(tElement,tAttr)->
#         cls = tAttr["qStatusSuccess"] || tAttr["qStatusFailded"] || tAttr["addClass"]
#         rmCls = null
#         return (scope,element,attrs,groupCtrl)->
          
#           return if !cls and !rmCls

#           onPromise = (promiseProxy)->
#             promiseProxy.loading(()->
#               onEnd(element,cls,rmCls)
#             ).finish(()->
#               onStart(element,cls,rmCls)
#             )
#           onStart(element,cls,rmCls)
#           groupCtrl.attend(onPromise)
#           scope.$on("$destroy",()->
#             groupCtrl.unAttend(onPromise)
#           )
#     }
#   ])