DO 
$$DECLARE
 usr RECORD;
 sess RECORD;
 session_id INTEGER ;
 session_length INTEGER ;
 session_start TIMESTAMP ;
 gender integer ;

BEGIN
 FOR usr in (SELECT * FROM user_profiles) LOOP
      session_id := 1 ;
      session_length := 0 ;
      session_start := NULL ;
      FOR sess IN ( SELECT *, extract(day from delta)*86400 + extract(hour from delta)*3600+ extract(minute from delta)*60 + extract(second from delta) intrvl FROM usrsession_intrmdt 
                     WHERE userid = usr.userid order by starttime ) LOOP
          IF sess.delta IS NULL THEN 
               session_start := sess.starttime ;
          END IF ;
          IF sess.intrvl > 43200 THEN
             RAISE NOTICE 'Interval %', sess.intrvl ;
          END IF ;
          
          IF COALESCE(sess.intrvl, 0) < 1800 THEN
             session_length := session_length + COALESCE(sess.intrvl, 0) ; 
          ELSE
              IF session_length between 180 and 43200 THEN
                INSERT INTO user_session_aggregated
                         (userid, session_start, startdate, timeofday, session_id, session_length, gender, age, country )
                   VALUES
                         (sess.userid, session_start, session_start::date, CASE WHEN date_part('hour', session_start) BETWEEN 6 and 12 THEN 1
                                                                                WHEN date_part('hour', session_start) BETWEEN 12 and 17 THEN 2
                                                                                WHEN date_part('hour', session_start) BETWEEN 17 and 22 THEN 3
                                                                            ELSE 4
                                                                            END,                                                                         
                         session_id, greatest(session_length,180), usr.gender, usr.age+extract(year from age(session_start, usr.registered)), usr.country) ;
                 raise notice 'Inserted user %, date %, session %, length %, age %, country %', sess.userid, session_start, session_id, session_length, usr.age, usr.country ;
              END IF ;
             session_start := sess.starttime ;
             session_id := session_id + 1;
             session_length := 0 ;
           END IF ;
        END LOOP;
   END LOOP;
exception when others then
 begin
    raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';

    raise notice '% %', SQLERRM, SQLSTATE;
end;
END$$;