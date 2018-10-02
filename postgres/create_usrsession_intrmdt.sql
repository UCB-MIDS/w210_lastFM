drop table if exists usrsession_intrmdt ;
create table usrsession_intrmdt as
select userid, starttime, starttime::date startdate, 
       case when date_part('hour', starttime) between 6 and 12 then '1'
            when date_part('hour', starttime) between 12 and 17 then '2'
            when date_part('hour', starttime) between 17 and 22 then '3'
            else '4'
       end timeofday,
       lag(starttime,1) over (partition by userid order by userid, starttime) as  prevstart,
       starttime-lag(starttime,1) over (partition by userid order by userid, starttime) as  delta
from user_sessions 
order by userid, starttime ;
