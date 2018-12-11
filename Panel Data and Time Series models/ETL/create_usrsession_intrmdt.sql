drop table usrsession_intrmdt ;
create table usrsession_intrmdt as
select userid, session_start, session_dt, 
       time_of_day,
       day_of_week,
       lag(session_start,1) over (partition by userid order by userid, session_start) as  prevstart,
       session_start-lag(session_start,1) over (partition by userid order by userid, session_start) as  delta,
       genre_1,
       genre_2,
       genre_3
from user_session_genre 
order by userid, session_start ;

