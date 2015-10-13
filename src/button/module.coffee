STATUS = """<span class="status"  q-status><i class="icon-check success"q-status-default></i> <i class="icon-spinner9 loading" q-status-loading></i> <i class="icon-close failed" q-status-failed></i></span>"""

angular.module("q-button",['ng-loading'])
.directive("btnInside",[()->
  return {
    restrict: 'C'
    replace:true
    template:(element,attr)->
      element.prepend(STATUS)
      html = element.html()
      tag = element[0].tagName
      return "<#{tag} q-group>#{html}</#{tag}>";
  }
])
.directive("btnOutsideGroup",[()->
  template = """<span class="status"  q-status><i class="icon-check success"q-status-success></i> <i class="icon-spinner9 loading" q-status-loading></i> <i class="icon-close failed" q-status-failed></i></span>"""
  return {
    restrict: 'C'
    replace:true
    transclude:true
    template:(element,attr)->
      tag = element[0].tagName
      return "<#{tag} q-group><ng-transclude></ng-transclude>#{template}</#{tag}>";
  }
])