library(revdepcheck)

# Use patched Rcpp for macOS (https://github.com/RcppCore/Rcpp/issues/1060)
r <- getOption("repos")
r["Rcppdrat"] <- "https://RcppCore.github.io/drat"

# Set configure.args for sf install, set to only use source installs
opt <- options(configure.args = c("sf" = '--with-proj-lib=/usr/local/lib/'),
        install.packages.check.source = "no",
        install.packages.compile.from.source = "always",
        pkgType = "source",
        repos = r)

revdep_reset()
revdep_check(quiet = FALSE, num_workers = 4)

options(opt)
