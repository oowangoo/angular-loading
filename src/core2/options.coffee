defaultOption = {
  loading:0
  success:0
  failed:0
  animate:true
}
qInitOptionsDirective = qOptionsDirective = ['defaultOption',(defaultOption)->
  return {
    restrict: 'A',
    controller:['$scope','$attrs',($scope,$attrs)->
      @$options = $scope.$eval($attrs.qOptions)
      for s in ['success','failed','loading']
        unless @$options[s]
          @$options[s] = @$options['delay'] || 0
      unless @$options.animate
        @$options.animate = defaultOption.$options.animate
    ]
  }
]