---
title: "Codebook"
author: "pdwessel"
date: "October 2, 2016"
output: html_document
---

#Codebook to accompany Course Project

##Tidy Dataset - Variables

My tidy data set contains 7 variables:

1. Subject
+ Tracks which subject the readings are for.
        
2. Activity
+ A categorical variable.
+ Six possible activities.
+ Is the activity the subject was performing at the time the measurement was taken.

3. Domain
+ A categorical variable.
+ Can be either 't' for time in seconds, or 'f' for frequency in Hz. 
+ Notes the domain the measurement is calculated in.
        
4. Feature
+ A categorical variable.
+ Takes on one of the 17 features
        
5. Measurement
+ A Categorical variable
+ Notes if the measurement is the mean 'mean' or standard deviation 'std'
        
6. Axis
+ A Categorical variable
+ Four possible categories for the reading including the XYZ axies, as well as 'Mag' for non-directional measurments.
        
7. Reading
+ A real value numeric variable, which is the calculated value for the identified item. The units depend on the domain
        
##Tidy Dataset - Transformations

To tidy the dataset I used three transformations.

###Select

I used the select funtion to subset the features data to contain only the relevant columns, that is any feature that contained the terms "mean()" or "std()".


###Gather

I used the gather function to gather together all of the measurement data into a single column. This was done to ensure that each row of data represented a single observation.

###Separate

Following the principles of a tidy data set, namely that each column represents only one variable. I identified that the feature names contain four different variables.

1. Domain
+ The first letter of the feature was either a t or f for time and frequency respectively. I parsed this first letter off and group and put it into a new column, representing the domain variable.

2. Feature
+ The next item I parsed was the feature name,that is what was being measured. There are 17 seperated features.

3. Measurement
+ I had already selected only the mean and standard deviation calculations but now it isolated them into their own column

4. Axis
+ Finally the measurements were all computed along the three primary axis. However as some of the compluted value were not tied to an axis and were more of a Magnitude I added in a fourth category to this column to capture magnitude.
