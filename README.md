# GettingCleaningData-CourseProject
Work done for GettingCleaningData CourseProject - June2015

**Introduction**
Here we are explaining what the the script Run_analysis.R does in technical details regarding the UCI HAR original raw Dataset. In terms of practice, this generates a tidy data text file that meets the principles that follows:
* each variable measured  is in one column,
* each different observation of each variable is in a different row,
* the tidy dataset contains some measures relative on one specific tests which is based on Samsung smartphones where 30 different subjects wear a smartphone that captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. 

**Details on output**
Finally, the tidy dataset contains observations according to rules explicited by Hadley Whickham's paper (http://vita.had.co.nz/papers/tidy-data.pdf), all columns contains header with explicit names that are defined in the CodeBook.md, there is no duplicate columns.
At the end, we have a tidy data set of 180 rows , 68 columns.

**Note**
We kept some standard deviation and mean measurements in the tidy dataset , exclusing those with names like MeanFreq and gravityMean because those ones are not measurements that comes from calculation on the mean or std. Indeed, these measurements are based on a mean frequence and mean gravity. We removed also measurements with "angle" that are measureing angle between vectors and are not part of a tidy data for measurements.
		
**SCRIPT**		
For this course project, we have done a Run_analysis.R file that contains:
- 5 steps functions named Step1_Merge(), Step2_Extract(df_from_step1_function), Step3_NameActivity(df_from_step2_function), Step4_DescriptiveVariableNames(df_from_step3_function), Step5_IndependentTidyData(df_from_step4_function).

- A global function named run_analysis that does the calls of each steps function describes above.

The function run_analysis is the function to call to get the getting and cleaning data stuff done. One **prerequisite** is that the folder "UCI HAR Dataset" is expanded under your R working directory.

For this project, I have considered two data sets to load:
\\UCI HAR Dataset\\train\\X_train.txt
\\UCI HAR Dataset\\test\\X_test.txt

I have ignored the datasets under Inertial folders as it was indicated in David's personal course project FAQ
(https://class.coursera.org/getdata-015/forum/thread?thread_id=26).

**Please pay attention that we require here package dplyr.
Please do first install.packages("dplyr")**

I mostly followed the 5 steps but with some personal amendments as it was possible to do.
	Description:
	
		- in **step1** function, I have loaded the following datasets in dataframes:
				# ".\\UCI HAR Dataset\\features.txt"
				# ".\\UCI HAR Dataset\\test\\X_test.txt"
				# ".\\UCI HAR Dataset\\test\\subject_test.txt"
				# ".\\UCI HAR Dataset\\test\\y_test.txt"
				# ".\\UCI HAR Dataset\\train\\X_train.txt"
				# ".\\UCI HAR Dataset\\train\\subject_train.txt
				# ".\\UCI HAR Dataset\\train\\y_train.txt"

then bind subject_train.txt, y_train.txt and X_train.txt by rows into a dataframe 1, 
then bind subject_test.txt, y_test.txt and X_test.txt by rows into a dataframe 2. Then i merged the two dataframe using rbind.
Note that I did name the measures columns in this step 1 with the FEATURES DATA SET. I did that here because it is very convenient to have the labels here to use them in step 2.

		- in **step2** function, the goal is to extract "only the measurements on the mean and standard deviation for each measurement". 
		So we had a look to all measurements with words like std and mean. 
		It appears that some of them are MeanFreq and gravityMean and those ones are not measurements 
		on the mean or std but measurements based on a mean frequence and mean gravity, 
		which is different and explains why i decided to exclude them from datasets. 
		Then, I have extract all other mesurement with Mean and std via dplyr:select function 
		that is really easy to use with sub-function contains. 
		For this, I had to make current names as valid names for select using function make.names. 
		This function change some characters such as (,)- in .

		- **Step 3**: we have merged the activity_labels file with my step2 dataset through the ids using merge function.
		
		- **Step 4** : as the column were already named in step 1 but modified by make.names, 
		we needed to clear a bit those names. For that, I have replaced the .. or ... in the names by .
		At the end, the column names are clear and in accordance with rules of tidy data. 
		More information to be read in the code book.

		- **Step 5** :We use here a group_by with a summarize_each column function using  mean function.
			Then we update the name of the columns with prefix AVGGrouped_ for Average grouped by.

To **run the script**, here are the following steps:
 - in **your R work folder**, expand the UCI HAR Dataset
 - copy the script in the working directory
 - in R console type: install.packages("dplyr")
 - then source("run_analysis.R")
 - then runDF<-run_analysis()
 - the data are in runDF.

