# GetCleanProject
Course project for the Coursera - John Hopkins University course Getting and Cleaning Data

##Assumptions

This script assumes that the data package was downloaded in the same directory as the working directory for the R script. Otherwise the file paths may need to be altered. 

##Script - run_analysis

There is only one script 'run_analysis' which is used to merge and tidy the data. 

###Overview

I took the following approach to cleaning this data set.

1. Merge corresponding train/test sets.
2. Subset relevant columns, update activity info.
3. Gather all calculated values into a single column.
4. Seperate the various categories in the features.

###Step 0 

The first step I took to transforming the data was to merge all the test-train pairs of data with each other. I accomplished this by creating a list of the pair of data tables and using the **rbindlist** function to stack the tables. I made sure to always stack the test data on top. I also went ahead and named the subject column.

```{r}
#Step 0: Merge the test and training data (test data on top)
xlist = list(X_test, X_train)
xData = rbindlist(xlist)
ylist = list(y_test, y_train)
yData = rbindlist(ylist)
sublist = list(subject_test, subject_train)
subData = rbindlist(sublist)
names(subData) <- "Subject"
```

###Step 1

The next step was to extract only the relevant columns from the xdata sets. To do this I searched the features vector for the name of any features that contained either "mean()" or "std()" through the use of the **grep** function. This gave me a vector of columns which referenced the columns I would be interested in, in the x Data. I used the **select** function to downsample the x data to only these columns. I then renamed these columns according to the feature they represent.


```{r}
#Step 1: Identify/extract the columns with mean/std
feature_indices <- grep("*mean()|*std()", features$V2)
xData <- select(xData, feature_indices)
names(xData) <- features[feature_indices, V2]
```

###Step 2

I built the data.table for the activities. Knowing that the yData contained a number reference to a named activity, i used it as a key for the activity labels to get a vector of named activities.

```{r}
#Step 2: Build the activity column from the y variable
aData = data.table(Activity = activity_labels[yData$V1,V2])
```

###Step 3

I used **cbind** to bind all the data to a single table now that I had three tables with the same number of observations. 

```{r}
#step 3: Put it all into one table
allData <- cbind(subData, aData, xData)
```

###Step 4

I used the **gather** function to bring together all of the features into two columns, the feature category and the reading.

```{r}
#step 4: Gather up all the signals/measurements into one column
allData <- gather(allData, Signal, Reading, -Subject, -Activity)
```

###Step 5

The feature (or signal) column now contains 4 variables. I started to separate these by using the **separate** function to take off the first letter which is either a t or f, for the time and frequecy domains, into its own column.

```{r}
#Step 5: Seperate the signals between time and freq
allData <- separate(allData, Signal, c("Domain", "Signal"),1)
```

###Step 6

I continued to use **seperate** to parse out the next variable which was the feature. The was structure to the data, a '-' was the seperator which made it easy to isolate the variable. I used *extra = merge"* to ensure that only the first '-' was used as a separator.

```{r}
#Step 6: Separate the signal type and Measurement Type
allData <- separate(allData, Signal, c("Feature", "Measurement"), sep = "-", extra = "merge")
```

###Step 7

Finally, I separated what was being measured (mean, std) from the axis. If the measurment was not along an axis I assigned the value "Mag" for magnitude.

```{r}
#Step 7: Separate the Measurement type and axis, (NA for Magnitudes)
allData <- separate(allData, Measurement, c("Measurement", "Axis"), sep = "-", fill = "right")
empty <- is.na(allData$Axis)
allData[empty, 'Axis'] <- "Mag"
```

###Step 8

This step was to create the mean of the readings over all the categories. For this I used the **aggregate** function. I renamed the columns and sorted for ease of viewing via the **order** funciton. 

```{r}
#Step 8: Average of data via groups
allData.mean <- aggregate(allData$Reading, by=list(allData$Subject, allData$Activity, allData$Domain, allData$Feature, allData$Measurement, allData$Axis), mean)
names(allData.mean) <- c("Subject", "Activity", "Domain", "Feature", "Measurement", "Axis", "Calculated Mean")
allData.mean[order(allData.mean$Subject,allData.mean$Activity, desc(allData.mean$Domain), allData.mean$Feature,allData.mean$Measurement, allData.mean$Axis),]
```

###Step 9

I used **write.table** to write the output text files.

```{r}
#Step 9: Write to an output file.
write.table(allData, "Tidy_Data.txt", append = FALSE, sep = " ", col.names = TRUE, row.names = FALSE)
write.table(allData, "Tidy_Mean_Data.txt", append = FALSE, sep = " ", col.names = TRUE, row.names = FALSE)
