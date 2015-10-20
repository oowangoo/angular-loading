qStatusCtrl = ()->
  @cases = {}
  return @

qStatusDirective = [()->
  restrict: 'EA'
  controller:"qStatusCtrl"
  require:["^qGroup",'qStatus']
  link:(scope,element,attrs,ctrls)->
    forName = attrs['qFor']

    element.addClass("q-status")
    groupCtrl = ctrls[0]
    statusCtrl = ctrls[1]

    selectedElements = []
    selectedScopes = []

    changeStatus = (status)->
      for ele,i in selectedElements
        selectedScopes[i].$destroy()
        ele.clone.remove()

      if selectedElements.length is 0
        element.removeClass("ng-hide")
      
      selectedElements.length = 0
      selectedScopes.length = 0 
      if (selected = statusCtrl.cases[status] || statusCtrl.cases["Default"]) 
        for sel in selected
          sel.transclude((caseElement,selectedScope)->
            caseElement.addClass(status.toLowerCase())
            selectedScopes.push(selectedScope);
            anchor = sel.element
            block = { clone: caseElement}
            selectedElements.push(block);
            anchor.after(caseElement)
          )
      
      if selectedElements.length is 0 
        element.addClass("ng-hide")

    onPromise = (proxy)->
      proxy.loading(()->
        changeStatus('Loading')
      ).ready().success(()->
        changeStatus('Success')
      ).failed(()->
        changeStatus('Failed')
      ).finish(()->
        changeStatus("Default")
      )

    changeStatus("Default")
  
    groupCtrl.attend(forName,onPromise)
    scope.$on("$destroy",()->
      groupCtrl.unAttend(forName,onPromise)
    )
]

qStatusDirectives = {}

createStatusDirectie = (type)->
  directiveName = getDirectiveName(type,'qStatus')
  qStatusDirectives[directiveName] = ()->
    return {
      restrict: 'AC'
      require:"^qStatus"
      priority:1200
      transclude: 'element'
      link:(scope,element,attrs,statusCtrl,$transclude)->
        statusCtrl.cases[type] = statusCtrl.cases[type] || []
        statusCtrl.cases[type].push({ transclude: $transclude, element: element })
        return ;
    }
for t in ['success','failed','loading','default']
  createStatusDirectie(t)