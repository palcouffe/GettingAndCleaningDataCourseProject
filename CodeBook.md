Code Book for Course Project Tidy Data Set
================

Scope of this document
----------------------

This Code Book describes a tidy data set obtained through transformations of a set of source data collected from the accelerometers from the Samsung Galaxy S smartphone. Are therefore detailed here the variables, the data and the transformations that have been performed to clean up the source data.

This document includes the following four sections :

-   **A. Study design, context and goal**
-   **B. Transformations operated**
-   **C. How to obtain the Tidy Data Set**
-   **D. Code Book describing the data and variables**

**Note** : Concerning the transformations, we made the choice to focus here on the *"what"* has been done to the initial set of source data (i.e the transformations). The *"how"*, that is a detailed explanation of the code (in [run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R)) is contained in the [README.md](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/README.md) of this repo. The objective was to keep the emphasis of this document on the description of the tidy set data. If you already went through the [README.md](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/README.md), the section B of this document might therefore seems redundant to you as it summarizes also the transformations operated but without the technical *"how"* details part. The idea was to have the two documents as independant and self contained as possible (thus the redundancy of the B section).

------------------------------------------------------------------------

A. Study design, context and goal
---------------------------------

This study is in the context of the final project of the Coursera "Getting and Cleaning Data" Course final project.
The goal was to start from an initial set of data collected (measurements) from the Samsung Galaxy S II smartphone carried on the waist by 30 volunteers (subjects) performing six activities. The initial set was originally randomly split into two sets : training data (70%) vs test data (30%). The transformations operated on this initial set aimed at :

-   *filtering* only the mean and standard deviation for each measurement
-   *summarizing* as the average those 2 type of measures for each activity and each subjet in a tidy data set appropriately labelled

The result of those transformations is the Tidy Data Set described here.

------------------------------------------------------------------------

B. Transformations operated
---------------------------

The initial source of data went through five different steps :

1.  **Merging into one set the training and the test data sets**
2.  **Extract only the measurements on the mean and stard deviation for each measurement**
3.  **Name the activities in the data set with the descriptive activity names**
4.  **Use descriptive variable names to label the data set**
5.  **Summarize into an independant tidy data seet with the average of each variable for each activity and each subject**

We will here briefly describe the initial source of the data and the five different transformations

**Reminder** : the detail on the code of those transformations ([run\_analysis.R](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/run_analysis.R)) can be found in the [README.md](https://github.com/palcouffe/GettingAndCleaningDataCourseProject/blob/master/README.md).

#### 0. Initial Data Source

The initial set of data can be found as a zip file under this [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). Once downladed, this will unzip as a `UCI HAR Dataset` directory. This directory will contain three main sets of info that have been used as the original data source :

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

The three following steps were taken to merge the training and the test data sets :

-   *Step 1* : the three **training data sets** were combined in the following way
    -   the ids of the subjects (`subject_train.txt`) and the ids of the activities (`y_train.txt`) have been appended (`cbind-ed` as columns) to the feature measurements data (`X_train.txt`)
    -   the variables of the feature measurements data have been prehalably named using the labels from `features.txt` directly at the reading of the data step (this will facilitate the selection of specific measurements in the next transformation)
-   *Step 2* : the three **test data sets** were combined along the same procedure
-   *Step 3* : The two **resulting data sets** were merged into one. Having the same variables (columns), they were merely `rbind-ed`.

The diagram below summarizes how the different set of data were merged :

![diagram](https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/datastructure.png)

#### 2. Extract only the measurements on the mean and standard deviation for each measurement

The extraction was made using a regexp pattern to filter only the relevant variable names from the merged data set (the 561 feature labels issued from `features.txt` - cf. the diagram above).
The pattern chosen was `"-(mean|std)\\(\\)"` which means all variable names including *-mean()* or *-std()*.
This extraction resulted in selecting **66 variable names out of the 561 original ones**.

**Note** : the `features_info.txt` indicates that there are other measures obtained by averaging signals such as *gravityMean*, *tBodyAccJerkMean* etc. So the question could raise if we should also include names ending with *Mean*. The decision here not to take those extra variable names was based on the fact that the `features_info.txt` presents those as "additional" and used only on the "angle() variable". The *mean()* and *std()* on the contrary were presented as two entries in a full list with their explicit definition which reinforces the presumption that those are the two ones referred to in the project.

> mean(): Mean value
> std(): Standard deviation

#### 3. Name the activities in the data set with the descriptive activity names

The labels of the activities are to be found (with their ids) in `UCI HAR Dataset/activity_labels.txt`. Our diagram above shows that our merged data set already has a variable *activityid*.
To add an extra variable column with the label (name) of the activities from the `activity_labels.txt`, the data set has been joined **on the activiyid info** with the data set issued from `activity_labels.txt`.

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

As a result the variable names (feature labels) are all in lower case and are now made of 4 segments separated by "-" (see below section D2 of this Code Book for the meanings of each segment)

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

-   The data was `melt` into a long form, all the 66 feature labels becoming values of a variable named `featurelabel` (the feature measure becoming a `value`)
-   The data was then `summarised` by computing the mean on the variable `value` grouping by `activityid`, `subjectid`, `featurelabel`

This resulted in the Tidy Data Set detailed below

------------------------------------------------------------------------

C. How to obtain the Tidy Data Set
----------------------------------

The Tidy Data set can be obtained either by direct download from this repo [link to tidy\_data.txt](https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/tidy_data.txt) or by running the [run\_analysis.R](https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/run_analysis.R). In both cases, you can use `read.table` with `header = TRUE` to read the tidy data set.

#### Code to directly download from [tidy\_data.txt](https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/tidy_data.txt) in this repo

``` r
tidy_data <- read.table("https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/tidy_data.txt", header = TRUE)
#View(tidy_data) #This View might work only under R Studio
```

#### Code to produce the set from [run\_analysis.R](https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/run_analysis.R) in this repo

If you choose to run [run\_analysis.R](https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/run_analysis.R) from this repo. The code will :

-   download the data source in a directory `./data_input_zip`
-   unzip it into `./UCI HAR Dataset` (. being your R working directory)
-   install the necessary packages and load the libraries `data.table`, `dplyr` and `stringr`
-   run the transformations and produce the `tidy_data.txt` in `./data_output`
-   you will then be able to use the code below to read the data and `View` it

``` r
source("https://raw.githubusercontent.com/palcouffe/GettingAndCleaningDataCourseProject/master/run_analysis.R")
tidy_data <- read.table("./data_output/tidy_data.txt", header = TRUE)
View(tidy_data) #This View might work only under R Studio
```

------------------------------------------------------------------------

D. Code Book describing the data and variables
----------------------------------------------

This section of the code book will include two parts

-   **D1. General description and summary of the data set** including list of variables, volumetry and summary of the data set
-   **D2. Detailed description of each of the variables** using the following template to present
    -   for each variable, its **details**
        -   *name*
        -   *type*
        -   *unit* or *nb unique values* (depending on the type)
        -   *origin* in the source data (the starting point for that data before the transformations)
        -   *main transformations* (from source and if applies)
        -   *description*
    -   for each variable, a **summary**
        -   list of values and nb of observations for each value (if the variable is of a factor type)
        -   Min, Max, Mean etc (if the variable is of a continuous type)

### D1. General description and summary of the tidy data set

##### The tidy data set has

-   **4 variables**
    -   **activitylabel** : an enumerated string (factor) with 6 possible values
    -   **subjectid** : an integer with 30 values between 1 and 30
    -   **featurelabel** : an enumerated string (factor) with 66 possible values
    -   **mean** : a numeric normalized and bounded within -1 and 1 (since the averaged values also are normalized cf `UCI HAR Dataset/README.txt`)
-   **11880 observations**
    -   each observation is the average (mean of all the measurements) for each feature label for each activity and each subject

##### Here is the summary of data that `str` gives us :

``` r
str(tidy_data)
```

    ## 'data.frame':    11880 obs. of  4 variables:
    ##  $ activitylabel: Factor w/ 6 levels "LAYING","SITTING",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ subjectid    : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ featurelabel : Factor w/ 66 levels "frequency-bodyacceleration-mean-x",..: 27 28 29 30 31 32 59 60 61 62 ...
    ##  $ mean         : num  0.2216 -0.0405 -0.1132 -0.9281 -0.8368 ...

##### Here is an example of the five first lines using `head`

``` r
head(tidy_data, 5)
```

    ##   activitylabel subjectid                 featurelabel        mean
    ## 1        LAYING         1 time-bodyacceleration-mean-x  0.22159824
    ## 2        LAYING         1 time-bodyacceleration-mean-y -0.04051395
    ## 3        LAYING         1 time-bodyacceleration-mean-z -0.11320355
    ## 4        LAYING         1  time-bodyacceleration-std-x -0.92805647
    ## 5        LAYING         1  time-bodyacceleration-std-y -0.83682741

##### Here is a summary using `table` crossing activitylabel vs. subjectid

This shows us that all subjects have done the 6 activities with 66 features averaged

``` r
table(tidy_data$activitylabel,tidy_data$subjectid)
```

    ##                     
    ##                       1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
    ##   LAYING             66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66
    ##   SITTING            66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66
    ##   STANDING           66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66
    ##   WALKING            66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66
    ##   WALKING_DOWNSTAIRS 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66
    ##   WALKING_UPSTAIRS   66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66
    ##                     
    ##                      19 20 21 22 23 24 25 26 27 28 29 30
    ##   LAYING             66 66 66 66 66 66 66 66 66 66 66 66
    ##   SITTING            66 66 66 66 66 66 66 66 66 66 66 66
    ##   STANDING           66 66 66 66 66 66 66 66 66 66 66 66
    ##   WALKING            66 66 66 66 66 66 66 66 66 66 66 66
    ##   WALKING_DOWNSTAIRS 66 66 66 66 66 66 66 66 66 66 66 66
    ##   WALKING_UPSTAIRS   66 66 66 66 66 66 66 66 66 66 66 66

### D2. Detailed description of each of the variables

#### Variable `activitylabel`

-   **Details**
    -   **name** : ***activitylabel***
    -   **type** : string (chr in R)
    -   **nb unique values** : 6 values WALKING, WALKING\_UPSTAIRS, WALKING\_DOWNSTAIRS, SITTING, STANDING, LAYING
    -   **origin** in the source data : `UCI HAR Dataset/activity_labels.txt`
    -   **description** : the label of the activity performed by the subject for the observation
-   **summary** : list of values with nb of observations

<!-- -->

    ##  activitylabel      nbobservations
    ##  LAYING             1980          
    ##  SITTING            1980          
    ##  STANDING           1980          
    ##  WALKING            1980          
    ##  WALKING_DOWNSTAIRS 1980          
    ##  WALKING_UPSTAIRS   1980

#### Variable `subjectid`

-   **Details**
    -   *name* : ***subjectid***
    -   *type* : integer (in in R)
    -   *nb unique values* : **30** values from 1 to 30
    -   *origin* in the source data : `UCI HAR Dataset/test/subject_test.txt` and `UCI HAR Dataset/test/subject_train.txt`
    -   *description* : the id of the subject who carried out the experimentation
-   **summary** : list of values with nb of observations

<!-- -->

    ##  subjectid nbobservations
    ##   1        396           
    ##   2        396           
    ##   3        396           
    ##   4        396           
    ##   5        396           
    ##   6        396           
    ##   7        396           
    ##   8        396           
    ##   9        396           
    ##  10        396           
    ##  11        396           
    ##  12        396           
    ##  13        396           
    ##  14        396           
    ##  15        396           
    ##  16        396           
    ##  17        396           
    ##  18        396           
    ##  19        396           
    ##  20        396           
    ##  21        396           
    ##  22        396           
    ##  23        396           
    ##  24        396           
    ##  25        396           
    ##  26        396           
    ##  27        396           
    ##  28        396           
    ##  29        396           
    ##  30        396

#### Variable `featurelabel`

-   **Details**
    -   *name* : ***featurelabel***
    -   *type* : string (chr in R)
    -   *nb unique values* : **66** values each a string (see complete list below, time-bodyaccelerationjerk-mean-x is an example)
    -   *origin* in the source data : `UCI HAR Dataset/features.txt`
    -   *main transformations* : filtered to keep only feature labels including *mean()* or *std()*, lower cased and abbrevations or notations put in a long form.
    -   *description* : the feature label describes the kind of signal that was measured and how It is a 4 segments string separated by -, each segment detailing more specificaly the signal measured
        -   part 1 : **time** (it it is a time domain signal that is measured) or **frequency** (for frequency domain signal if a Fast Fourier Transform (FFT) was applied ot the signal)
        -   part 2 : acceleration (either **bodyacceleration** or **gravityacceleration**) or **gyroscope** to specify the type of signal + **jerk** (if the signal was derived to obtain a Jerk Signal)
        -   part 3 : **std** or **mean** to denote the estimation made from the source signal measured
        -   part 4 optional: **-XYZ** to denote 3-axial signals in the X, Y and Z directions (some directions optional)
-   **summary** : list of values with nb of observations

<!-- -->

    ##  featurelabel                                 nbobservations
    ##  frequency-bodyacceleration-mean-x            180           
    ##  frequency-bodyacceleration-mean-y            180           
    ##  frequency-bodyacceleration-mean-z            180           
    ##  frequency-bodyacceleration-std-x             180           
    ##  frequency-bodyacceleration-std-y             180           
    ##  frequency-bodyacceleration-std-z             180           
    ##  frequency-bodyaccelerationjerk-mean-x        180           
    ##  frequency-bodyaccelerationjerk-mean-y        180           
    ##  frequency-bodyaccelerationjerk-mean-z        180           
    ##  frequency-bodyaccelerationjerk-std-x         180           
    ##  frequency-bodyaccelerationjerk-std-y         180           
    ##  frequency-bodyaccelerationjerk-std-z         180           
    ##  frequency-bodyaccelerationjerkmagnitude-mean 180           
    ##  frequency-bodyaccelerationjerkmagnitude-std  180           
    ##  frequency-bodyaccelerationmagnitude-mean     180           
    ##  frequency-bodyaccelerationmagnitude-std      180           
    ##  frequency-bodygyroscope-mean-x               180           
    ##  frequency-bodygyroscope-mean-y               180           
    ##  frequency-bodygyroscope-mean-z               180           
    ##  frequency-bodygyroscope-std-x                180           
    ##  frequency-bodygyroscope-std-y                180           
    ##  frequency-bodygyroscope-std-z                180           
    ##  frequency-bodygyroscopejerkmagnitude-mean    180           
    ##  frequency-bodygyroscopejerkmagnitude-std     180           
    ##  frequency-bodygyroscopemagnitude-mean        180           
    ##  frequency-bodygyroscopemagnitude-std         180           
    ##  time-bodyacceleration-mean-x                 180           
    ##  time-bodyacceleration-mean-y                 180           
    ##  time-bodyacceleration-mean-z                 180           
    ##  time-bodyacceleration-std-x                  180           
    ##  time-bodyacceleration-std-y                  180           
    ##  time-bodyacceleration-std-z                  180           
    ##  time-bodyaccelerationjerk-mean-x             180           
    ##  time-bodyaccelerationjerk-mean-y             180           
    ##  time-bodyaccelerationjerk-mean-z             180           
    ##  time-bodyaccelerationjerk-std-x              180           
    ##  time-bodyaccelerationjerk-std-y              180           
    ##  time-bodyaccelerationjerk-std-z              180           
    ##  time-bodyaccelerationjerkmagnitude-mean      180           
    ##  time-bodyaccelerationjerkmagnitude-std       180           
    ##  time-bodyaccelerationmagnitude-mean          180           
    ##  time-bodyaccelerationmagnitude-std           180           
    ##  time-bodygyroscope-mean-x                    180           
    ##  time-bodygyroscope-mean-y                    180           
    ##  time-bodygyroscope-mean-z                    180           
    ##  time-bodygyroscope-std-x                     180           
    ##  time-bodygyroscope-std-y                     180           
    ##  time-bodygyroscope-std-z                     180           
    ##  time-bodygyroscopejerk-mean-x                180           
    ##  time-bodygyroscopejerk-mean-y                180           
    ##  time-bodygyroscopejerk-mean-z                180           
    ##  time-bodygyroscopejerk-std-x                 180           
    ##  time-bodygyroscopejerk-std-y                 180           
    ##  time-bodygyroscopejerk-std-z                 180           
    ##  time-bodygyroscopejerkmagnitude-mean         180           
    ##  time-bodygyroscopejerkmagnitude-std          180           
    ##  time-bodygyroscopemagnitude-mean             180           
    ##  time-bodygyroscopemagnitude-std              180           
    ##  time-gravityacceleration-mean-x              180           
    ##  time-gravityacceleration-mean-y              180           
    ##  time-gravityacceleration-mean-z              180           
    ##  time-gravityacceleration-std-x               180           
    ##  time-gravityacceleration-std-y               180           
    ##  time-gravityacceleration-std-z               180           
    ##  time-gravityaccelerationmagnitude-mean       180           
    ##  time-gravityaccelerationmagnitude-std        180

### Variable `mean`

-   **Details**
    -   *name* : ***mean***
    -   *type* : numeric (num)
    -   *unit* : no unit as this a normalized value bounded within -1 and 1 (since the averaged values also are)
    -   *nb unique values* : **30** values from 1 to 30
    -   *origin* in the source data : `UCI HAR Dataset/test/X_test.txt` and `UCI HAR Dataset/test/X_train.txt`
    -   *main transformations* : test and train data set were merged, measurements for mean and std were kept and mean was computed for each subject, activity, feature measured
    -   *description* : the mean for the measurements (in the source data set) for a feature (featurelabel) for a subject (subjectid) and an activity (activitylabel)
-   **summary** : being a numeric, we just present here the result of the `summary` function (min, max etc)

``` r
summary(tidy_data$mean)
```

    ##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
    ## -0.99770 -0.96210 -0.46990 -0.48440 -0.07836  0.97450
