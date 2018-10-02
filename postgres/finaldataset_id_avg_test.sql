copy (select a.userid, CASE WHEN a.gender = 'm' THEN '1' WHEN a.gender = 'f' THEN '0' ELSE 'NA' END gender ,
             COALESCE(CAST(a.age AS char(2)), 'NA') age, 
             b.countryid country, 
             a.startdate, 
             extract(DOW from a.session_start) day_of_week,
             a.timeofday,
             rank() OVER (PARTITION BY a.userid, a.session_start::date  ORDER BY session_start) sessionid,
             round(c.avgsession, 2), a.session_start, a.session_length
        from user_session_aggregated a, country b, (select userid, avg(session_length) avgsession from user_session_aggregated group by userid) c
 where a.session_start > '04/01/2009' and
       a.userid = c.userid and
       COALESCE(a.country, 'NA') = COALESCE(b.countryname, 'NA') and
       exists (select 1 from user_session_aggregated where userid = a.userid and session_start < '03/31/2009')
order by a.userid, a.session_start) to 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\lastfm-dataset-1K\usersessions-with-id-avg-test.csv' DELIMITER '|' CSV HEADER;
