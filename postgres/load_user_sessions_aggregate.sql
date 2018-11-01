DO 
$$DECLARE
 usr RECORD;
 sess RECORD;
 session_id INTEGER ;
 session_length INTEGER ;
 session_start TIMESTAMP ;
 gender integer ;
 genres TEXT ;
 genre_list TEXT ;

BEGIN
 CREATE TEMP TABLE genre_tab(genre text unique, sesscount integer) ;
 FOR usr in (SELECT a.userid, a.gender, a.age, b.countryid country,a.registered  
               FROM user_profiles a, country b 
              WHERE a.country = b.countryname) LOOP
      session_id := 1 ;
      session_length := 0 ;
      session_start := NULL ;
      genres := ',' ;
      genre_list := '' ;
      truncate table genre_tab ;
      FOR sess IN ( SELECT *, extract(day from delta)*86400 + extract(hour from delta)*3600 + extract(minute from delta)*60 + extract(second from delta) intrvl FROM usrsession_intrmdt 
                     WHERE userid = usr.userid order by session_start ) LOOP
          IF sess.delta IS NULL THEN 
               session_start := sess.session_start ;
          END IF ;
          IF sess.intrvl > 86400 THEN
             RAISE NOTICE 'Interval %', sess.intrvl ;
          END IF ;
          
          IF COALESCE(sess.intrvl, 0) < 1800 THEN
             session_length := session_length + COALESCE(sess.intrvl, 0) ; 
             genres := genres || COALESCE(sess.genre_1, 'NULL')||','||COALESCE(sess.genre_2, 'NULL')||','||COALESCE(sess.genre_3, 'NULL')||',' ;
             IF sess.genre_1 IS NOT NULL THEN 
                    INSERT INTO genre_tab (genre, sesscount)
                    VALUES (sess.genre_1, 1)
                    ON CONFLICT (genre) DO UPDATE SET sesscount = genre_tab.sesscount+1;
             END IF ;
             IF sess.genre_2 IS NOT NULL THEN             
                    INSERT INTO genre_tab (genre, sesscount)
                    VALUES (sess.genre_2, 1)
                    ON CONFLICT (genre) DO UPDATE SET sesscount = genre_tab.sesscount+1;
             END IF ; 
             IF sess.genre_3 IS NOT NULL THEN                    
                    INSERT INTO genre_tab (genre, sesscount)
                    VALUES (sess.genre_3, 1)
                    ON CONFLICT (genre) DO UPDATE SET sesscount = genre_tab.sesscount+1;
             END IF ;
          ELSE
                gender := case when usr.gender = 'm' then 1 when usr.gender = 'f' then 0 else null end ;
                genre_list := (SELECT string_agg(genre||'-'||sesscount::text, ', ') FROM genre_tab) ;
                IF session_length > 300 THEN 
                    INSERT INTO user_session_aggregated 
                         (userid, session_start, day_of_week, time_of_day,  session_id, session_length, gender, age, country, genre )
                   VALUES
                         (sess.userid, session_start, sess.day_of_week, sess.time_of_day, session_id, greatest(session_length,300), gender, usr.age+extract(year from age(session_start, usr.registered)), usr.country, genre_list) ;
                         raise notice 'Inserted user %, date %, session %, length %, genre %', sess.userid, session_start, session_id, session_length, genre_list ;
                END IF ;
             session_start := sess.session_start ;
             session_id := session_id + 1;
             session_length := 0 ;
             TRUNCATE TABLE genre_tab ;
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