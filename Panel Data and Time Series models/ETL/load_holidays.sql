drop table intnl_holidays ;
create table intnl_holidays (id integer,
                             raw_country text,
                             hol_dt date,
                             is_holiday integer,
                             country text) ;

copy intnl_holidays from 'C:\Users\jayashree.raman\Documents\Learning\MIDS\capstone\datasets\international_holidays.tsv' with (format csv, header true, delimiter E'\t', null '') ;
