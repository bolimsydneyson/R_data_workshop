
# 1.Data Manipulation ============================


# Learning Objectives ----------------------------
  #  Understand how to inspect your data
  #  Use functions (`filter`, `mutate`, `group_by`, `count`, `summarize`) in `dplyr` packages for data manipulation
  #  Use functions (`spread`, `gather`) in `tidyr` package for data manipulation.
  #  Use the pipe operator `%>%`
  #  Understand the split-apply-combine structure




## Set up -----------------------------------------
# Instsall packages (if they are not installed)
#install.packages("readr")
#install.packages("dplyr")
#install.packages("ggplot2")

# Load libraries (load the libraries once they are installed)
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)
library(lubridate)
library(tidyr)



## 1.1 Inspect your Data -------------------------
# 0. Download the data ---------------------------
download.file(url="https://raw.githubusercontent.com/bolimsydneyson/R_data_workshop/master/combined.csv",
              destfile = "data/raw.csv")

# You can specify the URL for downloading
# destfile is where the destination of the downloaded file will be at
# Type in the destination
# To get the destination, type 'getwd()' on your console - that is your working directory
# If you want to specify within the working directory, use 'setwd()'
# For example, when I type in getwd(), I get "C:/Users/bolim/OneDrive/Documents"
# I want to specify the working directory to "CIF" folder.
# I would type 'setwd("~/CIF")' on my console


# 0. Read in the data --------------------------
surveys <- read_csv("data/raw.csv")

# 1. See the data ------------------------------
# head(), tail(), View()
head(surveys)
tail(surveys)
View(surveys)

# 2. Check structure --------------------------
dim(surveys)
nrow(surveys)
ncol(surveys)
colnames(surveys)

# 3. Summary statistics ----------------------
str(surveys)
summary(surveys)

# 4. Indexing --------------------------------
# Surveys is a `dataframe` object. Dataframe has rows and columns. It looks like a table.
# Slicing a part of dataframe object is called indexing.
  # You can index by number, or by name of the row/column.
  # Indexing starts from 1. (NOT 0)
  # dataframe[row, column]
surveys[1, 1] # first row, first column
surveys[1:3, 2] # 1~3rd rows, 2nd column
surveys[, 2:3] # all rows, 2~3rd columns

  # QUIZ: what will equal to head(surveys)? head() returns first six rows and all columns


# You can specify the column name
surveys["species_id"] # sliced dataframe
surveys[,"species_id"] # vector
surveys[["species_id"]] # vetor
surveys$species_id # vector






## 1.2 `dplyr`, `stringr`--------------------------
# Learning Objectives ----------------------------
  #  Use the pipe operator `%>%`  
  #  Use functions (`select`, `filter`, `mutate`, `group_by`, `count`, `summarize`) in `dplyr` packages for data cleaning
  #  Use functions (`spread`, `gather`) in `tidyr` package for data manipulation.
  #  Understand the split-apply-combine structure


# 1. `dplyr`-------------------------------------
  # select() ------------------------------------
  # select(dataframe, column_name)
select(surveys, plot_id, species_id, weight)
select(surveys, -record_id, -species_id)

  # Pipe structure `%>%`
  # dataframe %>% select(column_name)
surveys %>% select(plot_id, species_id, weight)
surveys %>% select(-record_id, -species_id)

surveys %>% select(-record_id, -species_id) %>% head()


  # filter() ------------------------------------
  # filter(dataframe, condition, .preserve = FALSE)
  # filters based on the condition
data_female <- filter(surveys, sex == "F")
print(data_female)

data_21c <- filter(surveys, year >= 2000)
print(data_21c)

  # Pipe structure `%>%`
  # dataframe %>% filter(condition)
data_female2 <- surveys %>% filter(sex == "F")
print(data_female2)


  # mutate() -----------------------------------
  # Create a new column based on new conditions
  # mutate(dataframe, ...)
surveys_new <- mutate(surveys, weight_kg = weight / 1000)
View(surveys_new)

surveys_new <- mutate(surveys, weight_lb = weight_kg * 2.2)
View(surveys_new)

surveys_new <- mutate(surveys_new, weight_lb = round(weight_lb, digits = 2))
View(surveys_new)

  # Pipe structure `%>%`
  # dataframe %>% mutate(condition)
surveys_new2 <- surveys %>% mutate(weight_kg = weight * 0.454)
View(surveys_new2)

surveys_new2 <- surveys %>% 
  mutate(weight_kg = weight * 0.454) %>% 
  mutate(weight_kg = round(weight_kg, digits = 2))
View(surveys_new2)

surveys_new2 <- surveys %>% 
  mutate(weight_kg = round(weight * 0.454, digits = 2))
View(surveys_new2)

rm(surveys_new)

  # group_by() and summarise() ----------------------
  # split-apply-combine structure
surveys %>% group_by(sex) %>% summarise(mean(weight, na.rm = TRUE))
surveys %>% group_by(species) %>% summarise(n())

surveys %>% group_by(sex) %>% summarise(avg_weight = mean(weight, na.rm = TRUE))
surveys %>% group_by(species) %>% summarise(count = n())

surveys %>% count(sex)
surveys %>% count(species)

  # summarise with mean(), median(), n()


  # use them together ------------------------------
dplyr_df <- surveys %>% 
  filter(!is.na(sex)) %>%
  group_by(genus) %>%
  summarise(avg_weight = round(mean(weight, na.rm = TRUE), digits = 2)) %>%
  mutate(avg_weight_kg = round(avg_weight * 0.454, digits = 2))

View(dplyr_df)



# 2. `stringr` & `lubridate` --------------------------------------------
  # use str_c to concatenate strings
  # strings are characters
  # to concatenate them, you use str_c() function

  # stringr::str_c() -----------------------------------------------
str_c("A", "B", "C", sep = "_")
str_c("1993", "05", "16", sep = "-")

  # str_c columns?
surveys %>% str_c(year, month, day, sep = "-")
# THIS SHOULD GIVE YOU AN ERROR

date <- str_c(surveys$year, surveys$month, surveys$day, sep = "-")
View(date)

  # lubridate::ymd() -------------------------------------------------
  # changes to year, month, day components
typeof(date)

date2 <- ymd(date)
summary(date2)

  # mix with dplyr mutate function ----------------------------------
surveys$date <- str_c(surveys$year, surveys$month, surveys$day, sep = "-")
View(surveys)

surveys <- surveys %>%
  mutate(date = ymd(date))

summary(surveys["date"])



# 3. filter out NA-------------------------------
  #is.na(), !is.na(), na.omit()
  surveys_clean <- na.omit(surveys)





## 1.3 `tidyr`, `readr`---------------------------
# 4. `tidyr` -----------------------------------------------
  # spread() : wide data format ----------------------------
surveys_gw <- surveys_clean %>%
  group_by(genus, plot_id) %>%
  summarise(mean_weight = mean(weight))

View(surveys_gw)

  # spread function
  # key & value
surveys_spread <- surveys_gw %>%
  spread(key = genus, value = mean_weight)

View(surveys_spread)

  # fill the empty NA with 0
surveys_spread2 <- surveys_gw %>% spread(genus, mean_weight, fill = 0) %>% head()
View(surveys_spread2)

  # gather() : long data format ------------------------------
surveys_gather <- surveys_spread %>%
  gather(key = genus, value = mean_weight, -plot_id)

# -plot_id means to ignore plot_id

View(surveys_gather)


# 5. Data export --------------------------------------------
  # filter out na values in weight, hindfoot_length, and sex 
surveys_complete <- surveys %>%
  filter(!is.na(weight), !is.na(hindfoot_length), !is.na(sex))

  # extract most common species_id
species_counts <- surveys_complete %>%
  count(species_id) %>%
  filter(n >= 50)

  # only keep the most common species
surveys_complete <- surveys_complete %>%
  filter(species_id %in% species_counts$species_id)

  # export csv with write_csv()
write_csv(surveys_complete, path = "data/surveys_complete.csv")










# 2. Data Visualization ==============================

# Learning Objectives ----------------------------
  # Produce scatter plots, box plots, histograms
  # Put labels on plots
  # Group with color
  # Use facets, coord_flip, themes, grid arrangements
  # Export the visualization


# 0. Read in the data ---------------------------
surveys_complete <- readr::read_csv("data/surveys_complete.csv")


# 1. ggplot2 package ----------------------------
# ggplot(data = <DATA>, mapping = aes(<MAPPINGS>)) + <GEOM_FUNCTION>()

# Example
ggplot(data = surveys_complete, mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point()


  # geom_point() ----------------------------------
ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point()

# Assign plot to a variable
surveys_plot <- ggplot(data = surveys_complete, 
                       mapping = aes(x = weight, y = hindfoot_length))

# Draw the plot
surveys_plot + 
  geom_point()


  # add alpha
ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point(alpha = 0.1)


  # add color
ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point(alpha = 0.1, color = "green")

  # add color and express categorical variables
ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point(alpha = 0.1, aes(color = species_id))

  # add jitter
ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point(alpha = 0.1, aes(color = species_id))+
  geom_jitter()


  # geom_boxplot() --------------------------------
ggplot(data = surveys_complete, 
       mapping = aes(x = species_id, y = weight)) +
  geom_boxplot()


ggplot(data = surveys_complete, 
       mapping = aes(x = species_id, y = weight)) +
  geom_boxplot(alpha = 0) +
  geom_jitter(alpha = 0.3, color = "red")



  # geom_line() -----------------------------------
  # time series data
yearly_counts <- surveys_complete %>%
  count(year, genus)

ggplot(data = yearly_counts, 
       mapping = aes(x = year, y = n)) +
  geom_line()


surveys_complete %>%
  count(year, genus) %>%
  ggplot(data = .,
         mapping = aes(x = year, y = n)) +
  geom_line()


  # add group
ggplot(data = yearly_counts, 
       mapping = aes(x = year, y = n, group = genus)) +
  geom_line()


  # add color
ggplot(data = yearly_counts, 
       mapping = aes(x = year, y = n, color = genus)) +
  geom_line()


  # geom_histogram() -----------------------------
  # used for counts of the particular x value; distribution
surveys_complete %>%
  select(year) %>%
  ggplot(data = ., aes(x = year)) + 
  geom_histogram()


surveys_complete %>%
  select(year) %>%
  mutate(year = factor(year)) %>%
  ggplot(data = ., aes(x = year)) + 
  stat_count()




  # geom_violin() ------------------------------
ggplot(data = yearly_counts, 
       mapping = aes(x = genus, y = n)) +
  geom_violin()





# Note:R cheatsheet available on the Github web




















# 2. Faceting ---------------------------------------
  # facet_wrap(), facet_grid()


  # facet_wrap() --------------------------------------
ggplot(data = yearly_counts, 
       mapping = aes(x = year, y = n)) +
  geom_line() +
  facet_wrap(~genus)


  # facet_wrap and colors
yearly_sex_counts <- surveys_complete %>%
  count(year, genus, sex)

ggplot(data = yearly_sex_counts, 
       mapping = aes(x = year, y = n, color = sex)) +
  geom_line() +
  facet_wrap(~genus)

  # facet_grid() ---------------------------------------
ggplot(data = yearly_sex_counts, 
       mapping = aes(x = year, y = n, color = sex)) +
  geom_line() +
  facet_grid(sex ~ genus)


  # One column, facet by rows
ggplot(data = yearly_sex_counts, 
       mapping = aes(x = year, y = n, color = sex)) +
  geom_line() +
  facet_grid(genus ~ .)

  # One row, facet by column
ggplot(data = yearly_sex_counts, 
       mapping = aes(x = year, y = n, color = sex)) +
  geom_line() +
  facet_grid(. ~ genus)


# 3. Add elements -------------------------------------
ggplot(data = yearly_sex_counts, 
       mapping = aes(x = year, y = n, color = sex)) +
  geom_line() +
  facet_wrap(~ genus) +
  labs(title = "Observed genera through time",
       x = "Year of observation",
       y = "Number of individuals")


# 4. Save it with ggsave() ---------------------------
obj <- ggplot(data = yearly_sex_counts, 
       mapping = aes(x = year, y = n, color = sex)) +
  geom_line() +
  facet_wrap(~ genus) +
  labs(title = "Observed genera through time",
       x = "Year of observation",
       y = "Number of individuals")

ggsave("observed_genera_through_time.png", obj)
