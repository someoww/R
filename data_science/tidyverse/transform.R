# Tibble - similar to data frames, but has some advantages

mtcars_t <- as_tibble(mtcars)
head(mtcars_t)


# Penguins data

library(palmerpenguins)
data(penguins)
glimpse(penguins)


# dplyr - a package for data manipulation with a consistent and flexible grammar - used for creating new variables, computing summaries, renaming variables, re-ordering observations, etc. The first argument is a data frame and output is always a data frame.



# Verbs for Rows 
# filter() keeps rows based on the values of the columns(variables)
# arrange() re-orders the rows(observations)
# distinct() which finds rows with unique values, but can also optionally modify the columns



# The function filter() allows to obtain a subset of observations based on given conditions

adelie_subset <- penguins |> filter(species == "Adelie")
summary(adelie_subset)

chinstrap_subset <- penguins |> filter(species == "Chinstrap", bill_length_mm > 52)
summary(chinstrap_subset$sex)

penguins_subset <- penguins |> filter(species == "Adelie" | species == "Gentoo")
summary(penguins_subset$island)

# There is a useful shortcut when we're combining | and ==; %in%
head(penguins |> filter(species %in% c("Chinstrap", "Gentoo")))



# The function arrange() re-orders the observations by one or more variables(column names); defaults to ascending order

penguins |> arrange(bill_length_mm)
penguins |> arrange(flipper_length_mm)
penguins |> arrange(desc(bill_length_mm))
penguins |> arrange(bill_length_mm, flipper_length_mm)



# We can find unique rows, remove duplicates in a dataset with unique()

penguins |> distinct()
penguins |> distinct(species, year)

penguins |> count(species, year, sort = T)



# Verbs for columns


# mutate() is used to create new variables to the existing data frame

penguins |> mutate(body_mass_kg = body_mass_g/1000)
penguins |> mutate(body_mass_kg = body_mass_g/1000, .before = 1)

# We can re-code with mutate()

penguins |> 
  mutate(
    flip_size = if_else(
      flipper_length_mm > 210, "large", "short"
    ), .before = 1
  )

# To re-code a variable in more than two categories, case_when() is used

penguins |>
  mutate(
    mass_c = case_when(
      body_mass_g > 4500 ~ "large",
      body_mass_g > 3000 & body_mass_g <= 4500 ~ "medium",
      body_mass_g <= 3000 ~ "small"
    ), .before = 1
  )



# In practice, only a subset of variables from the original dataset are used, the original data frame may contain many more variables.

names(penguins)
penguins |> select(year, island, species)

# A colon may be used to select a number of consecutive variables

penguins |> select(species:body_mass_g) 
penguins |> select(species:bill_depth_mm, -island) 

# select() can also be used to rename a variable and reordering the sequence of variables

penguins |> select(species, year, bill_len = bill_length_mm)

# select() has some helper functions: starts_with(), ends_with(), contains

names(penguins)
penguins |> select(starts_with("bill")) 


# If we want to keep all the existing variables and just want to rename a few, we can use rename() instead of select()

penguins |> rename(location = island)



# The real power of pipe arises when we start to combine multiple variables

penguins |> 
  filter(species == "Adelie" & sex == "female") |>
  arrange(desc(bill_length_mm))



# Verbs for groups: group_by() and summarise() being common ones
# group_by() divides datasets into groups meaningful for your analysis 

penguins |> group_by(species)

# summarise() collapses a data frame into a single row

penguins |> summarise(mean_mass = mean(body_mass_g, na.rm = T), sd_mass = sd(body_mass_g, na.rm = T))

# summarise() with group_by()

penguins |>
  group_by(species) |>
  summarise(
    mean_mass = mean(body_mass_g, na.rm = T),
    sd_mass = sd(body_mass_g, na.rm = T)
  )

# Or we could use .by argument

penguins |>
  summarise(
    mean_mass = mean(body_mass_g, na.rm = T),
    sd_mass = sd(body_mass_g, na.rm = T),
    .by = species
  )


# slice() selects rows by row number

penguins |> slice(1:5)
penguins |> slice(c(1,4))
penguins |> 
  slice_max(order_by = bill_length_mm, n = 10)
penguins |> 
  slice_min(order_by = body_mass_g, n = 3)

# random sampling of rows

penguins |> slice_sample(n=5) # sample 5 penguins
penguins |> slice_sample(prop=0.1) # sample 10% of data
penguins |> slice_sample(n=5, replace = T)



# Find frequency distributions

# count() provides frequency distribution of a variable

penguins |> count(species)
penguins |> count(sex)
penguins |> count(species, name = "freq")

# proportions with count()

# relative frequency distribution of species
penguins |> count(species) |> mutate(prop = n / sum(n))

# distribution of penguins flipper size
penguins |>
  mutate(flip_s = if_else(
    flipper_length_mm > 210, "large", "short")) |>
  count(flip_s)

# distribution of penguins body mass
penguins |>
  mutate(mass_c = case_when(
    body_mass_g > 4500 ~ "large",
    body_mass_g > 3000 & body_mass_g <= 4500 ~ "medium",
    body_mass_g <= 3000 ~ "small")
  ) |>
  count(mass_c)


# joint distributions with count()

penguins |> count(year, species)

# frequency and overall proportions

penguins |> count(species, year) |> mutate(prop = n/sum(n))

# frequency and (species) marginal proportions

penguins |>
  count(species, year)  |>
  mutate(prop = n / sum(n),
         .by= species)

# frequency and (year) marginal proportions

penguins |>
  count(species, year)  |>
  mutate(prop = n / sum(n),
         .by = year)

