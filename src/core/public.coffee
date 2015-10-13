angular.isPromise = angular.isPromise || (obj)->return obj && angular.isFunction(obj.then);

isBoolean = ( value)->
  return typeof value is 'boolean';

extendOptions = (df)->
  `
  var opt = angular.copy(df) || {}
  for(var i = 1,ii = arguments.length; i < ii; i++){
    var obj = arguments[i]
    if(obj){
      var keys = Object.keys(obj);
      for (var j = 0, jj = keys.length; j < jj; j++) {
        var key = keys[j]
        var vl = obj[key]
        if(angular.isObject(vl))
          opt[key] = extendOptions(opt[key],vl)
        else if(vl || isBoolean(vl) || angular.isNumber(vl))
          opt[key] = vl
      }
    }
  }
  `
  return opt
$timeout = null
nextTick = (callback,delay)->
  if callback and angular.isFunction(callback)
    $timeout(callback,delay||0)
    
module = angular.module("ng-loading",['ng']).run(['$timeout',($t)->
  $timeout = $t
])