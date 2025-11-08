test_that("loading with old v8 engine gives a message", {
  local_mocked_bindings(v8_version = function() package_version("8.0"))
  expect_message(
    startup_v8_version_check(),
    "Warning: v8 Engine is version 8.0"
  )
})
