copy (select a.userid ,a.gender genderid, CASE WHEN a.gender = 1 then 'm' WHEN a.gender = 0 then 'f' ELSE 'NA' END gender ,
     COALESCE(CAST(a.age AS char(2)), 'NA') age, COALESCE(b.countryname, 'NA') country, a.session_start::date session_dt, 
       a.day_of_week day_of_week_id,
       CASE WHEN a.day_of_week = 0 THEN 'Sunday'
            WHEN a.day_of_week = 1 THEN 'Monday'
            WHEN a.day_of_week = 2 THEN 'Tuesday'
            WHEN a.day_of_week = 3 THEN 'Wednesday'
            WHEN a.day_of_week = 4 THEN 'Thursday'
            WHEN a.day_of_week = 5 THEN 'Friday'
            WHEN a.day_of_week = 6 THEN 'Saturday'
        ELSE 'NA' end day_of_week,
       CASE WHEN extract(hour from  a.session_start) between 5 and 12 THEN 1
            WHEN extract(hour from  a.session_start) between 12 and 17 THEN 2
            WHEN extract(hour from  a.session_start) between 17 and 22 THEN 3
        ELSE 4 END time_of_day_id,
       CASE WHEN extract(hour from  a.session_start) between 5 and 12 THEN 'Morning'
            WHEN extract(hour from  a.session_start) between 12 and 17 THEN 'Afternoon'
            WHEN extract(hour from  a.session_start) between 17 and 22 THEN 'Evening'
        ELSE 'Night' END time_of_day_id,
       rank() OVER (PARTITION BY a.userid, a.session_start::date  ORDER BY session_start) sessionid,
       round(avg(session_length) OVER (PARTITION BY (a.userid) ORDER BY session_start ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),2) session_length_mvavg,
       round(avg(session_length) OVER (PARTITION BY (a.userid) ORDER BY session_start ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING),2) session_length_mvavg_10,
       round(avg(session_length) OVER (PARTITION BY (a.userid) ORDER BY session_start ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING),2) session_length_mvavg_5,
       round(avg(session_length) OVER (PARTITION BY (a.userid, a.time_of_day) ORDER BY session_start ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING),2) session_length_mvavg_time,
       a.session_start, a.session_length, 
       LAG(a.session_length, 1) OVER (PARTITION BY a.userid ORDER BY a.session_start ) previous_duration,
       EXTRACT(EPOCH from (a.session_start - LAG(a.session_start, 1) OVER (PARTITION BY a.userid ORDER BY a.session_start))) absence_time,
       ch.is_holiday, a.genre
 from user_session_aggregated a
 LEFT OUTER JOIN country b ON b.countryid = a.country
 LEFT OUTER JOIN country_holidays ch ON a.session_start::date = ch.hol_dt AND (lower(b.countryname) in (ch.country, ch.raw_country) OR lower(b.countryname) like ch.country||'%')
  where a.session_start > to_timestamp('03/31/2009 23:59', 'MM/DD/YYYY HH24:MI:SS')
    and exists (select 1 from user_session_aggregated where userid = a.userid and session_start < to_timestamp('03/31/2009 23:59', 'MM/DD/YYYY HH24:MI:SS'))
order by a.userid, a.session_start) to 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\datasets\usersessions-with-genre-test.csv' DELIMITER '|' CSV HEADER;

