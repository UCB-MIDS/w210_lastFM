## User Session Length prediction in streaming media


We used the last.fm 1K dataset and to predict the user session length using ML, Deep Learning and Panel data techniques and compare them with the state of the art models published in the following papers:




### Repository details

 This repository has been divided into the following sections:
 
- ETL scripts imports data from session and user data from lastFM as well as TimeZone information from timeandupdate.com (used to adjust UTC to local time). Scripts also join session data with timezone data.
- https://github.com/UCB-MIDS/w210_lastFM/blob/master/Classification/Session%20Length%20Prediction%20ETL1_ImportFiles_addTimeZoneInfo.ipynb

- ETL scripts import holiday data for each of the countries and genre data for each of the tracks in the session data. Scripts also join Holiday and Genre data with session data.
- https://github.com/UCB-MIDS/w210_lastFM/blob/master/Classification/Session%20Length%20Prediction_ETL2_add_HolidayAndGenre_Sessionize.ipynb

- ML scripts to build decile classifiers. Log of session length is bucketized into deciles. A number of multinormial classification models are evaluated against accuracy (WORK IN PROGRESS)
- https://github.com/UCB-MIDS/w210_lastFM/blob/master/Classification/Session%20Length%20Prediction_EDA%20and%20Classification.ipynb


### Tools

The feature engineering has been done with 
- Pyspark: ETL and feature engineering
- MLlib:   Classification
