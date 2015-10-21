Q_CLASS = "q-promise"

LOADING_CLASS = 'q-loading'
SUCCESS_CLASS = 'q-success'
FAILED_CLASS = 'q-failed'

$timeout =  null
module = angular.module("ng-loading",['ng'])
.run(['$timeout',(timeout)->
  $timeout = timeout
])

.constant("defaultOption",defaultOption)

.service("PromiseProxy",PromiseProxyService)

.controller("ControlCtrl",ControlCtrl)
.controller("GroupCtrl",GroupCtrl)

.directive("qCloakDirective",qCloakDirective)
.directive("qGroupDirective",qGroupDirective)
.directive("qInitDirective",qInitDirective)
.directive("qOptionsDirective",qOptionsDirective)
.directive("qStatusDirective",qStatusDirective)

for dct,event of qEventDirectives
  module.directive(event,dct)

for dct,status of qStatusDirectives
  module.directive(status,dct)
