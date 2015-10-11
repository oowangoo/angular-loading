gulp = require('gulp')
compass = require("gulp-compass")
clean = require("gulp-clean")
plumber = require("gulp-plumber")
connect = require("gulp-connect")
gutil = require("gulp-util")
coffee = require("gulp-coffee")
concat = require("gulp-concat")

paths = {
  coffee:"src/**/*.coffee"
  compass:"src/style/**/*.scss"
  tmp:".tmp"
}
gulp.task("compass",['cleanBuild'],(done)->
  gulp.src(paths.compass)
  .pipe(plumber())
  .pipe(compass({sass:"src",css:paths.tmp}))
  .on('error',gutil.log)
  .pipe(connect.reload())
)

gulp.task("concat",()->
  gulp.src(paths.coffee)
  .pipe(concat("all.coffee"))
  .pipe(gulp.dest(paths.tmp))
)

gulp.task("coffeeConcat",['concat'],()->
  gulp.src(paths.tmp+"/all.coffee")
  .pipe(coffee())
  .on('error',gutil.log)
  .pipe(gulp.dest(paths.tmp))
  .pipe(connect.reload())
)

gulp.task("coffee",['cleanBuild'],(done)->
  gulp.src(paths.coffee)
  .pipe(plumber())
  .pipe(coffee({bare:true}))
  .on('error',gutil.log)
  .pipe(gulp.dest(paths.tmp))
  .pipe(connect.reload())
)

gulp.task("cleanBuild",()->
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

gulp.task("build",['cleanBuild','compass','coffee'])
gulp.task("s",['build','watch','connect'])