drop table if exists user_session_aggregated_full ;
create table user_session_aggregated_full (userid varchar(50), 
                                      session_start timestamp, 
                                      day_of_week integer,
                                      time_of_day integer,
                                      session_id integer, 
                                      session_length integer, 
                                      session_count integer,
                                      absence_time integer,
                                      gender integer, 
                                      age integer, 
                                      country integer,
                                      genre text) ;