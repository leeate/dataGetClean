###Tidy dataset of *Human Activity Recognition Using Smartphones Data Set*  


####For Coursera's Getting and Cleaning Data course.    
#####<br>This file describes each step in creating the tidy data set with "run_analysis.R". <br> Note that looking at the comments in the source code could also be very helpful - to be as clear as possible, this README even follows the numbering in it.      


#####Source data: Human Activity Recognition database built from the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors.    More info: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
<br>

#####Warning! Please use the read.table() function to read in the resulting dataset, with arguments '*rownames=FALSE*' and '*check.names=FALSE*' !
<br>

####Steps in creating the tidy dataset:

1. Reading in initial data
    * Nothing exciting about that. Test / train data are loaded into variables 'test' and 'train'.
2. Adding (common) variable names to each file
    * This is where things get interesting: the original dataset comes with common variable names for test/train. Because these varnames are short and descriptive (for those who know all this Physics stuff - I don't), I decided to keep them. They consist of several different parts, each of them are descriptive on its own: 
        * 'f' and 't' at the beginning of var names - the 'f' prefix means frequency domain signals, 't' means time domain signals
        * 'Body' and 'Gravity' - body or gravity acceleration / gyroscopic data
        * 'Acc' and 'Gyro' - acceleration or gyroscopic data
        * 'Jerk' - denotes if the current variable shows Jerk signals
        * 'Mag' - if variable name contains it, said variable shows magnitude data, calculated using the Euclidean norm
        * 'X', 'Y' or 'Z' at the end - shows which axis the variable belongs to (if any)
        * Each of these names also come with variables for the mean and standard deviation (marked with mean() or std() in the variable names) - these will be extracted in step 6.
    * It should be noted that these names came in an ordered format, meaning, there was an ordinal number (eg. "1. ") in front of each of them. These are also cleared in this step, using sapply(). 
    * Finally, they are added to the test / train variables. 
3. Adding Activity and Subject variables, which were stored in seperate files
    * The dataset contains identifiers for activities and subjects in a seperate file, for 'test' and 'train' each, so these need to be added before merging the two data. Subjects are simply a number from 0 to 30 for each person, activities range for 1 to 6. We'll deal with adding meaningful labels to them in a later step. For now, they are simply added as new variables to the test/train data.frame. 
4. Merging the two datsets
    * Test / train datasets are simply row-bound to each other, creating a new data.frame, creatively named 'data'. 
5. Replacing numbered activities with descriptive names, from "./activity_labels.txt". 
    * For now, the 'Activity' variable is only a numeric, ranging from 1 to 6. To make them descriptive, we'll have to 'label' the different values. 
    * As with the variable names described in step 2, activity labels come in a numbered format. As a first step, we remove the numbers.
    * Then we have R treat our 'Activity' variable as factor. We can pass activity labels to it as factor levels afterwards.
6. Extracting only the measurements on the mean and standard deviation.
    * We know that that averaged measurements' names have either 'mean' or 'std' in them (see step 2.). So we can use the grep() function on the name vector of the data.frame, which returns indices that are associated with either mean or std. 
    * Then we have R point to column numbers of the 'Activity' and 'Subject' variables (which we'll need for aggregation in the next step)
    * Then we subset on these indices, creating 'data2'.
7. Making the data tidy, using the aggregate() function, to make "Subject-Activity" combinations.
    * aggregate() is used for easily and quickly making summarized tables using grouping variables (the 'by' argument). We pass the 'data2' data.frame, our desired grouping variables(Subject, Activity) and the mean() function to aggregate(), then store the resulting table in a new data.frame, called 'tidy'. 
    * Because of how the aggregate() behaves, several additional steps are needed:
        * The old Activity and Subject variables are dropped. They now function as grouping variables in the first two columns, and they would give NA's if left in the dataset.
        * aggregate() has named our grouping variables "Group.1" and "Group.2" which is not really meaningful, so we change them to "Subject" and "Activity", to give their meaning back. 
        * Finally, we order the tidy datased based on "Subject". To do this, however, we first needed to change this variable to a numeric, because aggregate() made it a factor, and that would base sorting on alphabetical order (e.g. 1,10,100 instead of 1,2,3...)
8. As a latest step, we write our tidy dataset to a text file. 