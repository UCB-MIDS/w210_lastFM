## User Profiles

load_user_profiles.sql - Load data from userid-profile.tsv into the user_profiles table

## User Sessions
The final list of files to create the dataset with genre and other features is(to be run in following order) :

1.load_user_sessions_genre.sql - Uploads the raw file into the user_session_genre table
2.create_usrsession_intrmdt.sql - Creates an intermediate table from user_session_genre computing the intervals between 
                                  the tracks played
3.create_user_session_aggregated.sql - Create the structure for the user_session_aggregated table
4.load_user_sessions_aggregate.sql - Load the user_session_aggregated table with the aggregated session lengths computed 
                                     from the intervals in the intermediate table and the genres with the totals for 
                                     the session and join with user_profiles to get the user demographics
5.finaldataset.sql - Final dataset flat file from the data in the table
6.finaldataset-train.sql, finaldataset-test.sql - Split the final dataset into test and train 
                                                 (sessions after 03/31/2009 are in test dataset, all the rest in train) 
                                                 - only users with observations in both data sets are included
