#declare libraries
library(data.table)
library(dtplyr)
library(tidyr)
library(dplyr)


#Read in the test data
X_test <- fread("./ProjData/test/X_test.txt", sep = " ")
y_test <- fread("./ProjData/test/y_test.txt", sep = " ")
subject_test <- fread("./ProjData/test/subject_test.txt", sep = " ")        


#Read in the train data
X_train <- fread("./ProjData/train/X_train.txt", sep = " ")
y_train <- fread("./ProjData/train/y_train.txt", sep = " ")
subject_train <- fread("./ProjData/train/subject_train.txt", sep = " ")        

#Read in dataset info
features <- fread("./ProjData/features.txt")
activity_labels <- fread("./ProjData/activity_labels.txt")

#Step 0: Merge the test and training data (test data on top)
xlist = list(X_test, X_train)
xData = rbindlist(xlist)
ylist = list(y_test, y_train)
yData = rbindlist(ylist)
sublist = list(subject_test, subject_train)
subData = rbindlist(sublist)
names(subData) <- "Subject"

#Step 1: Identify/extract the columns with mean/std
feature_indices <- grep("*mean()|*std()", features$V2)
xData <- select(xData, feature_indices)
names(xData) <- features[feature_indices, V2]

#Step 2: Build the activity column from the y variable
aData = data.table(Activity = activity_labels[yData$V1,V2])

#step 3: Put it all into one table
allData <- cbind(subData, aData, xData)

#step 4: Gather up all the signals/measurements into one column
allData <- gather(allData, Signal, Reading, -Subject, -Activity)

#Step 5: Seperate the signals between time and freq
allData <- separate(allData, Signal, c("Domain", "Signal"),1)

#Step 6: Separate the signal type and Measurement Type
allData <- separate(allData, Signal, c("Feature", "Measurement"), sep = "-", extra = "merge")

#Step 7: Separate the Measurement type and axis, (NA for Magnitudes)
allData <- separate(allData, Measurement, c("Measurement", "Axis"), sep = "-", fill = "right")
empty <- is.na(allData$Axis)
allData[empty, 'Axis'] <- "Mag"

#Step 8: Average of data via groups
allData.mean <- aggregate(allData$Reading, by=list(allData$Subject, allData$Activity, allData$Domain, allData$Feature, allData$Measurement, allData$Axis), mean)
names(allData.mean) <- c("Subject", "Activity", "Domain", "Feature", "Measurement", "Axis", "Calculated Mean")
allData.mean[order(allData.mean$Subject,allData.mean$Activity, desc(allData.mean$Domain), allData.mean$Feature,allData.mean$Measurement, allData.mean$Axis),]

#Step 9: Write to an output file.
write.table(allData, "Tidy_Data.txt", append = FALSE, sep = " ", col.names = TRUE, row.names = FALSE)
write.table(allData, "Tidy_Mean_Data.txt", append = FALSE, sep = " ", col.names = TRUE, row.names = FALSE)
                    