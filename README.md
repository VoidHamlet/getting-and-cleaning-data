Getting and Cleaning Data: A Coursera Project
=============================================

Introduction
------------
This repository stores my course work on the Data Science Coursera module, "Getting and Cleaning data".

Raw Data
------------------
The following items are available:

Unlabeled features (561) contained in X_test.txt, X_train.txt. 
Activity labels contained in files y_test.txt, y_train.txt.
Test subjects contained in file subject_test.txt, subject_train.txt.

Script and Tidy Data Set
-------------------------------------
The run_analysis.R in this repository combines the test and training data sets, adds labels and filters columns involving mean and standard deviations.

The script also produces a tidy data set featuring the means of all the columns per test subject & activity.
The resulting TidyAverageSubset.txt is included in the repository.

Note: In order for the script initialization to be successful, the data must be extracted from the archive to your working directory.

Code Book
-------------------
The uploaded CodeBook.md file outlines the task execution.
