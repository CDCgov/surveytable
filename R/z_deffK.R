# From:
# Richard Valliant and George Zipf (2023). PracTools: Designing and
# Weighting Survey Samples. R package version 1.4.2.
# https://CRAN.R-project.org/package=PracTools

# Kish design effect
# Kish design effect due to unequal weights
# w: vector of inverses of selection probabilities for a sample

# deffK = function (w)
deffK = function(prob)
{
  w = 1 / prob
  assert_that(all(w > 0), all(w < Inf))

  # if (any(w <= 0))
  #   warning("Some weights are less than or equal to 0.\n")
  # n <- length(w)
  # ret = 1 + sum((w - mean(w))^2)/n/mean(w)^2
  ret = 1 + mean((w - mean(w))^2)/mean(w)^2
  # assert_that(all(ret > 0))
  assert_that(all(ret >= 1)) # Second term >= 0
  ret
}
