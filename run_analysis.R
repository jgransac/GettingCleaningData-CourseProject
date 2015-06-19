###source("run_analysis2.R")
install.packages("dplyr")
library(dplyr)

gt_labelActivity<-function(a_file)
{
  ## load activity labels ids
  label<-read.table(a_file, sep="")
  ## give a col name
  names(label)<-c("label_id")
  label
}

## this function is getting the input files from working dir and does the merge to get one table 
## by merging subjetcs, label activity id, and X_train X_test datasets together
## no input arguments as we are supposing the names of sources to be stable
Step1_Merge<-function() 
{
  
  
  
  
  ## load features
  features<-read.table(".\\UCI HAR Dataset\\features.txt", sep="")
  
  
  ### TEST dataset part
  ## load X_test datasets 
  Xtest<-read.table(".\\UCI HAR Dataset\\test\\X_test.txt", sep="")
  
  ## give columns names - this is PART OF STEP4. Descriptive variable is partly done here be able to use dply::select function in step 2
  names(Xtest)<-features[,2]
  
  ## load subjects
  subject_test<-read.table(".\\UCI HAR Dataset\\test\\subject_test.txt", sep="")
  ## give a col name
  names(subject_test)<-c("subject")
  
  ## load activity labels ids for test: "y_test.txt"
  test_label<-gt_labelActivity(".\\UCI HAR Dataset\\test\\y_test.txt")

  
  ## BIND THE THREE TABLES TO GET ONE CALLED X_test
  X_test<-bind_cols(subject_test, test_label,Xtest)
  
  #######################################
  ### TRAIN dataset part
  ## load X_train datasets 
  Xtrain<-read.table(".\\UCI HAR Dataset\\train\\X_train.txt", sep="")
  
  ## give columns names
  names(Xtrain)<-features[,2]
  
  ## load subjects
  subject_train<-read.table(".\\UCI HAR Dataset\\train\\subject_train.txt", sep="")
  ## give a col name
  names(subject_train)<-c("subject")
 
  ## load activity labels ids for train dataset: "y_train.txt"
  train_label<-gt_labelActivity(".\\UCI HAR Dataset\\train\\y_train.txt")


  X_train<-bind_cols(subject_train, train_label,Xtrain)
  
  #########
  ## Bind by rows to get step 1 Ok
  X_merged_data<-rbind(X_test, X_train)
  
  ## final Step 1 datasets
  X_merged_data
  
}

## STep 2 
## Selecting columns: the goal is to extract a dataset from X_MergedData with only label activity, subject and all std and mean measures 
Step2_Extract<-function(a_dfXMergedData)
{
  ## select() from dplyr is a good function for that.
  ## However the column names in XMergedData contains not accepted characters such as "-"   "("   ")"   ","
  ## To be able to do the select, we need to transform first the columns names in acceptable names
  ## for that I use make.names with keeping all columns names UNIQUE
  ## make.names modifies columns names by replacing unauthorized character by "."
  ## Which is good because it does not depreciate the names of columns, they are still understandable.
  ## Example: "tBodyAccJerk-arCoeff()-Y,3" turns to "tBodyAccJerk.arCoeff...Y.3"
  valid_column_names <- make.names(names=names(a_dfXMergedData), unique=TRUE, allow_ = TRUE)
  names(a_dfXMergedData)<-valid_column_names
  XExtractedDataWith_mean_std_Measures<-select(a_dfXMergedData, c(subject,label_id),contains("mean"), contains("std"), -contains("meanFreq"), -contains("gravityMean"))
##  XExtractedDataWith_mean_std_Measures<-select(a_dfXMergedData, c(subject,label_id),contains("mean"), contains("std"), -contains("meanFreq"))
  XExtractedDataWith_mean_std_Measures
}

## STEP 3
## Uses descriptive activity names to name the activities in the data set
## OBJECT: joining the activityId in the XMergedData set with dataset activity_labels.txt 
## and keep just the label : WALKING, LAYING etc.. as activity
Step3_NameActivity<-function(a_dfXMergedData)
{
  ## load activity
  activity<-read.table(".\\UCI HAR Dataset\\activity_labels.txt",  sep="")
  names(activity)<-c("id", "activity")
  
  ## join dataFrame XMergedData with activity_labels
  XMergedDataLabeled<-merge(activity, a_dfXMergedData, by.x="id", by.y="label_id",  all=TRUE, sort=FALSE)

  ## then remove the unuseful column "id" (label id)
  
  XMergedDataLabeled<-select(XMergedDataLabeled, -id)
  
  ## this operation could have been done on step 1 using Merge
  ## HOWEVER MERGE IS BY DEFAULT ORDERING DATA SETS THAT ARE JOINED
  ## TO AVOID THAT , use sort=FALSE ...
  ## this tip is useful only if we join on step one, using y_train/y_test joined with activity_label
  XMergedDataLabeled
}

## STEP 4 
## Appropriately labels the data set with descriptive variable names
## COMMENTS to the reader:
## This is has been partially done in STEP1 : Descriptive variable is partly done in step 1 be able to use dply::select function in step 2
## However using dply::select implies to have valid columns names which turned them in poorly descriptive as original
## let us clean that here
Step4_DescriptiveVariableNames<-function(a_dfXLabeledMergedData)
{
  ## considering that the features have been joined in step1 to name variables properly,
  ## considering that those variables names have been modified in step2 in order to use dplyr::select (characters such as '-'  '('  ')'  ',' have been replaced by character "."
  ## so we have some variables names containing string like "..." or ".." that we can remove.
  ## I consider that I have to clear the multiple '...' or '..' from variables names and replace them by '.' as it respects the R naming columns convention
  ## EXAMPLE:
  ## "tBodyGyro-mean()-X   has been changed in step 2 by    "tBodyGyro.mean...X"
  ## and will be replaced by "tBodyGyro.mean.X" which is good to read.
  description<-names(a_dfXLabeledMergedData)
  description<-gsub("...","",description, fixed=TRUE)
  description<-gsub("..",".",description, fixed=TRUE)
  names(a_dfXLabeledMergedData)<-description
  a_dfXLabeledMergedData
}

## STEP 5 
## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## COMMENTS to the reader:
## This is has been partially done in STEP1 : Descriptive variable is partly done in step 1 be able to use dply::select function in step 2
## However using dply::select implies to have valid columns names which turned them in poorly descriptive as original
## let us clean that here
Step5_DescriptiveVariableNames<-function(a_dfXLabeledMergedData)
{
## considering that the features have been joined in step1 to name variables properly,
## considering that those variables names have been modified in step2 in order to use dplyr::select (characters such as '-'  '('  ')'  ',' have been replaced by character "."
## so we have some variables names containing string like "..." or ".." that we can remove.
## I consider that I have to clear the multiple '...' or '..' from variables names and replace them by '.' as it respects the R naming columns convention
## EXAMPLE:
## "tBodyGyro-mean()-X   has been changed in step 2 by    "tBodyGyro.mean...X"
## and will be replaced by "tBodyGyro.mean.X" which is good to read.

  finalDF<-a_dfXLabeledMergedData %>% group_by(subject,activity) %>% summarise_each(funs(mean))
  finalDF
}

######## THE FUNCTION TO CALL THAT IS CALLING ALL STEPS FUNCTIONS

run_analysis<-function()
{
  run<-Step1_Merge() %>%  Step2_Extract() %>% Step3_NameActivity () %>% Step4_DescriptiveVariableNames() %>%  Step5_DescriptiveVariableNames()
  description<-names(run)
  
  ## then we update the variables names that indicate that this is an average calculation based on a grouping
  description<-paste("AVG_Grouping_", description, sep="")
  description[1]<-c("subject")
  description[2]<-c("activity")
  names(run)<-description
  run
}