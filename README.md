Getting and Cleaning Data Course Project
================

Scope of this document
----------------------

In the context of our final project assignment, we are to demonstrate our ability to produce a tidy data set to be used for later analysis from a source data set that will undergo several transformations. This README details the [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R) script that was written to perform these transformations (downlading, merging, extracting etc). The output of the [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R) script is a tidy data set fully described in the [Code Book](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/CodeBook.md).

This document includes the following four sections :

-   **A. Study design, context and goal**
-   **B. Technical Details of the Transformations operated by [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R)**
    -   Step 0. Preliminary downloading and exploration of the source data set
    -   Step 1. Merging the training and the test sets to create one data set
    -   Step 2. Extracting only the measurements on the mean and standard deviation for each measurement
    -   Step 3. Naming the activities in the data set using descriptive activity names
    -   Step 4. Appropriately labelling the data set with descriptive variable names
    -   Step 5. From the data set in step 4, creating a second, independent tidy data set with the average of each variable for each activity and each subject
-   **C. How to read the produced Tidy Data Set**
-   **D. References**

In this repository you will find

-   [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R) : the script containing all the transformations corresponding to the steps of the assignment
-   README.md : this document
-   [tidy\_data.txt](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/tidy_data.txt) : the tidy data set produced by the [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R) script
-   [CodeBook.md](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/CodeBook.md) : the Code Book that describes the variables, the data from the tidy data set and any transformations or work that were performed to clean up the source data

**Note** : We made the choice to emphasize in this README, the technical details of *how* things were done in [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R) in addition to describing of *what* was done. In parallel, we therefore choose to limit the Code Book to the *what* (and not the *how*) and the detailed description of the tidy data set, its variables and any transformations or work that were performed to clean up the source data.

The reader will therefore notice those 2 documents have in common that *what* part (especially the descriptive parts of sections A and B). This was a deliberate choice to ensure that each document was fully complete and understandable by itself.

------------------------------------------------------------------------

A. Study design, context and goal
---------------------------------

This study is in the context of the final project of the Coursera "Getting and Cleaning Data" Course final project.
The goal was to start from an initial set of data collected (measurements) from the Samsung Galaxy S II smartphone carried on the waist by 30 volunteers (subjects) performing six activities. The initial set was originally randomly split into two sets : training data (70%) vs test data (30%). The transformations operated on this initial set aimed at :

-   *filtering* only the mean and standard deviation for each measurement
-   *summarizing* as the average those 2 type of measures for each activity and each subjet in a tidy data set appropriately labelled

The result of those transformations is the Tidy Data Set described in the [Code Book](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/CodeBook.md)

------------------------------------------------------------------------

B. Technical Details of the Transformations operated by [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### 0. Preliminary downloading and exploration of the source data set

##### Installing packages and loading libraries

The following three libraries are used

-   `data.table` chosen for the speed to read tables using fread, for the `melt` function to tidy the data and for the nice aggregation using `by.()` feature to compute the mean in the last step
-   `dplyr` to re arrange and sort data using `rename` and `arrange`
-   `stringr` for the fun as it allows to substitute different patterns with different replacements on a string in one scoop, an info I shared on our forum [here](https://www.coursera.org/learn/data-cleaning/module/78HFW/discussions/WYSgqQu8EeaO1w7d1s7iLw). If the necessary packages are not installed, the script will install them.

``` r
if (!require(data.table,quietly=TRUE)) install.packages("data.table")
if (!require(dplyr,quietly=TRUE)) install.packages("dplyr")
if (!require(stringr,quietly=TRUE)) install.packages("stringr")

library(data.table)
library(dplyr)
library(stringr)
```

##### Downlaoding the source data set

The initial set of data can be found as a zip file under this [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). It is downloaded into a directory `data_input_zip` (created if it does not already exists) and unzipped into the work directory as `UCI HAR Dataset`. Note that this will replace with the just downloaded data any previously downloaded data.

``` r
if (!file.exists("data_input_zip")) dir.create("data_input_zip")
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="data_input_zip/Dataset.zip", method="curl")
unzip ("data_input_zip/Dataset.zip",exdir=".")
```

##### Exploring and understanding the source data set

This`UCI HAR Dataset` directory will contain three main sets of info that will be used as the original data source :

-   *meta data info* :
    -   `UCI HAR Dataset/activity_labels.txt` : the labels of the activities (6) with their corresponding id
    -   `UCI HAR Dataset/features.txt` : the labels of the features measured (561) with their corresponding id
-   *test data set* : 3 sets of data
    -   `UCI HAR Dataset/test/X_test.txt` : the 561-vector Feature measurements (2947x561), each one for an activity in `y_test.txt` and a subject in `subject_test.txt`
    -   `UCI HAR Dataset/test/y_test.txt` : the ids of the activities (2947) for each 561-vector in `X_test.txt`
    -   `UCI HAR Dataset/test/subject_test.txt` : the ids of the subject (2947) for each 561-vector in `X_test.txt`
-   *training data* set : 3 sets of data
    -   `UCI HAR Dataset/train/X_train.txt` : the 561-vector Feature measurements (7352x561), each one for an activity in `y_train.txt` and a subject in `subject_train.txt`
    -   `UCI HAR Dataset/train/y_train.txt` : the ids of the activities (7352) for each 561-vector in `X_train.txt`
    -   `UCI HAR Dataset/train/subject_train.txt` : the ids of the subject (7352) for each 561-vector in `X_train.txt`

The `UCI HAR Dataset` directory also contains two explanatory files essential to understand the data :

-   `UCI HAR Dataset/README.txt`: general info about the experiment, measures and details of all the files contained in `UCI HAR Dataset`
-   `UCI HAR Dataset/features_info.txt` : information about the variobles used on the feature vector (the 561-vector measures in `UCI HAR Dataset/features.txt`)

**Note** : the \`Inertial Signals' data have been ignored for this study since it did not contain any mean or std measures.

#### 1. Merging into one set the training and the test data sets

The diagram below summarizes how the different set of data were merged :

![diagram](https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/datastructure.png)

A preliminary step was to load the meta data info described above. `fread` from `data.table` library is used for speed efficiency. Note that by default `stringsAsFactors = FALSE` for `fread`.

``` r
# 
FeatureLabels <- fread("./UCI HAR Dataset/features.txt",col.names=c("featureid","featurelabel"))
ActivityLabels <- fread("./UCI HAR Dataset/activity_labels.txt",col.names=c("activityid","activitylabel"))
```

Then the three following steps were taken to merge the training and the test data sets :

-   *Step 1* : the three **training data sets** were read then combined in the following way
    -   the ids of the subjects (`subject_train.txt`) and the ids of the activities (`y_train.txt`) have been appended (`cbind-ed` as columns) to the feature measurements data (`X_train.txt`)
    -   the variables of the feature measurements data have been prehalably named using the labels from `features.txt` directly at the reading of the data step (this will facilitate the selection of specific measurements in the next transformation)

``` r
# Note the col.names argument is used in the fread to adequately use the feature labels to name the variables
FeaturesMeasurements_train <- fread("./UCI HAR Dataset/train/X_train.txt",
                                    col.names=FeatureLabels$featurelabel)
ActivityIds_train <- fread("./UCI HAR Dataset/train/y_train.txt",
                           col.names="activityid")
SubjectIds_train <- fread("./UCI HAR Dataset/train/subject_train.txt",
                          col.names="subjectid")
# The 3 sets of data are now cbind-ed
Data_train <- cbind(SubjectIds_train,ActivityIds_train,FeaturesMeasurements_train)
```

-   *Step 2* : the three **test data sets** were read then combined along the same procedure

``` r
# Note the col.names argument is used in the fread to adequately use the feature labels to name the variables
FeaturesMeasurements_test <- fread("./UCI HAR Dataset/test/X_test.txt",col.names=FeatureLabels$featurelabel)
ActivityIds_test <- fread("./UCI HAR Dataset/test/y_test.txt",col.names="activityid")
SubjectIds_test <- fread("./UCI HAR Dataset/test/subject_test.txt",col.names="subjectid")
# The 3 sets of data are now cbind-ed
Data_test <- cbind(SubjectIds_test,ActivityIds_test,FeaturesMeasurements_test)
```

-   *Step 3* : The two **resulting data sets** were merged into one. Having the same variables (columns), they were merely `rbind-ed`.

``` r
Data_merged <- rbind(Data_test,Data_train)
```

**Note** : adding a variable source in step 1 and 2 to keep the provenance (either from *training* or *test* set of data) could have been considered but since no further transformations involved that info it was not done.

#### 2. Extract only the measurements on the mean and standard deviation for each measurement

The extraction was made using a regexp pattern to filter only the relevant variable names from the merged data set (the 561 feature labels issued from `features.txt` - cf. the diagram above).
The pattern chosen was `"-(mean|std)\\(\\)"` which means all variable names including *-mean()* or *-std()*. Note the syntax of `select` is specific to the library `data.table`.

``` r
pattern <- "-(mean|std)\\(\\)"
# Select to keep only variables 1 (subjectid),2 (activityid) and all of the ones matching the pattern
data_filtered <- select(Data_merged,1,2,matches(pattern))
```

This extraction resulted in selecting **66 variable names out of the 561 original ones**.

**Note** : the `features_info.txt` indicates that there are other measures obtained by averaging signals such as *gravityMean*, *tBodyAccJerkMean* etc. So the question could raise if we should also include names ending with *Mean*. The decision here not to take those extra variable names was based on the fact that the `features_info.txt` presents those as "additional" and used only on the "angle() variable". The *mean()* and *std()* on the contrary were presented as two entries in a full list with their explicit definition which reinforces the presumption that those are the two ones referred to in the project.

> mean(): Mean value
> std(): Standard deviation

#### 3. Name the activities in the data set with the descriptive activity names

The labels of the activities are to be found (with their ids) in `UCI HAR Dataset/activity_labels.txt`. Our diagram above shows that our merged data set already has a variable *activityid*.
To add an extra variable column with the label (name) of the activities from the `activity_labels.txt`, the data set has been joined **on the activiyid info** with the data set issued from `activity_labels.txt`.

``` r
data_labelled <- merge(ActivityLabels,data_filtered,
                       by.x="activityid",by.y="activityid",all=FALSE)
```

#### 4. Use descriptive variable names to label the data set

The goal of the renaming of the 66 selected measurements variables (feature labels) is to make them as readible as possible. As shown in our diagram above, those names originated from `UCI HAR Dataset/features.txt` and are described in detail in `UCI HAR Dataset/features_info.txt`.

-   *As a first step*, the variables names (feature labels) have been all turned to lower. Though this is not compulsory and actually might for some people make things less readable (the upper case limiting a "word"), this was a choice dictated by good practice.
-   *Then* the following abbreviations or notations were replaced in the following way :
    -   *t* by *time-*
    -   *f* by *frequency-*
    -   *acc* by *acceleration*
    -   *mag* by *magnitude*
    -   *gyro* by *gyroscope*
    -   *std()* by *std*
    -   *mean()* by *mean*
    -   *bodybody* by *bodybody*

We decided to use the `str_replace_all` function from the library `stringr` to code in one call these substitutions (see References) just for the elegance (in our eyes).

``` r
names(data_labelled) <- tolower(names(data_labelled))
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
```

As a result the variable names (feature labels) are all in lower case and are now made of 4 segments separated by "-" (see section D2 of the [Code Book](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/CodeBook.md) for the meanings of each segment)

#### 5. Summarize into an independant tidy data set with the average of each variable for each activity and each subject

There are certainly two choices to present our filtered and summarized data set as "tidy".

-   One is to present the measurements names (feature labels) as different columns (as in the original merged set). This is referred to the **"wide form"**.
-   The other is to present all of the measurements names (feature labels) in one column. This is referred to as the **"long or narrow form"**

As reminded in David Hood's (so helpful) advices for the assignement to be found [here](https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/), both forms are considerered tidy :

> Depending on the interpretation, this could support either data in the wide (first) or the long form (second) being in tidy format, and the marking rubric specifically accepts wide or long.

We opted here for the **"long form"**, for the following reasons :

-   once measurements names (feature labels) are put into one column, the final set has 4 variables (`activityid`, `subjectid`, `featurelabel`, `mean`). With that lay out, one can say that each observation (row) is indeed the average of each variable (measures for the feature label) for each activity and each subject (as required by the assignment). We have therefore one column for each part of the assignment statement.
-   although we cannot pre-judge of the future utilisations of our tidy data set, having all the mean values in one column will certainly be more practical for plotting, aggregation and further computations (by activity, by subject, by feature label)

Two steps were undertaken to summarize in this format our merged data set :

-   The data was `melt` into a long form, all the 66 feature labels becoming values of a variable named `featurelabel` (the feature measure becoming a `value`) and. This narrow form is produced using `melt` to put all of the columns other than `activityid`, `activitylabe`l and `subjectid` as values of a new colum `featurelabel`.

``` r
molten <- melt(data_labelled,
               id.vars=c("activityid","activitylabel","subjectid"),
               variable.name="featurelabel",
               value.name="value",
               variable.factor=FALSE)
```

-   The data was then `summarised` by computing the mean on the variable `value` grouping by `activitylabel`, `subjectid`, `featurelabel`. It was also ordered by `activitylabel` then `subjectid` then `featurelabel` (all ascending). Note that the syntax to group by the three variables and aggregate the measurements value into a mean is specific to the library `data.table` (see References)

``` r
tidy_data <- 
        molten[,mean(value),by=.(activitylabel,subjectid,featurelabel)] %>%
        rename(mean=V1) %>%
        arrange(activitylabel,subjectid,featurelabel)
```

This resulted in the Tidy Data Set detailed below

``` r
if (!file.exists("data_output")) dir.create("data_output")
write.table(tidy_data,"data_output/tidy_data.txt",row.names = FALSE)
```

------------------------------------------------------------------------

C. How to read the produced Tidy Data Set
-----------------------------------------

The Tidy Data Set produced by [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R) as a file `tidy_data.txt` placed in the directory `data_output` (created if not exists). It can be loaded using `read.table` with the argument `header=TRUE`.

``` r
read_tidy_data <- read.table("data_output/tidy_data.txt", header = TRUE) 
View(read_tidy_data)
```

------------------------------------------------------------------------

D. References
-------------

I would like to include here a few links to some info that I found useful to help me through this assignment :

1.  First of all of corse and without saying all of the classes from Week 2 and Week 3
2.  The immensely useful [link](https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/) that David Hood provided helped me ensure that I was asking myself the right questions
3.  The [vignette of data.table library](https://rawgit.com/wiki/Rdatatable/data.table/vignettes/datatable-intro.html) vignette of `data.table` library here helped me with the specificity of column selection and grouping by that proved very efficient for the last step to summarise data by mean, especially the section on *aggregation using by*. The [cheat sheet](https://www.google.ca/url?sa=t&rct=j&q=&esrc=s&source=web&cd=10&ved=0ahUKEwjlyIL48anMAhXGaz4KHT_wCG4QFghWMAk&url=https%3A%2F%2Fwww.rstudio.com%2Fwp-content%2Fuploads%2F2015%2F02%2Fdata-wrangling-cheatsheet.pdf&usg=AFQjCNG_Ls2vJHHE1mi4ZHP1mLioHVqIXA) I shared on our [forum](https://www.coursera.org/learn/data-cleaning/module/jjNES/discussions/qyafVQrxEeayPAoPBKi3uQ) was also very helpful.
4.  The use of the library `stringr` to substitute different patterns with different replacements on a string in one scoop was found in a stackoverflow [thread](http://stackoverflow.com/questions/19424709/r-gsub-pattern-vector-and-replacement-vector), a link I shared on our forum [here](https://www.coursera.org/learn/data-cleaning/module/78HFW/discussions/WYSgqQu8EeaO1w7d1s7iLw)
5.  The use of Studio R Markdown to produce markdown documents with code was something new to me that I discovered through the [Nice R Code Blog](http://nicercode.github.io/guides/reports/)
