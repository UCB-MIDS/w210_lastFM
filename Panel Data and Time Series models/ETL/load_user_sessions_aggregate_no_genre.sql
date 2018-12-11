DO 
$$DECLARE
 usr RECORD;
 sess RECORD;
 session_id INTEGER ;
 session_length INTEGER ;
 session_count INTEGER ;
 session_start TIMESTAMP ;
 gender integer ;
 absence_time integer ;

BEGIN
 FOR usr in (SELECT a.userid, a.gender, a.age, b.countryid country,a.registered  
               FROM user_profiles a, country b 
              WHERE a.country = b.countryname) LOOP
      session_id := 1 ;
      session_length := 0 ;
      session_length := 1 ;
      session_start := NULL ;
      absence_time := 0 ;

      FOR sess IN ( SELECT *, extract(day from delta)*86400 + extract(hour from delta)*3600 + extract(minute from delta)*60 + extract(second from delta) intrvl FROM usrsession_intrmdt 
                     WHERE userid = usr.userid order by session_start ) LOOP
          IF sess.delta IS NULL OR session_start IS NULL THEN 
               session_start := sess.session_start ;
          END IF ;
          
          IF COALESCE(sess.intrvl, 0) < 1800 AND session_length + COALESCE(sess.intrvl, 0) < 43201 THEN
             session_length := session_length + COALESCE(sess.intrvl, 0) ; 
             session_count := session_count + 1 ;
          ELSE
                gender := case when usr.gender = 'm' then 1 when usr.gender = 'f' then 0 else null end ;
                absence_time := sess.intrvl ;
                IF session_length > 300 and session_length < 43201 THEN 
                    INSERT INTO user_session_aggregated 
                         (userid, session_start, day_of_week, time_of_day,  session_id, session_length, session_count,  gender, age, country, absence_time )
                   VALUES
                         (sess.userid, session_start, sess.day_of_week, sess.time_of_day, session_id, greatest(session_length,300), session_count, gender, usr.age+extract(year from age(session_start, usr.registered)), usr.country, absence_time) ;
                         raise notice 'Inserted user %, date %, session %, count %, length % absence time %', sess.userid, session_start, session_id, session_count, session_length, absence_time;
                END IF ;
             session_start := sess.session_start ;
             session_id := session_id + 1;
             session_length := 0 ;
             session_count := 0 ;
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