drop table user_sessions ;
create table user_sessions (userid varchar(20),
                            starttime timestamp ) ;


copy user_sessions from 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\lastfm-dataset-1K\usrsession.tsv' with (format csv, delimiter E'\t', null '') ;

