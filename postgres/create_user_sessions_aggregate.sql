drop table user_session_aggregated ;
create table user_session_aggregated (userid varchar(50), 
                                      session_start timestamp, 
                                      day_of_week integer,
                                      time_of_day integer,
                                      session_id integer, 
                                      session_length integer, 
                                      gender integer, 
                                      age integer, 
                                      country integer,
                                      genre text) ;