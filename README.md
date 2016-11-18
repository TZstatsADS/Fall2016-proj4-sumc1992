# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: Sen Zhuang (sz2536)
+ Projec title: Words 4 Music
+ Project summary:
In this project, I examinated music qualities/features and frequencies of terms in lyrics in hope of building a predictive model to produce a ranking for terms in lyrics. 

## Topics Modeling
Tokenized terms are first converted to single strings for text preping and matrix creation. Frequenly used terms, numbers and punctuations are removed for topic modeling / LDA process. Here number of topics is set to 20.
Once cooresponding probabilities for each song are produced, I then manually recalculated probabilities for terms so we account for frequenly used terms, numbers and punctuations when making final predictions.

## Feature Extraction 
Music features from H5 are extracted with examination of missing values, abnormalites and information usefullness in mind.

## Modeling / Testing
In predictive modeling part, I tested various machine learning models such as random forest, knn, cart and naive bayes. Based on accuracy and efficiency, I decided to pursue random forest modeling.

## Result

	
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
