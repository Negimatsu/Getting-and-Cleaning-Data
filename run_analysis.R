library(plyr)
library(dplyr)
library(data.table)

if(!file.exists("./data"))
{
  dir.create("./data")  
}
## Load main data 
pathMain <- "./data/UCI HAR Dataset/"

featurePath <- paste(pathMain, "features.txt", sep="")
activtyPath <- paste(pathMain, "activity_labels.txt", sep="")

dataFeature <- read.table(featurePath, header = FALSE)[,2]
dataActivityLabel <- read.table(activtyPath, header = FALSE)
names(dataActivityLabel) <- c("Activity_ID", "Activity_name")


## Load Test Data and set column names
pathTest <- "./data/UCI HAR Dataset/test/"

SubjectTest <-"subject_test.txt"
XTest <-"X_test.txt"
YTest <- "y_test.txt"

SubjectTestFile <- paste(pathTest, SubjectTest, sep="")
XTestFile <- paste(pathTest, XTest, sep="")
YTestFile <- paste(pathTest, YTest, sep="")

SubjectTestData <- read.table(SubjectTestFile, header = FALSE)
names(SubjectTestData) = "Subject"

XTestData <- read.table(XTestFile, header = FALSE)
names(XTestData) = dataFeature

YTestData <- read.table(YTestFile, header = FALSE)
names(YTestData) <- "Activity_ID"
YTestData <- join(YTestData,dataActivityLabel, by= "Activity_ID")

DataTest <- cbind(SubjectTestData, YTestData, XTestData, deparse.level = 0)

## Load Train Data and set column names
pathTrain <- "./data/UCI HAR Dataset/train/"

SubjectTrain <-"subject_train.txt"
XTrain <-"X_train.txt"
YTrain <- "y_train.txt"

SubjectTrainFile <- paste(pathTrain, SubjectTrain, sep="")
XTrainFile <- paste(pathTrain, XTrain, sep="")
YTrainFile <- paste(pathTrain, YTrain, sep="")

SubjectTrainData <- read.table(SubjectTrainFile, header = FALSE)
names(SubjectTrainData) = "Subject"

XTrainData <- read.table(XTrainFile, header = FALSE)
names(XTrainData) = dataFeature

YTrainData <- read.table(YTrainFile, header = FALSE)
names(YTrainData) <- "Activity_ID"
YTrainData <- join(YTrainData, dataActivityLabel, by= "Activity_ID")

DataTrain <- cbind(SubjectTrainData, YTrainData, XTrainData, deparse.level = 0)


#### Mearge test data and train data
data = rbind(DataTest, DataTrain)

## Select only mean and std column
selectFeature  <-  grep(".*Mean.*|.*std.*", dataFeature, ignore.case = TRUE )
selectData <-  data[, selectFeature]

#melt data for label and value
IDLabels <-  c("Subject", "Activity_ID", "Activity_name")
dataLabels <-  setdiff(colnames(selectData), IDLabels)
meltData <-  melt(selectData, id = IDLabels, measure.vars = dataLabels)

#Calculate mean each subject and activity name with dcast
tidyData <-  dcast(meltData, meltData$Subject + meltData$Activity_name  ~ variable, mean)
names(tidyData) <- c("Subject", "Activity_Name", dataLabels)


##Export file
write.table(tidyData, file = "./tidy_data.txt")
