library(revdepcheck)

# Set configure.args for sf install, set to only use source installs
# opt <- options(
#         install.packages.check.source = "no",
#         install.packages.compile.from.source = "always",
#         pkgType = "source",
#         repos = r)

revdep_reset()
revdep_check(quiet = FALSE, num_workers = 4)

# options(opt)
