angular.isPromise = angular.isPromise || (obj)->return obj && angular.isFunction(obj.then);

isBoolean = ( value)->
  return typeof value is 'boolean';
  
nextTick = (callback,delay)->
  if callback and angular.isFunction(callback)
    $timeout(callback,delay||0)

arrayRemove = (array, value)->
  var index = array.indexOf(value)
  if (index >= 0)
    array.splice(index, 1)
  return value

getDirectiveName = (name,pre)->
  unless pre 
    pre = 'q'
  n = name[0].toUpperCase()
  name = name.substr(1)
  return "#{pre}#{n}#{name}"