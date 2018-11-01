drop  extension file_fdw cascade;
create extension file_fdw;
create server my_csv foreign data wrapper file_fdw;
drop foreign table if exists user_session_full ;

create foreign table user_session_full (
                                 userid varchar(20), 
                                 reg_date  date, 
                                 genre_1    text,
                                 genre_2   text, 
                                 genre_3    text, 
                                 local_time text,
                                 is_holiday char(1)
) server my_csv
options (filename 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\datasets\usersessiongenre.csv', format 'csv', delimiter '|', header 'true')
;

drop table user_session_genre ;
create table user_session_genre as select userid, to_timestamp(local_time, 'YYYY-MM-DD hh24:mi:ss')::timestamp without time zone at time zone 'Etc/UTC'
 session_start, to_date(local_time, 'YYYY-MM-DD') session_dt, 
                                          CASE WHEN extract(hour from to_timestamp(local_time, 'YYYY-MM-DD hh24:mi:ss')::timestamp without time zone at time zone 'Etc/UTC') between 5 and 12 THEN 1
                                               WHEN extract(hour from to_timestamp(local_time, 'YYYY-MM-DD hh24:mi:ss')::timestamp without time zone at time zone 'Etc/UTC') between 12 and 17 THEN 2
                                               WHEN extract(hour from to_timestamp(local_time, 'YYYY-MM-DD hh24:mi:ss')::timestamp without time zone at time zone 'Etc/UTC') between 17 and 22 THEN 3
                                               ELSE 4
                                          END time_of_day, 
                                          extract(DOW from to_date(local_time, '%Y-%m-%d')) day_of_week, genre_1, genre_2, genre_3 
                                     from user_session_full ;

