library(revdepcheck)

# redis package requires Rmpi, which requires openMPI installed.
# install with `brew install open-mpi`
# Also make sure gfortran is installed: https://mac.r-project.org/tools/

# Set configure.args for sf install, set to only use source installs
# opt <- options(
#         install.packages.check.source = "no",
#         install.packages.compile.from.source = "always",
#         pkgType = "source")
options("install.packages.compile.from.source" = "always")

revdep_reset()
revdep_check(quiet = FALSE, num_workers = 4)

# options(opt)
