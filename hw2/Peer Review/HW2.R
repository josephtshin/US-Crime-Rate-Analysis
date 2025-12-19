rm(list = ls())

card_data <- read.table("credit_card_data-headers copy 2.txt", header = TRUE)

# Question 3.1 
# Using the same data set (credit_card_data.txt or credit_card_data-headers.txt) 
# as in Question 2.2, use the ksvm or kknn function to find a good classifier:
# (a) using cross-validation (do this for the k-nearest-neighbors model; SVM 
#     is optional); and
# (b) splitting the data into training, validation, and test data sets (pick 
#     either KNN or SVM; the other is optional).

library(kknn)
library(kernlab)
library(carat)
library(caret)
library(e1071)
library(ggplot2)
library(MLmetrics)
# data exploration
summary(card_data)
head(card_data)
tail(card_data)


################### 3.1.a ###################
#split the data into training and test data sets (75/25 split)
smp_size <- floor(0.75 * nrow(card_data))

## set the seed 
set.seed(97)

### here I'm attempting to use cross-validation knn model
cv_knn_model <- cv.kknn((R1)~., 
                        card_data, 
                        k = 10, #default value is 10
                        distance = 2, #default Minkowski distance metric is 2
                        kernel = "rectangular", 
                        ykernel = NULL, 
                        scale = TRUE)

print(cv_knn_model)
# results:
# mean absolute error = 0.2051114
# mean squared error = 0.1152406

### here I'm attempting to use cross-validation svm model
#define the control function for cv using trainControl function
custom_control <- trainControl(
  method = "cv",       # select Cross-validation method
  number = 5,          # select Number of folds
  verboseIter = TRUE,  # select option to output the progress
  savePredictions = "final", 
  classProbs = TRUE,   # select to estimate class probabilities
  summaryFunction = multiClassSummary #select to use for multi-class classification
)

# set up, train and evaluate svm model

#-- convert V11 to a categorical variable with alternative labels to help svm model run
card_data$R1 = factor(card_data$R1, levels = c('0', '1'), labels = c("Deny", "Accept"))

cv_svm_model <- train(
  (R1)~. ,            # Formula for the model
  data = card_data,            # Data to be used
  method = "svmRadial",   # SVM with radial basis function kernel
  trControl = custom_control,
  tuneLength = 10         # Tune over 10 different parameter values
)
print(cv_svm_model)

plot(cv_svm_model)

################### 3.1.b ###################
# now we will split the data sets and rety each of the models 
# clear env vars
rm(list=ls())

# call kernlab for ksvm
library(kernlab)
card_data <- read.table("/Users/sirichandana/Desktop/OMSA/ISYE6501/Homework2_ISYE6501/data 3.1/credit_card_data.txt", stringsAsFactors = FALSE, header = FALSE)

#split the data 70/30 for train/test
split <- 0.7 
train_test_mask <- sample(nrow(card_data), size=round(nrow(card_data)*split))
train_set <- card_data[train_test_mask,] 
remainder_set <- card_data[-train_test_mask,]

# From the test set we'll split into train and val
validation_test_split <- 0.5
validation_test_mask <- sample(nrow(remainder_set), size=round(nrow(remainder_set)*validation_test_split))
validation_set <- remainder_set[validation_test_mask,]
test_set <- remainder_set[-validation_test_mask,]

# now we will run a knn model
ttv_kknn_model= kknn(R1~.,
                     train_set,
                     test_set,
                     k=10, #default
                     kernel = "optimal", 
                     ykernel = NULL, 
                     scale = TRUE)

print(ttv_kknn_model)
predicted_test<- rep(0,(nrow(test_set)))
test_accuracy<- sum(predicted_test == test_set[,11]) / nrow(test_set)
test_accuracy

# ################### 4.2 ###################
# The iris data set iris.txt contains 150 data points, each with four predictor 
# variables and one categorical response. The predictors are the width and length
# of the sepal and petal of flowers and the response is the type of flower. The 
# data is available from the R library datasets and can be accessed with iris 
# once the library is loaded. It is also available at the UCI Machine Learning 
# Repository (https://archive.ics.uci.edu/ml/datasets/Iris ). The response values 
# are only given to see how well a specific method performed and should not be 
# used to build the model.
# 
# Use the R function kmeans to cluster the points as well as possible. Report 
# the best combination of predictors, your suggested value of k, and how well 
# your best clustering predicts flower type.

rm(list = ls())

#load iris data set
library(datasets)
data(iris)

head(iris)

#deploy elbow method to find ideal number of clusters
library(kknn)
library(dplyr)
library('factoextra')

mapping<- c("setosa"=1,"versicolor"=2,"virginica"=3) #rename categories to numerical
iris$Species<- mapping[iris$Species]

#remove species column
filtered_iris<-iris[,1:4]

#Set seed
set.seed(123)

# plot
fviz_nbclust(filtered_iris, kmeans, method ="wss")
#### the bend/elbow occurs around k=3 which is the optimal number of clusters

### deploy kmeans with 3 clusters but varying predictors
iris_cluster_1 = kmeans(iris[,1:2], 
                        3, 
                        nstart = 20)
iris_cluster_2 = kmeans(iris[,2:3], 
                        3, 
                        nstart = 20)
iris_cluster_3 = kmeans(iris[,3:4], 
                        3, 
                        nstart = 20)
iris_cluster_4 = kmeans(iris[,1:4], 
                        3, 
                        nstart = 20)
iris_cluster_5 = kmeans(iris[,1:3], 
                        3, 
                        nstart = 20)
iris_cluster_6 = kmeans(iris[,2:4], 
                        3, 
                        nstart = 20)


table(iris_cluster_1$cluster, iris$Species)
table(iris_cluster_2$cluster, iris$Species)
table(iris_cluster_3$cluster, iris$Species)
table(iris_cluster_4$cluster, iris$Species)
table(iris_cluster_5$cluster, iris$Species)
table(iris_cluster_6$cluster, iris$Species)



iris_cluster_1 #71.6%
iris_cluster_2 #91.7%
iris_cluster_3 #94.3%
iris_cluster_4 #88.4%
iris_cluster_5 #88.3%
iris_cluster_6 #91.7%

# cluster 3 had highest percentage correct with 94.3% and included only columns 
# petal length & petal width with 3 clusters so those are the most important

iris





