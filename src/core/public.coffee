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
.controller("qStatusCtrl",qStatusCtrl)

.directive("qCloak",qCloakDirective)
.directive("qGroup",qGroupDirective)
.directive("qInit",qInitDirective)
.directive("qOptions",qOptionsDirective)
.directive("qInitOptions",qInitOptionsDirective)
.directive("qStatus",qStatusDirective)

register = (name,direct)->
  module.directive(name,direct)

for name,event of qEventDirectives
  register(name,event)

for name,ss of qStatusDirectives
  register(name,ss)
