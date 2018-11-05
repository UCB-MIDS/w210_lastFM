# User Session Length prediction in streaming media


We uset the last.fm 1K dataset and try to predict the user session length using ML, Deep Learning and Panel data techniques and compare them with the state of the art models published in the following papers:

- [Audio Ad Quality Prediction]( https://arxiv.org/pdf/1802.03319.pdf)
- [Predicting Session Length in Media Streaming](https://arxiv.org/pdf/1708.00130.pdf)
- [Hierarchical Modeling and Shrinkage for User Session Length Prediction in Media Streaming](https://arxiv.org/pdf/1803.01440.pdf)


## Repository details

 This repository has been divided into the following sections:
 - [R Model Files](https://github.com/UCB-MIDS/w210_lastFM/tree/master/R%20Model%20Files)           : Analysis in R for Panel Data models(completed), Continuous Time model, Dynamic Linear models, Non-Linear Mixed Effects models(In progress)
 - [classifier](https://github.com/UCB-MIDS/w210_lastFM/tree/master/classifier)                     : TBD
 - [postgres](https://github.com/UCB-MIDS/w210_lastFM/tree/master/postgres)                         : Feature engineering in SQL to extract the session lengths and other features from the raw data files
 - [sequence_to_sequence](https://github.com/UCB-MIDS/w210_lastFM/tree/master/sequence_to_sequence) : This section contains analysis done using various sequence to sequence deep learning techniques.



The feature engineering has been done with 
- pyspark - Deep Learning models
- Postgres - R Panel data models
- Postgres + pyspark - ML models
