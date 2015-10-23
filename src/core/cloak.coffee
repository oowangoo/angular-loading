# q-cloak directive like ng-cloak
# require qGroup
qCloakDirective = ()->
  require:"^qGroup"
  link:(scope,element,attrs,groupCtrl)->
    element.addClass("ng-cloak")
    forName = attrs['qName']
    onPromise = (promiseProxy)->
      promiseProxy.success(()->
        element.removeClass("ng-cloak")
        groupCtrl.unAttend(forName,onPromise) #remove handle
      )

    groupCtrl.attend(forName,onPromise) #add handle
    return