copy (select a.userid, COALESCE(a.gender, 'NA'),
             COALESCE(CAST(a.age AS char(2)), 'NA') age, 
             COALESCE(a.country,'NA') country,
             a.startdate, 
             extract(DOW from a.session_start) day_of_week,
             a.timeofday,
             rank() OVER (PARTITION BY a.userid, a.session_start::date  ORDER BY session_start) sessionid,
             round(c.avgsession, 2), a.session_start, a.session_length
        from user_session_aggregated a, (select userid, avg(session_length) avgsession from user_session_aggregated group by userid) c
 where a.session_start > '04/01/2009' and
       a.userid = c.userid and
       exists (select 1 from user_session_aggregated where userid = a.userid and session_start < '03/31/2009')
order by a.userid, a.session_start) to 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\lastfm-dataset-1K\usersessions-with-char-avg-test.csv' DELIMITER '|' CSV HEADER;
