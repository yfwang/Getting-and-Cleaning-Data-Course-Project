
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")


# Download and unzip the dataset: -----------------------------------------
filename <- "getdata_dataset.zip" # assigning extension to object "filename"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

## 1.Merges the training and the test sets to create one data set.
## =================================================================
# load activiy labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# load data column name
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# load x_test, y_test, subject_test and do the column bind
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(X_test) <- features
test_data <- cbind(subject_test,y_test,X_test)


# load x_train, y_train, subject_train and do the column bind
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) <- features
train_data <- cbind(subject_train,y_train,X_train)

# bind test and train data
data <- rbind(test_data,train_data)

##2.Extracts only the measurements on the mean and standard deviation for each measurement.
## =================================================================
extract_features <- grepl("mean|std", features)
data <- data[,extract_features]


##3.Uses descriptive activity names to name the activities in the data set
## =================================================================
data[,2] <- activity_labels[data[,2]]


##4.Appropriately labels the data set with descriptive variable names.
## =================================================================
id_labels   <-  c("subject", "activity")
names(data)[1:2] <- id_labels


# remove special characters
feature_descriptive <- gsub("[\\(\\)-]", "", features)
feature_descriptive <- feature_descriptive[extract_features]

# expand abbreviations and clean up names
feature_descriptive <- gsub("^f", "frequencyDomain", feature_descriptive)
feature_descriptive <- gsub("^t", "timeDomain", feature_descriptive)
feature_descriptive <- gsub("Acc", "Accelerometer", feature_descriptive)
feature_descriptive <- gsub("Gyro", "Gyroscope", feature_descriptive)
feature_descriptive <- gsub("Mag", "Magnitude", feature_descriptive)
feature_descriptive <- gsub("Freq", "Frequency", feature_descriptive)
feature_descriptive <- gsub("mean", "Mean", feature_descriptive)
feature_descriptive <- gsub("std", "StandardDeviation", feature_descriptive)
feature_descriptive <- gsub("BodyBody", "Body", feature_descriptive)

names(data)[3:81] <- feature_descriptive
data_labels <- setdiff(colnames(data), id_labels)


##5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## =================================================================
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)
tidy_data   = dcast(melt_data, subject + activity ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt")







