
library(reshape2)

# download zip file and unzip it

zipfile <- "getdata-projectfiles-UCI HAR Dataset.zip"

if (!file.exists(zipfile)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, zipfile, method="curl")
}

if (!file.exists("UCI HAR Dataset")) { 
        unzip(zipfile) 
}

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
str(activityLabels)
activityLabels[,2] <- as.character(activityLabels[,2])

features <- read.table("UCI HAR Dataset/features.txt")
str(features)
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
features[,2] = gsub('-mean', 'Mean', features[,2])
features[,2] = gsub('-std', 'Std', features[,2])
features[,2] = gsub('[-()]', '', features[,2])
featuresKept <- grep(".*Mean.*|.*Std.*", features[,2])


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresKept]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresKept]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testData <- cbind(testSubjects, testActivities, test)

# Merge training and test datasets together and label them
fullData <- rbind(trainData, testData)
featuresNames<-features[featuresKept,2]
colnames(fullData) <- c("subject", "activity", featuresNames)

# Transfom activities and subjects into factors
fullData$activity <- factor(fullData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
fullData$subject <- as.factor(fullData$subject)

fullData.melt <- melt(fullData, id = c("subject", "activity"))
fullData.mean <- dcast(fullData.melt, subject + activity ~ variable, mean)
# Out put tidy.txt file
write.table(fullData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
