# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Name: Sen Zhuang (sz2536)
+ Projec title: Words 4 Music
+ Project summary:
In this project, I examinated music qualities/features and frequencies of terms in lyrics in hope of building a predictive model to produce a ranking for terms (How frequently do we expect certain words to appear?)

## Where to find my scripts
```
proj/
├── lib/main_sz.r
```
main_sz.r includes detailed used packages and functions to build predictive models.

```
proj/
├── lib/helper.r
```
Special functions used in main script to prep, transform and format data for modeling, prediction and submission purporses.

## Examplation of user-defined functions in helper.r
### 1. string_convert
Use: Convert tokenized terms to single strings for matrix conversion.
Example:
Terms: a, b, d
Tokenized frequencies: 2, 1, 1

After conversion: 'a a b d'

### 2. adjust_prob
Use: Recalculated probability for every single terms. (When performing topics modeling, I remove frequently used words, punctations and numbers. But these values are included in project evaluation. This is a step to bring those values back.)

### 3. matrix_convert
Use: Convert strings to matrix and remove frequently used words, numbers and puncutaions.

### 4. feature_truncate_1d, feature_truncate_2d
Use: Assist feature generation; Used by feature_gen function

### 5. features_gen
Use: Generate, select/filter features from h5

### 6. prep_csf
Use: Preparing dataset for classification; Split into train and test for validation.

### 7. rank_list
Use: Produce ranked list of terms for project submission

### 8. test_features_gen
Use: Extract features from test set and apply pca model to test set.

## Topics Modeling
Tokenized terms are first converted to single strings for text preping and matrix creation. Frequenly used terms, numbers and punctuations are removed for topic modeling / LDA process. Here number of topics is set to 20.
Once cooresponding probabilities for each song are produced, I then manually recalculated probabilities for terms so we account for frequenly used terms, numbers and punctuations when making final predictions.

## Feature Extraction 
Music features from H5 are extracted with examination of missing values, abnormalites and information usefullness in mind.

## Modeling / Testing
In predictive modeling part, I tested various machine learning models such as random forest, knn, cart and naive bayes. Based on accuracy and efficiency, I decided to pursue random forest modeling.

## Result
