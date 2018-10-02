copy (select a.userid ,COALESCE(a.gender, 'NA') gender ,COALESCE(CAST(a.age AS char(2)), 'NA') age, COALESCE(a.country, 'NA') country, a.startdate, 
       extract(DOW from a.session_start) day_of_week,
       a.timeofday,
       rank() OVER (PARTITION BY a.userid, a.session_start::date  ORDER BY session_start) sessionid,
       round(avg(session_length) OVER (PARTITION BY (a.userid, a.timeofday) ORDER BY session_start ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),2) session_length_mvavg,
       a.session_start, a.session_length
 from user_session_aggregated a
 where a.session_start < '03/31/2009' 
   --and exists (select 1 from user_session_aggregated where userid = a.userid and session_start < '03/31/2009')
order by a.userid, a.session_start) to 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\lastfm-dataset-1K\usersessions-with-char-sec-train.csv' DELIMITER '|' CSV HEADER;
