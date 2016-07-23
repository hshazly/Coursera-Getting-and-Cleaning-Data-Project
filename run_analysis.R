library(reshape2)

zipFile = "getdata_dataset.zip"

url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if(!file.exists(zipFile)){
    download.file(url, zipFile, method = "curl")
}

if(!file.exists("UCI HAR Dataset")){
    unzip(zipFile)
}


# LOAD ACTIVITY LABELS & FEATURES
labels <- read.table("UCI HAR Dataset/activity_labels.txt")
labels[,2] <- as.character(labels[,2])

features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# EXTRACT MEAN & STD DEVIATION
fset <- grep(".*mean.*|.*std.*", features[,2])
fset.names <- features[fset,2]
fset.names = gsub('-mean', 'Mean', fset.names)
fset.names = gsub('-std', 'Std', fset.names)
fset.names <- gsub('[-()]', '', fset.names)

# LOAD TRAIN & TEST DATASETS
trainx <- read.table("UCI HAR Dataset/train/X_train.txt")[fset]
trainy <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(subject_train, trainy, trainx)

testx <- read.table("UCI HAR Dataset/test/X_test.txt")[fset]
testy <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(subject_test, testy, testx)


# MERGE AND ADD LABELS
data <- rbind(train, test)
colnames(data) <- c("subject", "activity", fset.names)



data.melted <- melt(data, id = c("subject", "activity"))
data.mean <- dcast(data.melted, subject + activity ~ variable, mean)

write.table(data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
