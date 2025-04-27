library(testthat)
library(ggsegmentedtotalbar)

test_that("ggsegmentedtotalbar produces a plot", {
  df <- data.frame(
    group = c("A", "A","A","B", "B","B"),
    segment = c("X", "Y", "Z", "X", "Y", "Z"),
    value = c(10, 20, 30, 40, 50, 60),
    total = c(60, 60, 60, 150, 150, 150)
  )
  p <- ggsegmentedtotalbar(df, "group", "segment", "value", "total")
  expect_s3_class(p, "gg")
})
