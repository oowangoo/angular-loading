(function() {
  var $timeout, FAILED_CLASS, LOADING_CLASS, Q_CLASS, SUCCESS_CLASS, createEventDirective, createStatusDirectie, eventAnimate, eventName, extendOptions, getAttributeConfig, getDirectiveName, isBoolean, j, k, len, len1, module, nextTick, nullGroupCtrl, onEnd, onStart, ref, ref1, t;

  angular.isPromise = angular.isPromise || function(obj) {
    return obj && angular.isFunction(obj.then);
  };

  isBoolean = function(value) {
    return typeof value === 'boolean';
  };

  extendOptions = function(df) {
    
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
  ;
    return opt;
  };

  $timeout = null;

  nextTick = function(callback, delay) {
    if (callback && angular.isFunction(callback)) {
      return $timeout(callback, delay || 0);
    }
  };

  getAttributeConfig = function(attrs) {
    var config, j, len, readStatus, ref, s;
    config = {};
    if (angular.isDefined(attrs['delay'])) {
      config.delay = parseInt(attrs['delay']);
    }
    readStatus = function(state) {
      config[state] = {};
      if (angular.isDefined(attrs[state])) {
        return config[state].delay = parseInt(attrs[state]);
      } else {
        return config[state].delay = config.delay;
      }
    };
    ref = ['success', 'failed', 'loading'];
    for (j = 0, len = ref.length; j < len; j++) {
      s = ref[j];
      readStatus(s);
    }
    return config;
  };

  module = angular.module("ng-loading", ['ng']).run([
    '$timeout', function($t) {
      return $timeout = $t;
    }
  ]);

  Q_CLASS = "q-promise";

  LOADING_CLASS = 'q-loading';

  SUCCESS_CLASS = 'q-success';

  FAILED_CLASS = 'q-failed';

  module.controller("qPromiseCtrl", [
    'PromiseProxy', '$attrs', function(PromiseProxy, $attrs) {
      var config, emit, lastPromise, listener;
      lastPromise = null;
      config = null;
      listener = [];
      this.setConfig = function() {
        var args;
        args = null;
        if (arguments.length > 0) {
          args = Array.prototype.slice.call(arguments);
        }
        return config = PromiseProxy.extendConfig(args);
      };
      this.getConfig = function() {
        return config;
      };
      this.get = function() {
        return lastPromise;
      };
      this.pop = function() {
        var l;
        l = lastPromise;
        lastPromise = null;
        return l;
      };
      this.push = function(promise) {
        lastPromise = PromiseProxy.$new(promise, config);
        nextTick(function() {
          return emit(lastPromise);
        });
        return lastPromise;
      };
      emit = function(promiseProxy) {
        var j, l, len, results;
        results = [];
        for (j = 0, len = listener.length; j < len; j++) {
          l = listener[j];
          results.push(l(promiseProxy));
        }
        return results;
      };
      this.attend = function(fn) {
        return listener.push(fn);
      };
      this.unAttend = function(fn) {
        var i, r;
        r = null;
        i = listener.indexOf(fn);
        if (i > -1) {
          r = listener.splice(i, 1);
        }
        return r;
      };
      return this;
    }
  ]);

  module.constant("qEventConfig", {
    animate: true
  });

  eventAnimate = function(proxy, element) {
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

  getDirectiveName = function(event) {
    var n;
    n = event[0].toUpperCase();
    event = event.substr(1);
    return "q" + n + event;
  };

  createEventDirective = function(eventName) {
    var directiveName;
    directiveName = getDirectiveName(eventName);
    return module.directive(directiveName, [
      '$parse', 'qEventConfig', function($parse, qEventConfig) {
        return {
          restrict: 'A',
          require: ["?^qGroup", directiveName],
          controller: "qPromiseCtrl",
          compile: function(tElement, tAttrs) {
            var config, fn, isAnimate;
            fn = $parse(tAttrs[directiveName]);
            config = getAttributeConfig(tAttrs);
            isAnimate = qEventConfig.animate;
            return function(scope, element, attrs, ctrls) {
              var qGroupCtrl, qPromiseCtrl;
              qGroupCtrl = ctrls[0];
              qPromiseCtrl = ctrls[1];
              if (qGroupCtrl) {
                qGroupCtrl.register(qPromiseCtrl);
                qPromiseCtrl.setConfig(qGroupCtrl.getConfig(), config);
              } else {
                qPromiseCtrl.setConfig(config);
              }
              element.on(eventName, function(event) {
                var callback, pm, proxy;
                if (qPromiseCtrl.get()) {
                  return;
                }
                callback = function() {
                  return fn(scope, {
                    $event: event
                  });
                };
                pm = scope.$apply(callback);
                if (!angular.isPromise(pm)) {
                  return;
                }
                proxy = qPromiseCtrl.push(pm);
                proxy.loading(function() {
                  return element.addClass(Q_CLASS);
                });
                if (isAnimate) {
                  eventAnimate(proxy, element);
                }
                return proxy["finally"](qPromiseCtrl.pop)["finally"](function() {
                  return element.removeClass(Q_CLASS);
                });
              });
              return scope.$on("$destroy", function() {
                if (qGroupCtrl) {
                  return qGroupCtrl.remove(qPromiseCtrl);
                }
              });
            };
          }
        };
      }
    ]);
  };

  ref = ['click', 'submit'];
  for (j = 0, len = ref.length; j < len; j++) {
    eventName = ref[j];
    createEventDirective(eventName);
  }

  nullGroupCtrl = {
    register: angular.noop,
    remove: angular.noop,
    attend: angular.noop,
    unAttend: angular.noop,
    get: angular.noop,
    getConfig: angular.noop,
    setConfig: angular.noop
  };

  module.controller("qGroupCtrl", [
    '$attrs', function($attrs) {
      var config, processQueue, promiseCtrlList, unAttendList;
      promiseCtrlList = [];
      config = getAttributeConfig($attrs);
      unAttendList = [];
      processQueue = function(promiseCtrl) {
        var atd, ctrl, fn, k, len1, temp;
        temp = [];
        for (k = 0, len1 = unAttendList.length; k < len1; k++) {
          atd = unAttendList[k];
          ctrl = atd.ctrl;
          fn = atd.callback;
          if (!ctrl || ctrl === promiseCtrl) {
            promiseCtrl.attend(fn);
          } else {
            temp.push(atd);
          }
        }
        return unAttendList = temp;
      };
      this.register = function(qPromiseCtrl) {
        promiseCtrlList.push(qPromiseCtrl);
        return processQueue(qPromiseCtrl);
      };
      this.remove = function(ctrl) {
        var i, r;
        r = null;
        i = promiseCtrlList.indexOf(ctrl);
        if (i > -1) {
          r = promiseCtrlList.splice(i, 1);
        }
        return r;
      };
      this.attend = function(promiseCtrl, fn) {
        if (!fn) {
          fn = promiseCtrl;
          promiseCtrl = this.get();
        }
        if (promiseCtrl) {
          return promiseCtrl.attend(fn);
        } else {
          return unAttendList.push({
            ctrl: promiseCtrl,
            callback: fn
          });
        }
      };
      this.unAttend = function(promiseCtrl, fn) {
        if (!fn) {
          fn = promiseCtrl;
          promiseCtrl = this.get();
        }
        if (promiseCtrl) {
          return promiseCtrl.unAttend(fn);
        }
      };
      this.get = function() {
        if (promiseCtrlList.length) {
          return promiseCtrlList[promiseCtrlList.length - 1];
        } else {
          return null;
        }
      };
      this.getConfig = function() {
        return config;
      };
      this.setConfig = function(cf) {
        return config = cf;
      };
      return this;
    }
  ]).directive("qGroup", [
    function() {
      return {
        restrict: 'AC',
        require: "qGroup",
        controller: "qGroupCtrl",
        compile: function(tElement, tAttrs) {
          return function(scope, element, attrs, qGroupCtrl) {
            return scope.qGroupCtrl = qGroupCtrl;
          };
        }
      };
    }
  ]).directive("qInit", [
    function() {
      var config;
      config = {
        failed: {
          delay: -1
        },
        delay: 0
      };
      return {
        require: ["?qGroup", 'qInit'],
        controller: "qPromiseCtrl",
        link: function(scope, element, attrs, ctrls) {
          var excute, groupCtrl, promiseCtrl;
          groupCtrl = ctrls[0] || nullGroupCtrl;
          promiseCtrl = ctrls[1];
          promiseCtrl.setConfig(config);
          groupCtrl.register(promiseCtrl);
          excute = function() {
            var p, proxy;
            if (promiseCtrl.get()) {
              return;
            }
            p = scope.$eval(attrs.qInit);
            if (!angular.isPromise(p)) {
              groupCtrl.remove(promiseCtrl);
              return;
            }
            proxy = promiseCtrl.push(p);
            proxy.loading(function() {
              return element.addClass("q-init").addClass(Q_CLASS);
            }).success(function() {
              element.removeClass("q-init").removeClass(Q_CLASS);
              return groupCtrl.remove(promiseCtrl);
            })["finally"](promiseCtrl.pop);
          };
          excute();
          promiseCtrl.retry = excute;
        }
      };
    }
  ]).directive("qRetry", [
    function() {
      return {
        restrict: "A",
        require: "^qInit",
        priority: 5,
        link: function(scope, element, attrs, qInitCtrl) {
          element.on('click', function() {
            qInitCtrl.retry();
          });
        }
      };
    }
  ]).directive("qCloak", [
    function() {
      return {
        restrict: "C",
        require: "^qGroup",
        link: function(scope, element, attrs, groupCtrl) {
          return groupCtrl.attend(function(promiseProxy) {
            return promiseProxy.success(function() {
              return element.removeClass("q-cloak");
            });
          });
        }
      };
    }
  ]);


  /**
  qConfig = {
    delay:number
    failed:
      delay:number
    loading:
      delay:number
    success:
      delay:number  
  }
  number 负数时不自动关闭,loading此设置无效
   */

  module.constant("qConfig", {
    delay: 100
  }).service("PromiseProxy", [
    '$timeout', '$q', '$exceptionHandler', 'qConfig', function($timeout, $q, $exceptionHandler, qConfig) {
      var PromiseProxy, _promiseNum, completePromise, extendConfig, getPromiseNum, makePromise, processQueue;
      _promiseNum = 1;
      getPromiseNum = function() {
        return _promiseNum++;
      };
      extendConfig = function() {
        var args, config, extendDefault, k, len1, ref1, s;
        if (arguments.length < 1) {
          return qConfig;
        }
        if (arguments.length === 1 && angular.isArray(arguments[0])) {
          args = arguments[0];
        } else {
          args = Array.prototype.slice.call(arguments);
        }
        args.unshift(qConfig);
        config = extendOptions.apply(this, args);
        extendDefault = function(status) {
          if (!config[status]) {
            config[status] = {};
          }
          return config[status].delay = config[status].delay || config.delay;
        };
        ref1 = ['success', 'failed', 'loading'];
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          s = ref1[k];
          extendDefault(s);
        }
        return config;
      };
      processQueue = function($$state) {
        var e, error, fn, k, len1, list, status, value;
        value = $$state.value;
        status = $$state.status;
        list = $$state.isComplete ? $$state.complete[status] : $$state.pending[status];
        for (k = 0, len1 = list.length; k < len1; k++) {
          fn = list[k];
          try {
            value = fn(value);
          } catch (error) {
            e = error;
            $exceptionHandler(e);
          }
        }
        return ($$state.value = value);
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
      completePromise = function(deferred, resolved, useTime, delay) {
        if (useTime >= delay) {
          makePromise(deferred, resolved);
        } else {
          nextTick(function() {
            return makePromise(deferred, resolved);
          }, delay - useTime);
        }
      };
      PromiseProxy = (function() {
        function PromiseProxy(tp, config) {
          var self;
          this.deferred = $q.defer();
          this.promise = this.deferred.promise;
          this.config = config;
          this.$$state = {};
          this.$$state.status = 0;
          this.$$state.pending = [[], [], [], []];
          this.$$state.complete = [[], []];
          self = this;
          nextTick(function() {
            return self.run(tp);
          });
          return this;
        }

        PromiseProxy.prototype.run = function(promise) {
          var config, endTime, rs, self, startTime, timeline;
          self = this;
          config = this.config;
          startTime = endTime = new Date();
          timeline = 0;
          promise["finally"](function() {
            endTime = new Date();
            return timeline = endTime - startTime;
          }).then(function() {
            return completePromise(self.deferred, true, timeline, config.success.delay);
          }, function() {
            return completePromise(self.deferred, false, timeline, config.failed.delay);
          });
          this.$$state.status = 0;
          processQueue(this.$$state);
          rs = false;
          return this.promise["finally"](function() {
            self.$$state.status = 1;
            return processQueue(self.$$state);
          }).then(function() {
            self.$$state.status = 2;
            self.$$state.value = true;
            processQueue(self.$$state);
            return (rs = true);
          })["catch"](function() {
            self.$$state.status = 3;
            self.$$state.value = false;
            processQueue(self.$$state);
            return false;
          })["finally"](function() {
            var delay;
            delay = rs ? config.success.delay : config.failed.delay;
            if (delay > 0) {
              return nextTick(function() {
                self.$$state.isComplete = true;
                self.$$state.status = 0;
                self.$$state.value = rs;
                return processQueue(self.$$state);
              }, delay);
            } else {
              self.$$state.isComplete = true;
              self.$$state.status = 1;
              self.$$state.value = rs;
              return processQueue(self.$$state);
            }
          });
        };

        PromiseProxy.prototype.then = function(onLoading, onReady, onSuccess, onFailded) {
          var arg, fn, i, k, len1;
          for (i = k = 0, len1 = arguments.length; k < len1; i = ++k) {
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

        PromiseProxy.prototype["thenF"] = function(onFinish, onUnFinish) {
          var arg, fn, i, k, len1;
          for (i = k = 0, len1 = arguments.length; k < len1; i = ++k) {
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

        PromiseProxy.prototype.unfinish = function(fn) {
          return this.thenF(null, fn);
        };

        PromiseProxy.prototype["finally"] = function(fn) {
          return this.thenF(fn, fn);
        };

        return PromiseProxy;

      })();
      return {
        extendConfig: extendConfig,
        $new: function(tp, config) {
          return new PromiseProxy(tp, config);
        }
      };
    }
  ]);

  module.controller("qStatusCtrl", function() {
    this.cases = {};
    return this;
  });

  module.directive('qStatus', [
    function() {
      return {
        restrict: 'EA',
        controller: "qStatusCtrl",
        require: ["^qGroup", 'qStatus'],
        link: function(scope, element, attrs, ctrls) {
          var changeStatus, groupCtrl, onPromise, selectedElements, selectedScopes, statusCtrl;
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
            if ((selected = statusCtrl.cases[status] || statusCtrl.cases["Default"])) {
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
          onPromise = function(promiseProxy) {
            return promiseProxy.loading(function() {
              return changeStatus('Loading');
            }).ready().success(function() {
              return changeStatus('Success');
            }).failed(function() {
              return changeStatus('Failed');
            }).finish(function() {
              return changeStatus("Default");
            });
          };
          changeStatus("Default");
          groupCtrl.attend(onPromise);
          return scope.$on("$destroy", function() {
            return groupCtrl.unAttend(onPromise);
          });
        }
      };
    }
  ]);

  onStart = function(element, cls, rmCls) {
    if (cls) {
      element.addClass(cls);
    }
    if (rmCls) {
      element.removeClass(rmCls);
    }
  };

  onEnd = function(element, cls, rmCls) {
    if (cls) {
      element.removeClass(cls);
    }
    if (rmCls) {
      element.addClass(rmCls);
    }
  };

  createStatusDirectie = function(type) {
    var directiveName, lowerType;
    directiveName = "qStatus" + type;
    lowerType = type.toLowerCase();
    return module.directive(directiveName, [
      function() {
        return {
          restrict: 'AC',
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
      }
    ]);
  };

  ref1 = ['Success', 'Failed', 'Loading', 'Default'];
  for (k = 0, len1 = ref1.length; k < len1; k++) {
    t = ref1[k];
    createStatusDirectie(t);
  }

}).call(this);
