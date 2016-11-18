#### helper functions ####

# Load libraries
require(RTextTools)
require(topicmodels)
library(rhdf5)

# Manually adjusted probabilities for all terms
adjust_prob <- function(lyr, label) {
        new_lyr <- lyr[-237,]
        df <- cbind(label, new_lyr)
        result <- data.frame(matrix(seq(20), nrow = max(as.numeric(label)), ncol = 5000))
        for (lb in 1:max(as.numeric(label))) {
                holder <- subset(df, df[,1] == lb)
                holder <- colSums(holder[,3:5002])
                tot <- sum(holder)
                prop <- holder / tot
                result[lb,] <- prop
        }
        result <- t(result)
        result <- cbind(colnames(new_lyr)[2:5001], result)
        result <- result[-c(2,3,6:30),]
        return(result)
}

# Convert tokenized terms to single string
string_convert <- function(lyr) {
        result <- data.frame()
        for (row in 1:(nrow(lyr))) {
                words <- NULL
                for (col in 2:(ncol(lyr)-1)) {
                        if (lyr[row,col] != 0) {
                                kw <- rep(colnames(lyr)[col],lyr[row,col])
                                kw <- paste(kw, collapse=' ')
                                words <- paste(words, kw)
                        }
                }
                result[row,1] <- words
        }
        return(result)
}

# Convert strings to matrix
matrix_convert <- function(text_string, language) {
        text <- as.vector(text_string)
        matx <- create_matrix(text_string, language = language)
        rowTotals <- apply(matx , 1, sum)
        matx.new   <- matx[rowTotals> 0, ]
        return(matx.new)
}

# Define feature processing functions
feature_truncate_1d <- function(ls, len){
        if(length(ls) >= len){
                ls <- ls[1:len]
        }
        else{
                if(length(ls) == 0){
                        ls <- rep(0, len)
                }
                else{
                        t <- ceiling(len/length(ls))
                        ls <- rep(ls, t)
                        ls <- ls[1:len]
                }
        }
        return(ls)
}

feature_truncate_2d <- function(df, ncols){
        if(dim(df)[2] >= ncols){
                df <- df[,1:ncols]
        }
        else{
                if(dim(df)[2] == 0){
                        df <- matrix(rep(0, 12*ncols), 12, ncols)
                }
                else{
                        t <- ceiling(ncols/dim(df)[2])
                        df <- do.call("cbind", replicate(t, df, simplify = FALSE))
                        df <- df[,1:ncols]
                }
        }
        ls <- as.vector(t(df))
        return(ls)
}

# Generate, select/filter features from h5
features_gen <- function(h5_data_path) {
        setwd(h5_data_path)
        file_names <- list.files(recursive = T)
        file_num <- length(file_names)
        # see if songs have features with 0 dim
        for(i in 1:file_num){
                data <- h5read(file_names[i], "analysis")
                H5close()
        }
        ab_songs <- c(715, 950, 991, 1112, 1325, 1375, 1658, 1705, 2284)
        # Convert training data
        train_data1 <- data.frame(matrix(ncol = 1, nrow = 0))
        train_data2 <- data.frame(matrix(ncol = 22151, nrow = 0))
        n <- 1
        for(i in 1:file_num){
                if(! i %in% ab_songs){
                        data <- h5read(file_names[i], "analysis")
                        H5close()
                        song_id <- substring(file_names[i], nchar(file_names[i])-20, nchar(file_names[i])-3)
                        bars_s <- feature_truncate_1d(data$bars_start, 120)
                        beats_s <- feature_truncate_1d(data$beats_start, 446)
                        sections_s <- feature_truncate_1d(data$sections_start, 9)
                        segments_s <- feature_truncate_1d(data$segments_start, 744)
                        segments_l_m <- feature_truncate_1d(data$segments_loudness_max, 744)
                        segments_l_m_t <- feature_truncate_1d(data$segments_loudness_max_time, 744)
                        segments_l_s <- feature_truncate_1d(data$segments_loudness_start, 744)
                        segments_p <- feature_truncate_2d(data$segments_pitches, 744)
                        segments_t <- feature_truncate_2d(data$segments_timbre, 744)
                        tatums_s <- feature_truncate_1d(data$tatums_start, 744)
                        new_data_row <- c(bars_s, beats_s, sections_s, segments_s, segments_l_m, segments_l_m_t,
                                          segments_l_s, segments_p, segments_t, tatums_s)
                        train_data1[n,] <- song_id
                        train_data2[n,] <- new_data_row
                        n <- n+1
                }
        }
        for(i in 1:22151){
                if(sum(train_data2[,i]==train_data2[1,i])==2341){
                        print(i)
                }
        }
        ab_columns <- c(567, 576)
        train_data2 <- cbind(train_data2[,1:566], train_data2[,568:575], train_data2[,577:22151])
        train_data <- cbind(train_data1, train_data2)
        
        pca <- prcomp(train_data2, center=TRUE, scale=TRUE)
        cumdev <- cumsum(pca$sdev) / sum(pca$sdev)
        cumdev_0.9 <- cumdev <= 0.9
        n <- sum(cumdev_0.9) + 1
        pca_matrix <- pca$rotation[,1:n]
        train_data_pca <- as.matrix(train_data2) %*% pca_matrix
        train_data_pca <- cbind(train_data1, train_data_pca)
        result <- list('train_data_pca' = train_data_pca, 
                       'pca_matrix' = pca_matrix)
        return(result)
}

# Prep function for classification
prep_csf <- function(features, label) {
        label <- as.factor(label)
        features <- features[-237,] # Remove song 237 - not value-added
        features <- features[,-c(1,2)]
        label <- label[-c(714,949,990,1111,1324,1374,1657,1704,2283)]
        result <- list('features' = features, 'label' = label)
}

# View ranking result
rank_list <- function(adjusted_pp, predictions) {
        adjusted_pp <- t(matrix(as.numeric(unlist(true_p20[,-1])), nrow=nrow(true_p20[,-1])))
        predictions <- as.matrix(music_rf_pre[,1:20])
        result<- predictions %*% adjusted_pp
        for (i in 1:nrow(result)){
                result[i,]=rank(-result[i,])
        }
        return(result)
}
