gulp = require('gulp')
compass = require("gulp-compass")
clean = require("gulp-clean")
plumber = require("gulp-plumber")
connect = require("gulp-connect")
gutil = require("gulp-util")
coffee = require("gulp-coffee")
coffeelint = require('gulp-coffeelint');
concat = require("gulp-concat")

paths = {
  coffee:"src/**/*.coffee"
  compass:"src/style/**/*.scss"
  tmp:".tmp"
}
gulp.task("compass",(done)->
  gulp.src(paths.compass)
  .pipe(plumber())
  .pipe(compass({sass:"src",css:paths.tmp}))
  .on('error',gutil.log)
  .pipe(connect.reload())
)

gulp.task("coffee",(done)->
 # .pipe(coffeelint())
 # .pipe(coffeelint.reporter())
  gulp.src(paths.coffee)
  .pipe(plumber())
  .pipe(coffee({bare:true}))
  .on('error',gutil.log)
  .pipe(gulp.dest(paths.tmp))
  .pipe(connect.reload())
)

gulp.task("clean",()->
  gulp.src(paths.tmp,{read:false}).pipe(clean())
)
gulp.task("watch",['build'],()->
  gulp.watch(paths.compass,['compass'])
  gulp.watch(paths.coffee,['coffee'])
  gulp.watch('demo/**/*',['reload'])
)
gulp.task("reload",()->
  gulp.src("demo/**/*").pipe(connect.reload())
)

gulp.task('connect',(done)->
  connect.server({
    root:[paths.tmp,'demo','bower_components','template']
    livereload:true
    port:3000
  })
)

gulp.task("build",['compass','coffee'])
gulp.task("s",['build','watch','connect'])



gulp.task("release",()->
  files = [
    'src/core/util.coffee'
    'src/core/proxy.coffee'
    'src/core/options.coffee'

    'src/core/group.coffee'
    'src/core/control.coffee'
    'src/core/event.coffee'
    'src/core/init.coffee'
    'src/core/status.coffee'

    'src/core/cloak.coffee'
    'src/core/public.coffee'
  ]
  gulp.src(files)
  .pipe(plumber())
  .pipe(concat("angular-loading.coffee"))
  .pipe(coffee())
  .on('error',gutil.log)
  .pipe(gulp.dest("release/"))
)