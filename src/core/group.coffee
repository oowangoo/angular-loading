nullGroupCtrl = {
  $$id : 0  #调试用属性
  $$getControl:angular.noop
  $$addGroupControl:angular.noop
  $$removeGroupControl:angular.noop

  $addControl : angular.noop
  $removeControl: angular.noop

  attend:angular.noop
  unAttend:angular.noop
}
groupId = 1
GroupCtrl = ['$element','$attrs','$scope',(element,attrs,scope)->
  @$$id = groupId++
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
    return unless array
    arrayRemove(array,callback)
    return

  #private
  @$$getControl = (name,exclude)->
    if name and name isnt '@'
      control = controls[name]
      if !control
        control = @$$parent.$$getControl(name,@)
      if !control
        for g in groups
          if g is exclude
            continue
          control = g.$$getControl(name)
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
      name = '@'
      controls[name].push control
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
    if name is '@'
      throw new Error('q control name can\'t be @' )
    if angular.isFunction(name)
      callback = name
      name = null
    if !angular.isFunction(callback)
      return
    name = name || '@'
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
    name = name || '@'
    control = @$$getControl(name)
    # 如果control先调用removeControl，此处会找不到control
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
  priority:1300
  controller: "GroupCtrl"
  }
]