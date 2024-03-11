# Libraries
library(tidyverse)
library(dplyr)

# Load data
df <- read.csv("data/HollywoodsMostProfitableStories.csv")
head(df)

# Check data types
names(df)
dim(df)
str(df)

# Summarize the data frame into just one vector
summary(df)

# Check values 
table(df$Genre)
table(df$Lead.Studio)
table(df$Audience..score..)
table(df$Profitability)
table(df$Rotten.Tomatoes..)
table(df$Worldwide.Gross)
table(df$Year)

# Check for missing values
colSums(is.na(df))
which(!complete.cases(df))
df[!complete.cases(df), ]

# Drop missing values using dplyr library
df_cleaned <- na.omit(df)

# Check number of missing values on both datasets
nas_df = sum(is.na(df))
print(paste("Number of missing values on df: ", nas_df))

nas_df_cleaned = sum(is.na(df_cleaned))
print(paste("Number of missing values on df_cleaned: ", nas_df_cleaned))

# Summarize the cleaned data frame into just one vector
summary(df_cleaned)

# Save cleaned dataset
write.csv(df_cleaned, "data/clean_df.csv")
