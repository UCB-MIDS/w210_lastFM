copy (select a.userid, COALESCE(a.gender, 'NA'),
             COALESCE(CAST(a.age AS char(2)), 'NA') age, 
             COALESCE(a.country,'NA') country,
             a.startdate, 
             to_char(a.session_start, 'day') day_of_week,
             CASE WHEN a.timeofday = '1' THEN 'morning'
                  WHEN a.timeofday = '2' THEN 'noon'
                  WHEN a.timeofday = '3' THEN 'evening'
                  ELSE 'night'
             END timeofday,
             rank() OVER (PARTITION BY a.userid, a.session_start::date  ORDER BY session_start) sessionid,
             round(c.avgsession, 2) usrsession_avg, a.session_start, a.session_length
        from user_session_aggregated a, (select userid, avg(session_length) avgsession from user_session_aggregated group by userid) c
 where a.userid = c.userid
order by a.userid, a.session_start) to 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\lastfm-dataset-1K\usersessions-with-char-avg.csv' DELIMITER '|' CSV HEADER;
