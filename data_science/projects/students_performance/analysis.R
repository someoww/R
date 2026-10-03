library(tidyverse)
library(broom)

# import and inspection

raw <- read_csv("student_performance.csv", na=c("", "NA", "N/A", "-"))
glimpse(raw)

raw |> summarise(across(everything(), \(x) sum(is.na(x))))
sum(duplicated(raw))

raw |> count(gender)
raw |> count(department)
raw |> count(part_time_job)


# data cleaning

clean <- raw |>
  distinct() |>
  mutate(
    gender = case_when(
      str_to_lower(str_trim(gender)) %in% c("f", "female") ~ "Female",
      str_to_lower(str_trim(gender)) %in% c("m", "male")   ~ "Male"),
    department = str_to_title(str_squish(department)),
    part_time_job = case_when(
      str_to_lower(str_trim(part_time_job)) %in% c("y", "yes") ~ "Yes",
      str_to_lower(str_trim(part_time_job)) %in% c("n", "no")  ~ "No"),
    attendance_pct   = parse_number(as.character(attendance_pct)),
    study_hours_week = if_else(study_hours_week > 80, NA, study_hours_week),
    attendance_pct   = if_else(attendance_pct > 100, NA, attendance_pct),
    sleep_hours      = if_else(sleep_hours < 3 | sleep_hours > 12, NA, sleep_hours),
    final_score      = if_else(final_score < 0 | final_score > 100, NA, final_score)
  ) |>
  filter(!is.na(final_score))


names(clean)
nrow(clean)
count(clean, gender)
count(clean, department)
summary(clean)



# Feature engineering

clean <- clean |>
  mutate(
    passed      = if_else(final_score >= 50, 1, 0),
    grade       = case_when(final_score >= 70 ~ "A",
                            final_score >= 60 ~ "B",
                            final_score >= 50 ~ "C",
                            TRUE              ~ "F"),
    improvement = final_score - midterm_score,
    study_level = case_when(study_hours_week < 10 ~ "Low",
                            study_hours_week < 18 ~ "Medium",
                            study_hours_week >= 18 ~ "High"),
    sleep_group = if_else(sleep_hours < 6, "Short", "Enough"),
    attend_c    = attendance_pct - mean(attendance_pct, na.rm = TRUE),
    study_level = factor(study_level, levels = c("Low", "Medium", "High")),
    grade       = factor(grade, levels = c("F", "C", "B", "A")),
    across(c(gender, department, part_time_job, sleep_group), as.factor)
  )


# Visualization

p1 <- ggplot(clean, aes(final_score)) +
  geom_histogram(binwidth = 5, fill = "steelblue", colour = "white") +
  labs(title = "Final scores are roughly bell-shaped",
       x = "Final score", y = "Students")

p2 <- ggplot(clean, aes(department, final_score)) +
  geom_boxplot(fill = "grey90") +
  labs(title = "Final score by department", x = NULL, y = "Final score")

p3 <- ggplot(clean, aes(study_hours_week, final_score)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm") +
  labs(title = "More study hours, higher scores",
       x = "Study hours per week", y = "Final score")

p4 <- clean |>
  drop_na(study_level) |>
  summarise(pass_rate = mean(passed), .by = study_level) |>
  ggplot(aes(study_level, pass_rate)) +
  geom_col(fill = "darkgreen") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Pass rate by study level", x = "Study level", y = "Pass rate")

p1; p2; p3; p4        # shows the plots


# Generate the clean CSV

write_csv(clean, "stdnt_perf_clean.csv")



# Fitting models


# simple linear regression

m1 <- lm(final_score ~ study_hours_week, data = clean)
tidy(m1, conf.int = TRUE)
glance(m1)


# multiple linear regression

m2 <- lm(final_score ~ study_hours_week + attendance_pct + prior_gpa +
           sleep_hours + part_time_job + department, data = clean)
tidy(m2, conf.int = TRUE)
glance(m2)


# diagnostics: is the model behaving?

aug <- augment(m2)
ggplot(aug, aes(.fitted, .resid)) +
  geom_point(alpha = 0.4) +
  geom_hline(yintercept = 0, colour = "red")

plot(m2, which = 2)


# train/test: honest accuracy

set.seed(230)
model_data <- clean |>
  drop_na(study_hours_week, attendance_pct, prior_gpa,
          sleep_hours, part_time_job, department)

train <- slice_sample(model_data, prop = 0.8)
test  <- anti_join(model_data, train, by = "student_id")

a <- lm(final_score ~ study_hours_week, data = train)
b <- lm(final_score ~ study_hours_week + attendance_pct + prior_gpa +
          sleep_hours + part_time_job + department, data = train)

rmse <- function(model, data) {
  sqrt(mean((data$final_score - predict(model, data))^2))
}
rmse(a, test); rmse(b, test)


# logistic regression: pass/fail

lg <- glm(passed ~ study_hours_week + attendance_pct + prior_gpa +
            sleep_hours + part_time_job,
          data = train, family = binomial)

tidy(lg, exponentiate = TRUE, conf.int = TRUE) |>
  filter(term != "(Intercept)")

test <- test |>
  mutate(p_hat = predict(lg, test, type = "response"),
         pred  = if_else(p_hat >= 0.5, 1, 0))

count(test, passed, pred)
mean(test$pred == test$passed)