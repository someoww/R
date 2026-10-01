# Generating Random Data

age = c(13,12,13,16,10,11,12,14,14,17,12)

sample(age, 3, replace = F)
sample(x = 0:100, size = 10, replace = F)
sample(x = letters[1:6], size = 15, replace = TRUE)

# Tossing a biased coin 10 times

smpl1 <- sample(x=c("H", "T"), size = 10000, replace = T, prob = c(0.75, 0.25))
table(smpl1)
summary(smpl1)

# We can set initial seed to ensure reproducibility.


rbinom(8, 10, 0.75)
summary(rnorm(5000, 10, 4))

pnorm(55, 50, 3) - pnorm(45, 50, 3)
dnorm(5, 10, 0.75)
qnorm(0.975, 0, 1)
