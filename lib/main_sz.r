#### Main Script ###

################### Open data, functions and define directories paths  #########
library(randomForest)
library(caret)
library(topicmodels)
load(file.choose()) # Load lyr.Rdata
source(file.choose()) # helper.r
## Define data folder with h5 music features
train_data_path <- 
        '/Users/senzhuang/Documents/GitHub/Fall2016-proj4-sumc1992/data/data/'

######################## Topics Modeling #######################################
# Perform convertion from tokenized terms to single string
# Convert to matrix and prep for LDA
matx <- matrix_convert(string_convert(lyr), 'english')

# Perform LDA
lda20 <- LDA(matx, 20)

# Extract labels
music_label <- topics(lda20)

# Produce adjusted probability for terms
true_p20 <- adjust_prob(lyr, music_label)

#################### Features generation and Selection #########################
features <- features_gen(train_data_path)

############################# Classification ###################################
# Prep for classification
master_dset <- prep_csf(features$train_data_pca, music_label)

# Train and test split

set.seed(123)
train_sample<-sample(1:2340,2000)
music_feature_train <- master_dset$features[train_sample,]
music_label_train <- master_dset$label[train_sample]
music_feature_test <- master_dset$features[-train_sample,]
music_label_test <- master_dset$label[-train_sample]

# Fit model

# RF
music_rf<-randomForest(music_feature_train, music_label_train,importance=T,proximity=T)
music_rf_pre<-predict(music_rf,music_feature_test,type="vote",norm.votes=T)


################################ Ranking #######################################
rank_result <- rank_list(true_p20, music_rf_pre)
rank_result <- rbind(true_p20[,1],rank_result)
save.image("~/Desktop/p4_trainmodel.rdata")
