library(tidyverse)

data1 <- read_csv("data/prawnGR.CSV")
summary(data1)

# Importing spreadsheets

library(readxl)
data2 <- read_excel("data/whaledata.xls")
summary(data2)


# Importing text files

data3 <- read.table("data/atmosphere.txt", header = TRUE)
data3
summary(data3)
table(data3$treatment)

# Importing SPSS, Stata, and SAS files require haven package
# Importing SPSS files

library(haven)
data4 <- read_sav("data/hw_dat.sav")
data4
summary(data4)


# Importing Stata files

data5 <- haven::read_dta("data/hw_dat.dta")
head(data5)
summary(data5)


# Importing SAS files

data6 <- haven::read_sas("data/airline.sas7bdat")
head(data6)
summary(data6)


# Importing R's native format(clicking on the file works well)

summary(TemoraBR)



# Data entry in R

meow = tibble(
  x = c(1, 2, 5),
  y = c("h", "m", "g"),
  z = c(0.08, 0.83, 0.60)
)
summary(meow)


# Loading built-in datasets

data("world_bank_pop")
summary(world_bank_pop)


# Importing datasets from Packages

library(gapminder)
data("gapminder")
head(gapminder)
summary(gapminder)



# Exporting data


# Exporting to R objects(.RData)

save(mtcars, TemoraBR, file = "data/two_data_sets.RData")

# Exporting to CSV

write_excel_csv(mtcars, "data/mtcars4.csv")



# Exporting to text files

# Export as space-separated text
write.table(mtcars, "data/mtcars.txt")

# Export as tab-separated text
write.table(mtcars, "data/mtcars_tab.txt", sep = "\t")

# Export as CSV using write.table
write.table(mtcars, "data/mtcars_custom.csv",
            sep = ",", row.names = FALSE)
