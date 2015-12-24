(function() {
  var $timeout, ControlCtrl, FAILED_CLASS, GroupCtrl, LOADING_CLASS, PromiseProxyService, Q_CLASS, SUCCESS_CLASS, arrayRemove, createEventDirective, createStatusDirective, defaultOption, event, eventName, getDirectiveName, groupId, isBoolean, j, k, len, len1, module, name, nextTick, nullGroupCtrl, qCloakDirective, qEventDirectives, qGroupDirective, qInitDirective, qInitOptionsDirective, qOptionsDirective, qStatusCtrl, qStatusDirective, qStatusDirectives, ref, ref1, register, ss, t;

  angular.isPromise = angular.isPromise || function(obj) {
    return obj && angular.isFunction(obj.then);
  };

  isBoolean = function(value) {
    return typeof value === 'boolean';
  };

  nextTick = function(callback, delay) {
    if (callback && angular.isFunction(callback)) {
      return $timeout(callback, delay || 0);
    }
  };

  arrayRemove = function(array, value) {
    var index;
    index = array.indexOf(value);
    if (index >= 0) {
      array.splice(index, 1);
    }
    return value;
  };

  getDirectiveName = function(name, pre) {
    var n;
    if (!pre) {
      pre = 'q';
    }
    n = name[0].toUpperCase();
    name = name.substr(1);
    return "" + pre + n + name;
  };

  PromiseProxyService = [
    '$q', '$exceptionHandler', function($q, $exceptionHandler) {
      var PromiseProxy, completePromise, listenPromise, makePromise, processQueue;
      listenPromise = function(promise, proxy) {
        var config, endTime, finallyFn, resultStatus, startTime, timeline;
        finallyFn = function(delay) {
          proxy.$$state.isComplete = true;
          proxy.$$state.status = delay >= 0 ? 0 : 1;
          proxy.$$state.value = resultStatus;
          return processQueue(proxy.$$state);
        };
        config = proxy.config;
        startTime = endTime = new Date();
        timeline = 0;
        promise["finally"](function() {
          endTime = new Date();
          return timeline = endTime - startTime;
        }).then(function() {
          return completePromise(proxy.deferred, true, config.success - timeline);
        }, function() {
          return completePromise(proxy.deferred, false, config.failed - timeline);
        });
        proxy.$$state.status = 0;
        processQueue(proxy.$$state);
        resultStatus = null;
        return proxy.promise["finally"](function() {
          proxy.$$state.status = 1;
          return processQueue(proxy.$$state);
        }).then(function() {
          proxy.$$state.status = 2;
          resultStatus = proxy.$$state.value = true;
          return resultStatus;
        })["catch"](function() {
          proxy.$$state.status = 3;
          resultStatus = proxy.$$state.value = false;
          return resultStatus;
        })["finally"](function() {
          return processQueue(proxy.$$state);
        })["finally"](function() {
          var delay;
          delay = resultStatus ? config['success'] : config['failed'];
          if (delay > 0) {
            return nextTick(function() {
              return finallyFn(delay);
            }, delay);
          } else {
            return finallyFn(delay);
          }
        });
      };
      makePromise = function(deferred, resolved, value) {
        if (!deferred) {
          return;
        }
        if (resolved) {
          deferred.resolve(value);
        } else {
          deferred.reject(value);
        }
      };
      processQueue = function($$state) {
        var e, error, fn, j, len, list, status, value;
        value = $$state.value;
        status = $$state.status;
        list = $$state.isComplete ? $$state.complete[status] : $$state.pending[status];
        for (j = 0, len = list.length; j < len; j++) {
          fn = list[j];
          try {
            value = fn(value);
          } catch (error) {
            e = error;
            $exceptionHandler(e);
          }
        }
        return ($$state.value = value);
      };
      completePromise = function(deferred, resolved, delay) {
        if (delay > 0) {
          nextTick(function() {
            return makePromise(deferred, resolved);
          }, delay);
        } else {
          makePromise(deferred, resolved);
        }
      };
      PromiseProxy = (function() {
        function PromiseProxy(promise, config) {
          var self;
          this.$$state = {
            status: -1,
            isComplete: false,
            pending: [[], [], [], []],
            complete: [[], []]
          };
          this.config = config;
          this.deferred = $q.defer();
          this.promise = this.deferred.promise;
          self = this;
          nextTick(function() {
            return listenPromise(promise, self);
          });
          return this;
        }

        PromiseProxy.prototype.then = function(onLoading, onReady, onSuccess, onFailded) {
          var arg, fn, i, j, len;
          for (i = j = 0, len = arguments.length; j < len; i = ++j) {
            arg = arguments[i];
            if (i > 3) {
              break;
            }
            if (arg) {
              this.$$state.pending[i].push(arg);
            }
          }
          if (!this.$$state.isComplete && !(arguments.length < this.$$state.status) && (fn = arguments[this.$$state.status])) {
            nextTick(fn);
          }
          return this;
        };

        PromiseProxy.prototype.thenF = function(onFinish, onUnFinish) {
          var arg, fn, i, j, len;
          for (i = j = 0, len = arguments.length; j < len; i = ++j) {
            arg = arguments[i];
            if (i > 2) {
              break;
            }
            if (arg) {
              this.$$state.complete[i].push(arg);
            }
          }
          if (this.$$state.isComplete && !(arguments.length < this.$$state.status) && (fn = arguments[this.$$state.status])) {
            nextTick(fn);
          }
          return this;
        };

        PromiseProxy.prototype.loading = function(fn) {
          return this.then(fn);
        };

        PromiseProxy.prototype.ready = function(fn) {
          return this.then(null, fn);
        };

        PromiseProxy.prototype.success = function(fn) {
          return this.then(null, null, fn);
        };

        PromiseProxy.prototype.failed = function(fn) {
          return this.then(null, null, null, fn);
        };

        PromiseProxy.prototype.finish = function(fn) {
          return this.thenF(fn);
        };

        PromiseProxy.prototype.unFinish = function(fn) {
          return this.thenF(null, fn);
        };

        PromiseProxy.prototype["finally"] = function(fn) {
          return this.thenF(fn, fn);
        };

        return PromiseProxy;

      })();
      return PromiseProxy;
    }
  ];

  defaultOption = {
    loading: 0,
    success: 0,
    failed: 0,
    animate: true
  };

  qInitOptionsDirective = qOptionsDirective = [
    'defaultOption', function(defaultOption) {
      return {
        restrict: 'A',
        controller: [
          '$scope', '$attrs', function($scope, $attrs) {
            var j, len, ref, s;
            this.$options = $scope.$eval($attrs.qOptions);
            ref = ['success', 'failed', 'loading'];
            for (j = 0, len = ref.length; j < len; j++) {
              s = ref[j];
              if (!this.$options[s]) {
                this.$options[s] = this.$options['delay'] || 0;
              }
            }
            if (!this.$options.animate) {
              return this.$options.animate = defaultOption.animate;
            }
          }
        ]
      };
    }
  ];

  nullGroupCtrl = {
    $$id: 0,
    $$getControl: angular.noop,
    $$addGroupControl: angular.noop,
    $$removeGroupControl: angular.noop,
    $addControl: angular.noop,
    $removeControl: angular.noop,
    attend: angular.noop,
    unAttend: angular.noop
  };

  groupId = 1;

  GroupCtrl = [
    '$element', '$attrs', '$scope', function(element, attrs, scope) {
      var addUnAttend, controls, getAndRemoveUnAttend, groups, parentGroup, removeUnAttend, self, unAttendList;
      this.$$id = groupId++;
      this.$$parent = parentGroup = element.parent().controller("qGroup") || nullGroupCtrl;
      this.$name = attrs['qName'];
      this.$$parent.$$addGroupControl(this);
      groups = [];
      controls = {
        '@': []
      };
      unAttendList = {
        '@': []
      };
      addUnAttend = function(name, callback) {
        var array;
        array = unAttendList[name] || [];
        array.push(callback);
        unAttendList[name] = array;
      };
      getAndRemoveUnAttend = function(name) {
        var array;
        array = unAttendList[name];
        unAttendList[name] = null;
        return array;
      };
      removeUnAttend = function(name, callback) {
        var array;
        array = unAttendList[name];
        arrayRemove(array, callback);
      };
      this.$$getControl = function(name, exclude) {
        var control, g, j, len;
        if (name && name !== '@') {
          control = controls[name];
          if (!control) {
            control = this.$$parent.$$getControl(name, this);
          }
          if (!control) {
            for (j = 0, len = groups.length; j < len; j++) {
              g = groups[j];
              if (g === exclude) {
                continue;
              }
              control = g.$$getControl(name);
            }
          }
        } else {
          control = controls['@'];
          control = control && control.length ? control[control.length - 1] : null;
        }
        return control;
      };
      this.$$addGroupControl = function(groupCtrl) {
        groups.push(groupCtrl);
      };
      this.$$removeGroupControl = function(groupCtrl) {
        arrayRemove(groups, groupCtrl);
      };
      this.$addControl = function(control) {
        var callbacks, name;
        name = control.$name;
        if (name) {
          if (controls[name]) {
            throw new Error("same name control");
          }
          controls[name] = control;
        } else {
          controls['@'].push(control);
        }
        callbacks = getAndRemoveUnAttend(name);
        angular.forEach(callbacks, function(v) {
          return control.attend(v);
        });
      };
      this.$removeControl = function(control) {
        var name;
        name = control.$name;
        if (name) {
          if (controls[name]) {
            delete controls[name];
          }
        } else {
          arrayRemove(controls['@'], control);
        }
      };
      this.attend = function(name, callback) {
        var control;
        if (angular.isFunction(name)) {
          callback = name;
          name = null;
        }
        if (!angular.isFunction(callback)) {
          return;
        }
        control = this.$$getControl(name);
        if (control) {
          control.attend(callback);
        } else {
          addUnAttend(name, callback);
        }
        return control;
      };
      this.unAttend = function(name, callback) {
        var control;
        if (angular.isFunction(name)) {
          callback = name;
          name = null;
        }
        if (!angular.isFunction(callback)) {
          return;
        }
        control = this.$$getControl(name);
        if (control) {
          return control.unAttend(callback);
        } else {
          return removeUnAttend(name, callback);
        }
      };
      self = this;
      scope.$on("$destroy", function() {
        return self.$$parent.$$removeGroupControl(self);
      });
      return this;
    }
  ];

  qGroupDirective = [
    function() {
      return {
        name: 'qGroup',
        priority: 1300,
        controller: "GroupCtrl"
      };
    }
  ];

  ControlCtrl = [
    '$element', '$attrs', '$scope', 'PromiseProxy', 'defaultOption', function(element, attrs, scope, PromiseProxy, defaultOption) {
      var control, emit, eventAnimate, groupCtrl, listener;
      control = this;
      this.$name = attrs['qName'];
      this.$options = defaultOption;
      groupCtrl = element.controller('qGroup') || element.parent().controller('qGroup') || nullGroupCtrl;
      groupCtrl.$addControl(this);
      listener = [];
      emit = function(proxy) {
        var j, l, len;
        for (j = 0, len = listener.length; j < len; j++) {
          l = listener[j];
          l(proxy);
        }
      };
      eventAnimate = function(proxy) {
        return proxy.loading(function() {
          return element.removeClass(SUCCESS_CLASS + " " + FAILED_CLASS).addClass(LOADING_CLASS);
        }).ready(function() {
          return element.removeClass(LOADING_CLASS);
        }).success(function() {
          return element.addClass(SUCCESS_CLASS);
        }).failed(function() {
          return element.addClass(FAILED_CLASS);
        }).finish(function() {
          return element.removeClass(SUCCESS_CLASS + " " + FAILED_CLASS);
        });
      };
      this.setOption = function(option) {
        if (option) {
          this.$options = angular.extend({}, defaultOption, option);
        }
      };
      this.attend = function(fn) {
        if (angular.isFunction(fn)) {
          listener.push(fn);
        }
      };
      this.unAttend = function(fn) {
        arrayRemove(listener, fn);
      };
      this.handlePromise = function(promise) {
        var proxy;
        proxy = new PromiseProxy(promise, this.$options);
        if (this.$options.animate) {
          eventAnimate(proxy);
        }
        emit(proxy);
        return proxy;
      };
      scope.$on("$destroy", function() {
        return groupCtrl.$removeControl(control);
      });
      return this;
    }
  ];

  qEventDirectives = {};

  createEventDirective = function(name) {
    var directiveName;
    directiveName = getDirectiveName(name);
    return qEventDirectives[directiveName] = [
      '$parse', function($parse) {
        return {
          restrict: 'A',
          controller: "ControlCtrl",
          require: ['?^qOptions', directiveName],
          compile: function(tElement, tAttrs) {
            var fn;
            fn = $parse(tAttrs[directiveName]);
            return function(scope, element, attrs, ctrls) {
              var control, excute, lastPromise, onPromise, qOptions;
              lastPromise = null;
              qOptions = ctrls[0] && ctrls[0].$options ? ctrls[0].$options : null;
              control = ctrls[1];
              control.setOption(qOptions);
              onPromise = function(promise) {
                var proxy;
                lastPromise = proxy = control.handlePromise(promise);
                proxy.loading(function() {
                  return element.addClass(Q_CLASS);
                }).finish(function() {
                  return element.removeClass(Q_CLASS);
                })["finally"](function() {
                  return lastPromise = null;
                });
                return proxy;
              };
              excute = function() {
                var callback, eventResult;
                if (lastPromise) {
                  return false;
                }
                callback = function() {
                  return fn(scope, {
                    $event: event
                  });
                };
                eventResult = scope.$apply(callback);
                if (!angular.isPromise(eventResult)) {
                  return true;
                }
                onPromise(eventResult);
                return true;
              };
              element.on(name, excute);
            };
          }
        };
      }
    ];
  };

  ref = ['click', 'submit'];
  for (j = 0, len = ref.length; j < len; j++) {
    eventName = ref[j];
    createEventDirective(eventName);
  }

  qInitDirective = [
    'defaultOption', function(defaultOption) {
      var dfInitOptions;
      dfInitOptions = angular.copy(defaultOption);
      dfInitOptions.failed = -1;
      return {
        restrict: 'A',
        controller: "ControlCtrl",
        require: ['?^qInitOptions', 'qInit'],
        link: function(scope, element, attrs, ctrls) {
          var control, excute, lastPromise, onPromise, options;
          lastPromise = null;
          options = ctrls[0] && ctrls[0].$options ? ctrls[0].$options : dfInitOptions;
          control = ctrls[1];
          control.setOption(options);
          onPromise = function(promise) {
            var proxy;
            lastPromise = proxy = control.handlePromise(promise);
            proxy.loading(function() {
              return element.addClass('q-init').addClass(Q_CLASS);
            }).success(function() {
              return element.removeClass("q-init").removeClass(Q_CLASS);
            })["finally"](function() {
              return lastPromise = null;
            });
          };
          excute = function() {
            var result;
            if (lastPromise) {
              return false;
            }
            result = scope.$eval(attrs.qInit);
            if (!angular.isPromise(result)) {
              return true;
            }
            onPromise(result);
            return true;
          };
          excute();
          return control.run = excute;
        }
      };
    }
  ];

  qStatusCtrl = function() {
    this.cases = {};
    return this;
  };

  qStatusDirective = [
    function() {
      return {
        restrict: 'EA',
        controller: "qStatusCtrl",
        require: ["^qGroup", 'qStatus'],
        link: function(scope, element, attrs, ctrls) {
          var changeStatus, forName, groupCtrl, onPromise, selectedElements, selectedScopes, statusCtrl;
          forName = attrs['qFor'];
          element.addClass("q-status");
          groupCtrl = ctrls[0];
          statusCtrl = ctrls[1];
          selectedElements = [];
          selectedScopes = [];
          changeStatus = function(status) {
            var ele, i, k, len1, len2, m, sel, selected;
            for (i = k = 0, len1 = selectedElements.length; k < len1; i = ++k) {
              ele = selectedElements[i];
              selectedScopes[i].$destroy();
              ele.clone.remove();
            }
            if (selectedElements.length === 0) {
              element.removeClass("ng-hide");
            }
            selectedElements.length = 0;
            selectedScopes.length = 0;
            if ((selected = statusCtrl.cases[status] || statusCtrl.cases["default"])) {
              for (m = 0, len2 = selected.length; m < len2; m++) {
                sel = selected[m];
                sel.transclude(function(caseElement, selectedScope) {
                  var anchor, block;
                  caseElement.addClass(status.toLowerCase());
                  selectedScopes.push(selectedScope);
                  anchor = sel.element;
                  block = {
                    clone: caseElement
                  };
                  selectedElements.push(block);
                  return anchor.after(caseElement);
                });
              }
            }
            if (selectedElements.length === 0) {
              return element.addClass("ng-hide");
            }
          };
          onPromise = function(proxy) {
            return proxy.loading(function() {
              return changeStatus('loading');
            }).ready().success(function() {
              return changeStatus('success');
            }).failed(function() {
              return changeStatus('failed');
            }).finish(function() {
              return changeStatus("default");
            });
          };
          changeStatus("Default");
          groupCtrl.attend(forName, onPromise);
          return scope.$on("$destroy", function() {
            return groupCtrl.unAttend(forName, onPromise);
          });
        }
      };
    }
  ];

  qStatusDirectives = {};

  createStatusDirective = function(type) {
    var directiveName;
    directiveName = getDirectiveName(type, 'qStatus');
    qStatusDirectives[directiveName] = function() {
      return {
        restrict: 'A',
        require: "^qStatus",
        priority: 1200,
        transclude: 'element',
        link: function(scope, element, attrs, statusCtrl, $transclude) {
          statusCtrl.cases[type] = statusCtrl.cases[type] || [];
          statusCtrl.cases[type].push({
            transclude: $transclude,
            element: element
          });
        }
      };
    };
  };

  ref1 = ['success', 'failed', 'loading', 'default'];
  for (k = 0, len1 = ref1.length; k < len1; k++) {
    t = ref1[k];
    createStatusDirective(t);
  }

  qCloakDirective = function() {
    return {
      require: "^qGroup",
      link: function(scope, element, attrs, groupCtrl) {
        var forName, onPromise;
        element.addClass("ng-cloak");
        forName = attrs['qName'];
        onPromise = function(promiseProxy) {
          return promiseProxy.success(function() {
            element.removeClass("ng-cloak");
            return groupCtrl.unAttend(forName, onPromise);
          });
        };
        groupCtrl.attend(forName, onPromise);
      }
    };
  };

  Q_CLASS = "q-promise";

  LOADING_CLASS = 'q-loading';

  SUCCESS_CLASS = 'q-success';

  FAILED_CLASS = 'q-failed';

  $timeout = null;

  module = angular.module("ng-loading", ['ng']).run([
    '$timeout', function(timeout) {
      return $timeout = timeout;
    }
  ]).constant("defaultOption", defaultOption).service("PromiseProxy", PromiseProxyService).controller("ControlCtrl", ControlCtrl).controller("GroupCtrl", GroupCtrl).controller("qStatusCtrl", qStatusCtrl).directive("qCloak", qCloakDirective).directive("qGroup", qGroupDirective).directive("qInit", qInitDirective).directive("qOptions", qOptionsDirective).directive("qInitOptions", qInitOptionsDirective).directive("qStatus", qStatusDirective);

  register = function(name, direct) {
    return module.directive(name, direct);
  };

  for (name in qEventDirectives) {
    event = qEventDirectives[name];
    register(name, event);
  }

  for (name in qStatusDirectives) {
    ss = qStatusDirectives[name];
    register(name, ss);
  }

}).call(this);
