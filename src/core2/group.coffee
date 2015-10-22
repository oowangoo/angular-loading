nullGroupCtrl = {
  $$getControl:angular.noop
  $$addGroupControl:angular.noop
  $$removeGroupControl:angular.noop

  $addControl : angular.noop
  $removeControl: angular.noop

  attend:angular.noop
  unAttend:angular.noop
}

GroupCtrl = ['$element','$attrs','$scope',(element,attrs,scope)->
  console.log 'qGroupCtrl'
  @$$parent = parentGroup = element.parent().controller("qGroup") || nullGroupCtrl
  @$name = attrs['qName']

  @$$parent.$$addGroupControl(@)

  groups = [] #childs


  controls = {
    '@':[]
  }

  unAttendList = {'@':[] } # un attend list

  addUnAttend = (name,callback)->
    array = unAttendList[name] || []
    array.push callback
    unAttendList[name] = array
    return
  getAndRemoveUnAttend = (name)->
    array = unAttendList[name]
    unAttendList[name] = null
    return array
  removeUnAttend = (name,callback)->
    array = unAttendList[name]
    arrayRemove(array,callback)
    return

  #private
  @$$getControl = (name)->
    if name and name isnt '@'
      control = controls[name]
      while @$$parent and !control
        control = @$$parent.$$getControl(name)
    else
      control = controls['@'] #array
      control = if control and control.length then control[control.length-1] else null
    return control
  @$$addGroupControl = (groupCtrl)->
    groups.push groupCtrl
    return
  @$$removeGroupControl = (groupCtrl)->
    arrayRemove(groups,groupCtrl)
    return
  #protected
  @$addControl = (control)->
    name = control.$name
    if name
      if controls[name]
        throw new Error("same name control")
      controls[name] = control
    else
      controls['@'].push control
    callbacks = getAndRemoveUnAttend(name)
    angular.forEach(callbacks,(v)->
      control.attend(v)
    )
    return

  @$removeControl = (control)->
    name = control.$name
    
    if name
      if controls[name]
        delete controls[name]
    else
      arrayRemove(controls['@'],control)

    return
  #public

  @attend=(name,callback)->
    if angular.isFunction(name)
      callback = name
      name = null
    if !angular.isFunction(callback)
      return

    control = @$$getControl(name)
    #no control add list
    if control
      control.attend(callback)
    else
      addUnAttend(name,callback)

    return control

  @unAttend=(name,callback)->
    if angular.isFunction(name)
      callback = name
      name = null
    if !angular.isFunction(callback)
      return
    control = @$$getControl(name)
    if control
      control.unAttend(callback)
    else
      removeUnAttend(name,callback)

  self = @
  scope.$on("$destroy",()->
    self.$$parent.$$removeGroupControl(self)
  )
  return @
]

qGroupDirective = [()->
  return {
  name: 'qGroup'
  controller: "GroupCtrl"
  }
]