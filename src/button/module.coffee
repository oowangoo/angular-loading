STATUS = """<span q-status><i class="icon-check"q-status-default></i> <i class="icon-spinner9" q-status-loading></i> <i class="icon-close" q-status-failed></i></span>"""

angular.module("q-button",['ng-loading'])
.directive("btnInside",[()->
  return {
    restrict: 'C'
    replace:true
    priority:1000
    template:(element,attr)->
      element.prepend(STATUS)
      html = element.html()
      tag = element[0].tagName
      return "<#{tag} q-group delay='-1'>#{html}</#{tag}>";
  }
])
.directive("btnOutsideGroup",[()->
  template = """<span q-status><i class="icon-check success"q-status-success></i> <i class="icon-spinner9 loading" q-status-loading></i> <i class="icon-close failed" q-status-failed></i></span>"""
  return {
    restrict: 'C'
    replace:true
    transclude:true
    priority:1000
    template:(element,attr)->
      tag = element[0].tagName
      return "<#{tag} q-group delay='2000' loading='300'><ng-transclude></ng-transclude>#{template}</#{tag}>";
  }
])