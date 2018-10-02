drop table user_profiles ;
create table user_profiles (userid varchar(20),
                            gender varchar(1),
                            age	integer,
                            country varchar(255),
                            registered date) ;


copy user_profiles from 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\lastfm-dataset-1K\userid-profile.tsv' with delimiter E'\t' null as '' format 'text'

select * from user_profiles ;