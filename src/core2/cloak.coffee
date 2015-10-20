# q-cloak directive like ng-cloak 
# require qGroup 
qCloakDirective = ()->
  require:"^qGroup"
  link:(scope,element,attrs,groupCtrl)->
    forName = atts['qName']
    onPromise = (promiseProxy)->
      promiseProxy.success(()->
        element.removeClass("q-cloak")
        groupCtrl.unAttend(forName,onPromise) #remove handle
      )

    groupCtrl.attend(forName,onPromise) #add handle
    return