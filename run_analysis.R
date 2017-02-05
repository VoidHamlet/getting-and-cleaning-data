## This script satisfies the following tasks from the linked data source:
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## First of all, let's get the data. The task instructions do not include this part but download.file and unzip would do in a pinch.
## I would rather not make assumptions or changes as to the working directory of everyone else, ergo using my own for this example.

## We will work with the below two libraries. If they are not installed, install.package("packagename") should be run first.

require("data.table")
require("plyr")

library(data.table)
library(plyr)

## It pays off to read what we are working with first (i.e., README, metadata).
## We are going to have R read the metadata but the README is for you.

featureNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

## On examining the data sets, each of the train and test sets accounts for subject, features, activity.
## Let's read them and store them. Pet peeve: uppercase "X" and lowercase "y" but we'll be rid of that shortly.

trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
trainFeatures <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)
trainActivity <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)

testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
testFeatures <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
testActivity <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)

## On to combine each of the sets. No more pet peeves in the naming notation.

subject <- rbind(trainSubject, testSubject)
features <- rbind(trainFeatures, testFeatures)
activity <- rbind(trainActivity, testActivity)

## Now to address the column names, starting from the metadata.
## featureNames is self-descriptive, activityLabels we can split.

colnames(activityLabels) <- c("Activity_ID", "Activity_Name")

## featureNames comes handy when naming the features set columns.

colnames(features) <- t(featureNames[2])

## And now for the rest of them.

colnames(activity) <- "Activity_ID"
colnames(subject) <- "Subject_ID"

## Finally, we can merge the data.

combiData <- cbind(features, activity, subject)

## Now let's get the means.

colMeanSTD <- grep(".*Mean.*|.*Std.*", names(combiData), ignore.case=TRUE)

## names(combiData) gives us numericIDs for the two columns we need to add there:
## Activity_ID and Subject_ID, at 562 and 563 respectively.
## Might as well use that to differentiate and populate our resulting data subset.

colMeanSTD <- c(colMeanSTD, 562, 563)
combiDataSubset <- combiData[,colMeanSTD]

## Apply descriptive activity names to name the activities in the data set - first, let's pause.
## While checking tail(str(combiDataSubset)), we observe that the Activity_ID is of type integer.
## That one we need to represent as type character, in order to supply the names there instead.
## activityLabels has a total of 6 IDs, ergo we can substitute each ID with each name leisurely.

combiDataSubset$Activity_ID <- as.character(combiDataSubset$Activity_ID)
for (i in 1:6)
	{
	combiDataSubset$Activity_ID[combiDataSubset$Activity_ID == i] <- as.character(activityLabels[i,2])
	}

## Lesson learned the hard way, we have to factor the resulting vector.
 
combiDataSubset$Activity_ID <- as.factor(combiDataSubset$Activity_ID)

## Appropriately labelling the data set with descriptive variable names
## requies a look at the names(combiDataSubset) which has abbreviations aplenty.
## We address them and my "consistency with upper or lower case" pet peeve below.

names(combiDataSubset) <- gsub("Acc", "Accelerometer", names(combiDataSubset))
names(combiDataSubset) <- gsub("angle", "Angle", names(combiDataSubset))
names(combiDataSubset) <- gsub("BodyBody", "Body", names(combiDataSubset))
names(combiDataSubset) <- gsub("^f", "Frequency", names(combiDataSubset))
names(combiDataSubset) <- gsub("-freq()", "Frequency", names(combiDataSubset), ignore.case = TRUE)
names(combiDataSubset) <- gsub("Gyro", "Gyroscope", names(combiDataSubset))
names(combiDataSubset) <- gsub("gravity", "Gravity", names(combiDataSubset))
names(combiDataSubset) <- gsub("Mag", "Magnitude", names(combiDataSubset))
names(combiDataSubset) <- gsub("-mean()", "Mean", names(combiDataSubset), ignore.case = TRUE)
names(combiDataSubset) <- gsub("-std()", "Standard", names(combiDataSubset), ignore.case = TRUE)
names(combiDataSubset) <- gsub("^t", "Time", names(combiDataSubset))
names(combiDataSubset) <- gsub("tBody", "TimeBody", names(combiDataSubset))

## Check names(combiDataSubset) again, see if they are to our satisfaction.

## What's left is to create a second, independent tidy data set
## with the average of each variable for each activity and each subject.
## We've got just the guy for that. Shameless plug for ddply:
## Split data frame, apply function, return results in a data frame.

tidyAverageSubset <- ddply(combiDataSubset, c("Subject_ID", "Activity_ID"), numcolwise(mean))
write.table(tidyAverageSubset, file="UCI HAR Dataset/TidyAverageSubset.txt", row.name=FALSE)