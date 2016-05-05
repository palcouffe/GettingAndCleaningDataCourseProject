################################################################################
# File Name : run_analysis.R
# Reference : Getting and Cleaning Data Course Project
# Author    : Ph A
# Date      : 2016-05-02
# Version   : V1.0
# Summary   : script to transform into a tidy data set a set of source data
################################################################################

################################################################################
# Step 0.a      : Load libraries and install packages if necessary
################################################################################

if (!require(data.table,quietly=TRUE)) install.packages("data.table")
if (!require(dplyr,quietly=TRUE)) install.packages("dplyr")
if (!require(stringr,quietly=TRUE)) install.packages("stringr")

library(data.table)
library(dplyr)
library(stringr)

################################################################################
# Step 0.b      : Download and unzip data source in specifically created dir
################################################################################

# Data is downloded in specific dir data°input°zip created if does not exist yet
# This will replace with the just downloaded data any previously downloaded file
if (!file.exists("data_input_zip")) dir.create("data_input_zip")
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="data_input_zip/Dataset.zip", method="curl")
unzip ("data_input_zip/Dataset.zip",exdir=".")

# Just a good practice seen in the lessons to keep track of downloaded date
dateDownloaded <- date()

#T his is just an extrq precaution to ensure the part of the coursera submission that stipulates
# "run_analysis.R ... that can be run as long as the Samsung data is in your working directory"
if (!("UCI HAR Dataset" %in% list.files("."))) {
        stop ("Error : the Samsung data is not in your working directory.")    
}

################################################################################
# Step 1      : Merging into one set the training and the test data sets 
################################################################################

# Read the meta data features.txt and activity_labels use fread from data.table library for speed
# Note that by default stringsAsFactors = FALSE for fread
FeatureLabels <- fread("./UCI HAR Dataset/features.txt",col.names=c("featureid","featurelabel"))
ActivityLabels <- fread("./UCI HAR Dataset/activity_labels.txt",col.names=c("activityid","activitylabel"))

# Read the 3 training data set components (measures, activity ids and subject ids) and bind them as columns
# Note the col.names argument is used in the fread to adequately use the feature labels to name the variables
FeaturesMeasurements_train <- fread("./UCI HAR Dataset/train/X_train.txt",col.names=FeatureLabels$featurelabel)
ActivityIds_train <- fread("./UCI HAR Dataset/train/y_train.txt",col.names="activityid")
SubjectIds_train <- fread("./UCI HAR Dataset/train/subject_train.txt",col.names="subjectid")
# The 3 sets of data are now cbind-ed
Data_train <- cbind(SubjectIds_train,ActivityIds_train,FeaturesMeasurements_train)

# Read the 3 test data set components (measures, activity ids and subject ids) and bind them as columns
# Note the col.names argument is used in the fread to adequately use the feature labels to name the variables
FeaturesMeasurements_test <- fread("./UCI HAR Dataset/test/X_test.txt",col.names=FeatureLabels$featurelabel)
ActivityIds_test <- fread("./UCI HAR Dataset/test/y_test.txt",col.names="activityid")
SubjectIds_test <- fread("./UCI HAR Dataset/test/subject_test.txt",col.names="subjectid")
# The 3 sets of data are now cbind-ed
Data_test <- cbind(SubjectIds_test,ActivityIds_test,FeaturesMeasurements_test)

# Finally, append the 2 sets of data via row binding since they have the same variables
Data_merged <- rbind(Data_test,Data_train)

################################################################################
# Step 2        : Extract only the measurements on the mean and standard deviation 
#                 for each measurement 
################################################################################

# Create the regexp that will filter all variable names including -mean() or -std()
pattern <- "-(mean|std)\\(\\)"

# Select to keep only variables 1 (subjectid),2 (activityid) and all of the ones matching the pattern
# Note this syntax is specific to the library data.table
data_filtered <- select(Data_merged,1,2,matches(pattern))

################################################################################
# Step 3        : Name the activities in the data set with the descriptive activity names  
################################################################################

# Merge ActivityLabels and data_filtererd on the common activityid info
data_labelled <- merge(ActivityLabels,data_filtered,by.x="activityid",by.y="activityid",all=FALSE)

################################################################################
# Step 4        : Use descriptive variable names to label the data set 
################################################################################

#rename variables
#t into time-
#Acc into accelaration
#Mag into magnitude
#Gyro into  gyroscope

# Switched to lower cqse
names(data_labelled) <- tolower(names(data_labelled))

# Replaced t by time-, f by frequency, acc by accelaration,
# mag by magnitude, gyro by  gyroscope, std() by std
# mean() and bodybody by body
# Note the use of str_replace_all from library stringr
my_patterns_subs <- c(
        "^t" = "time-",
        "^f" = "frequency-",
        "acc" = "acceleration",
        "mag" = "magnitude",
        "gyro" = "gyroscope",
        "std\\(\\)" = "std",
        "mean\\(\\)" = "mean",
        "bodybody" = "body"
        )
names(data_labelled) <- str_replace_all(names(data_labelled),my_patterns_subs)

################################################################################
# Step 5        : Summarize into an independant tidy data set with the average 
#                 of each variable for each activity and each subject
################################################################################

# A narrow form is produced using melt to put all of the columns other than 
# activityid, activitylabel and subjectid as values of a new colum featurelabel
molten <- melt(data_labelled,
               id.vars=c("activityid","activitylabel","subjectid"),
               variable.name="featurelabel",
               value.name="value")

# The mean is then computed grouping by activitylabel,subjectid,featurelabel
# and using a syntax specific to data.table 
# The calculated variable is renamed mean
# Finally the resulting data.table is sorted by (activitylabel,subjectid,featurelabel
tidy_data <- 
        molten[,mean(value),by=.(activitylabel,subjectid,featurelabel)] %>%
        rename(mean=V1) %>%
        arrange(activitylabel,subjectid,featurelabel)

################################################################################
# OUTPUT        : Write the produced tidy data set in a specific directory
################################################################################

if (!file.exists("data_output")) dir.create("data_output")
write.table(tidy_data,"data_output/tidy_data.txt",row.names = FALSE)

################################################################################
# HOW TO        : Read and visualise the produced tidy data set
################################################################################
read_tidy_data <- read.table("data_output/tidy_data.txt", header = TRUE) 
#View(read_tidy_data) #This migh twork only in R Studio
