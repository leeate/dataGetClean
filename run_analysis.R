#### You should change your working directory to the "UCI HAR dataset" folder, otherwise this script wont work! ###
# e.g.
setwd("./UCI HAR Dataset")


# 1. Reading in the initial data 
test <- read.table("./test/X_test.txt", header=FALSE)
train <- read.table("./train/X_train.txt", header=FALSE)


# 2. Adding (common) variable names to each file
#    This is what "appropriately labels the data set with descriptive variable names" (step 4)
varLabs <- readLines("./features.txt")
varLabsWoNums <- as.character(sapply(varLabs, # Getting rid of numbers before the feature names
                        function(x) { y <- strsplit(x," "); y[[1]][[2]]}))
names(test) <- varLabsWoNums
names(train) <- varLabsWoNums


# 3. Adding Activity and Subject variables, which were stored in seperate files
test$Activity <- readLines("./test/y_test.txt")
train$Activity <- readLines("./train/y_train.txt")
test$Subject <- readLines("./test/subject_test.txt")
train$Subject <- readLines("./train/subject_train.txt")


# 4. Merging the two datsets
data <- rbind(test,train)


# 5. Replacing numbered activities with descriptive names, from "./activity_labels.txt". 
#    That is, making a factor variable of the 'Activity' variable.

actLabs <- readLines("activity_labels.txt")
actLabsWoNums <- sapply(actLabs, # They contained numbers too at the beginning of each line, so we remove them  
       function(x) { y <- strsplit(x," "); y[[1]][[2]]})
data$Activity <- as.factor(data$Activity) # Treat 'Activity' variable as factor, then add the imported activity names as factor labels.
levels(data$Activity) <- as.character(actLabsWoNums)


# 6. Extracting only the measurements on the mean and standard deviation.

ind_mean <- grep("mean", names(data)) # First, we select these variables, by looking up "mean" and "std" among the names
ind_std <- grep("std", names(data))
ind_subj <- which(names(data) =="Subject") # Also adding indices of "Subject" and "Activity"
ind_act <- which(names(data) =="Activity")
data2 <- data[, c(ind_mean, ind_std, ind_subj, ind_act)] 


# 7. Making the data tidy, using the aggregate() function, to make "Subject-Activity" combinations.

tidy <- aggregate(data2, by=list(data2$Subject, data2$Activity), FUN=mean, na.rm=TRUE)
drop <- c("Activity","Subject") # Dropping "old" Subject and Activity variables, as they will give NA's. (You can't average factors).
tidy <- tidy[, !(names(tidy) %in% drop)] # They now show up as grouping variables "Group.1" and "Group.2"
names(tidy)[1:2] <- c("Subject","Activity") # aggregate() names the grouping variable "Group.x", which is not really meaningful, so w change 'em
tidy$Subject <- as.numeric(tidy$Subject) # It also treats grouping variables as factor, but in this way, the ordering would be stupid (e.g. 1,10,100..)
tidy <- tidy[order(tidy$Subject),] # Finally, we order the tidy data by the Subject variable. Why it was messed up in the first place, I don't know.


# 8. Writing the tidy data to a text file.

write.table(tidy, file="./tidy.txt", row.names=FALSE)