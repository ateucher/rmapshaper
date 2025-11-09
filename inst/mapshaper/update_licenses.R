# Script to update node_packages.csv and LICENSE files for bundled mapshaper dependencies
# This fetches license information and LICENSE files from npm/GitHub
# Only processes modules explicitly bundled with browserify -r flags

library(jsonlite)
library(httr2)
library(dplyr)
library(readr)
library(purrr)

# Configuration
output_csv <- "inst/mapshaper/node_packages.csv"
license_dir <- "inst/mapshaper"

# Explicitly bundled modules (from browserify -r flags)
# Excludes Node.js core modules (buffer, fs, path)
bundled_modules <- c(
  "sync-request",
  "mproj",
  "iconv-lite",
  "flatbush",
  "rw",
  "kdbush",
  "@tmcw/togeojson",
  "@placemarkio/tokml",
  "idb-keyval"
)

cat(sprintf("Processing %d bundled modules\n", length(bundled_modules)))

# Function to get package info from npm registry
get_npm_info <- function(package_name) {
  cat(sprintf("  Fetching info for %s...\n", package_name))

  # Handle scoped packages (@org/package)
  encoded_name <- URLencode(package_name, reserved = TRUE)

  tryCatch(
    {
      resp <- request(sprintf("https://registry.npmjs.org/%s", encoded_name)) |>
        req_timeout(30) |>
        req_perform()

      info <- resp_body_json(resp)

      list(
        name = package_name,
        version = info$`dist-tags`$latest %||% "unknown",
        license = info$license %||% "unknown",
        repository = info$repository$url %||% NA_character_,
        homepage = info$homepage %||% NA_character_
      )
    },
    error = function(e) {
      cat(sprintf(
        "    WARNING: Failed to fetch npm info for %s: %s\n",
        package_name,
        e$message
      ))
      list(
        name = package_name,
        version = "unknown",
        license = "unknown",
        repository = NA_character_,
        homepage = NA_character_
      )
    }
  )
}

# Function to clean GitHub URL
clean_github_url <- function(url) {
  if (is.na(url)) {
    return(NA_character_)
  }

  # Remove git+, .git suffix, git://, ssh://, etc.
  url <- sub("^git\\+", "", url)
  url <- sub("^git://", "https://", url)
  url <- sub("^ssh://git@", "https://", url)
  url <- sub("git@github\\.com:", "https://github.com/", url)
  url <- sub("\\.git$", "", url)

  # Extract github.com URLs
  if (grepl("github\\.com", url)) {
    # Extract owner/repo
    match <- regmatches(url, regexec("github\\.com[:/]([^/]+/[^/]+)", url))[[1]]
    if (length(match) >= 2) {
      return(sprintf("https://github.com/%s", match[2]))
    }
  }

  url
}

# Function to extract owner/repo from GitHub URL
extract_github_repo <- function(url) {
  if (is.na(url) || !grepl("github\\.com", url)) {
    return(NULL)
  }

  match <- regmatches(url, regexec("github\\.com[:/]([^/]+)/([^/]+)", url))[[1]]
  if (length(match) >= 3) {
    list(owner = match[2], repo = match[3])
  } else {
    NULL
  }
}

# Function to fetch LICENSE from GitHub
fetch_github_license <- function(owner, repo, package_name) {
  cat(sprintf("    Fetching LICENSE from GitHub: %s/%s\n", owner, repo))

  # Try common license file names
  license_files <- c(
    "LICENSE",
    "LICENSE.md",
    "LICENSE.txt",
    "LICENCE",
    "LICENCE.md",
    "LICENCE.txt",
    "LICENSE-MIT",
    "LICENSE.MIT"
  )

  for (filename in license_files) {
    tryCatch(
      {
        url <- sprintf(
          "https://raw.githubusercontent.com/%s/%s/main/%s",
          owner,
          repo,
          filename
        )

        resp <- request(url) |>
          req_timeout(30) |>
          req_perform()

        if (resp_status(resp) == 200) {
          return(resp_body_string(resp))
        }
      },
      error = function(e) {
        # Try master branch
        tryCatch(
          {
            url <- sprintf(
              "https://raw.githubusercontent.com/%s/%s/master/%s",
              owner,
              repo,
              filename
            )

            resp <- request(url) |>
              req_timeout(30) |>
              req_perform()

            if (resp_status(resp) == 200) {
              return(resp_body_string(resp))
            }
          },
          error = function(e2) {
            # Silent fail, will try next filename
          }
        )
      }
    )
  }

  cat(sprintf("    WARNING: Could not fetch LICENSE for %s/%s\n", owner, repo))
  NULL
}

# Function to write LICENSE file
write_license_file <- function(content, package_name, license_dir) {
  # Clean package name for filename (remove @org/ prefix)
  clean_name <- sub("^@[^/]+/", "", package_name)
  filename <- file.path(license_dir, sprintf("LICENSE-%s", clean_name))

  writeLines(content, filename)
  cat(sprintf("    Wrote %s\n", filename))
}

# Collect all package information
cat("\nFetching package information from npm...\n")
pkg_info_list <- map(bundled_modules, get_npm_info)

# Process each package
cat("\nProcessing licenses...\n")
for (info in pkg_info_list) {
  cat(sprintf("\n%s (%s):\n", info$name, info$license))

  # Clean repository URL
  repo_url <- clean_github_url(info$repository)
  if (is.na(repo_url)) {
    repo_url <- clean_github_url(info$homepage)
  }

  info$repository <- repo_url

  # Try to fetch LICENSE from GitHub
  if (!is.na(repo_url)) {
    gh_repo <- extract_github_repo(repo_url)
    if (!is.null(gh_repo)) {
      license_content <- fetch_github_license(
        gh_repo$owner,
        gh_repo$repo,
        info$name
      )

      if (!is.null(license_content)) {
        write_license_file(license_content, info$name, license_dir)
      }
    }
  } else {
    cat(sprintf("    WARNING: No GitHub URL found for %s\n", info$name))
  }
}

# Create data frame and write CSV
cat("\nCreating node_packages.csv...\n")
pkg_df <- map_dfr(
  pkg_info_list,
  ~ {
    # Clean repository URL to standard https://github.com format
    repo <- clean_github_url(.x$repository)

    tibble(
      `module name` = sprintf("%s@%s", .x$name, .x$version),
      license = .x$license,
      repository = repo %||% ""
    )
  }
) |>
  arrange(`module name`)

write_csv(pkg_df, output_csv)
cat(sprintf("Wrote %s with %d packages\n", output_csv, nrow(pkg_df)))

# Summary
cat("\n=== Summary ===\n")
cat(sprintf("Total packages: %d\n", nrow(pkg_df)))
cat(sprintf(
  "Packages with GitHub repos: %d\n",
  sum(!is.na(pkg_df$repository) & pkg_df$repository != "")
))

license_files <- list.files(
  license_dir,
  pattern = "^LICENSE-",
  full.names = FALSE
)
cat(sprintf("LICENSE files created: %d\n", length(license_files)))

cat("\nDone!\n")
