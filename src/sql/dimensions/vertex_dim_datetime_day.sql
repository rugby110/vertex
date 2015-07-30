-- first create a table of numbers from 1-100,000 to join against when creating dates

DROP TABLE IF EXISTS numbers;

CREATE TABLE numbers (
     number INT NOT NULL 
);

-- get 10 numbers into the table 
INSERT INTO numbers values (1);
INSERT INTO numbers values (2);
INSERT INTO numbers values (3);
INSERT INTO numbers values (4);
INSERT INTO numbers values (5);
INSERT INTO numbers values (6);
INSERT INTO numbers values (7);
INSERT INTO numbers values (8);
INSERT INTO numbers values (9);
INSERT INTO numbers values (10);

-- turn 10 numbers into 100,000 numbers
INSERT INTO numbers (number)
SELECT ROW_NUMBER() 
         OVER(ORDER BY n1.number) 
FROM   numbers n1 
       CROSS JOIN numbers n2 
       CROSS JOIN numbers n3 
       CROSS JOIN numbers n4 
       CROSS JOIN numbers n5
OFFSET 10;

DROP TABLE IF EXISTS vertex_dim_datetime_day;

CREATE TABLE vertex_dim_datetime_day ( 
     id         INT,
     full_date  TIMESTAMP,     
     full_time  INT,
     year       INT, 
     quarter    INT,
     month      INT, 
     week       INT,
     day        INT, 
     year_label                 varchar,
     quarter_label_short        varchar,
     quarter_label_long         varchar,
     quarter_label_human        varchar,
     month_label_short          varchar,
     month_label_long           varchar,
     month_label_human          varchar,
     week_label_short           varchar,
     week_label_long            varchar,
     week_label_human           varchar,
     day_label_short            varchar,
     day_label_long             varchar,
     day_label_human            varchar,
     day_in_week                int,
     is_last_day_in_month       boolean,
     day_name_short             varchar,
     day_name_long              varchar,
     is_first_day_in_week       boolean,
     is_last_day_in_week        boolean,
     is_weekend                 boolean,
     year_quarter               int,
     year_quarter_month         int
);

-- populate the datetime table by joining on the numbers table
INSERT INTO vertex_dim_datetime_day (
        id, 
        full_date, 
        full_time, 
        year, quarter, month, week, day, 
        year_label,
        quarter_label_short,    quarter_label_long,     quarter_label_human,
        month_label_short,      month_label_long,       month_label_human,
        week_label_short,       week_label_long,        week_label_human,
        day_label_short,        day_label_long,         day_label_human,
        day_in_week,
        is_last_day_in_month,
        day_name_short, day_name_long,
        is_first_day_in_week,
        is_last_day_in_week,
        is_weekend,
        year_quarter,
        year_quarter_month
        )
SELECT YEAR(a.date)*10000 + MONTH(a.date)*100 + DAY(a.date),
       a.date,
       EXTRACT(EPOCH from a.date),
       YEAR(a.date), 
       QUARTER(a.date), 
       MONTH(a.date),
       WEEK(a.date),  
       DAY(a.date),
       TO_CHAR(a.date,'YYYY'),
       TO_CHAR(a.date,'Q'),
       'Q'|| TO_CHAR(a.date,'Q'),
       TO_CHAR(a.date,'YYYY') || '-Q'||TO_CHAR(a.date,'Q'),
       TO_CHAR(a.date,'Mon'),
       TRIM(TO_CHAR(a.date,'Month')),
       TO_CHAR(a.date,'YYYY') || '-'||TO_CHAR(a.date,'Mon'),
       TO_CHAR(a.date,'Mon') || ' ' || TO_CHAR(a.date, 'WW'),
       TRIM(TO_CHAR(a.date,'Month')) || ' ' || TO_CHAR(a.date, 'WW'),
       TO_CHAR(a.date,'YYYY') || '-'||TO_CHAR(a.date,'Mon') || '-' || TO_CHAR(a.date, 'WW') || ' wk',
       TO_CHAR(a.date,'DD'),
       CASE WHEN DAY(a.date) < 10 THEN RIGHT(TO_CHAR(a.date,'DD'),1) -- trim to '1' from '01'
            ELSE TO_CHAR(a.date,'DD')
       END ||  -- append to get 1st, 2nd, etc. 11-13 are an exception and are all 'th'
           CASE WHEN MOD(DAY(a.date),10) = 1 AND (DAY(a.date) < 10 OR DAY(a.date) > 13) THEN 'st'
                WHEN MOD(DAY(a.date),10) = 2 AND (DAY(a.date) < 10 OR DAY(a.date) > 13) THEN 'nd'
                WHEN MOD(DAY(a.date),10) = 3 AND (DAY(a.date) < 10 OR DAY(a.date) > 13) THEN 'rd'
                ELSE 'th'
           END,
       TO_CHAR(a.date,'YYYY') || '-'||TO_CHAR(a.date,'Mon') || '-' || TO_CHAR(a.date, 'DD'),
       --TO_CHAR(a.date,'YYYY') || '-'||TO_CHAR(a.date,'MM') || '-' || TO_CHAR(a.date, 'DD'),
       -- in Vertica, DAYOFWEEK returns Sunday=1, Monday=2, so adjust to get Monday=1, Sunday=7 
       CASE WHEN DAYOFWEEK(a.date) - 1 > 0 THEN DAYOFWEEK(a.date) - 1
            ELSE 7 -- for Sunday
       END,
       DAY(a.date) = DAY(LAST_DAY(a.date)), -- LAST_DAY returns the last day of the month for the date passed in
       TO_CHAR(a.date, 'Dy'),
       TRIM(TO_CHAR(a.date, 'Day')),
       DAYOFWEEK(a.date)-1 = 1,
       DAYOFWEEK(a.date)-1 = 0,
       DAYOFWEEK(a.date)-1 = 6 or DAYOFWEEK(a.date)-1 = 0,
       YEAR(a.date)*100 + QUARTER(a.date),
       YEAR(a.date)*10000 + QUARTER(a.date)*100 + MONTH(a.date) 
FROM  (SELECT TIMESTAMPADD(dd, number, '2004-12-31') AS date
       FROM   numbers 
       ORDER  BY number 
       LIMIT  18250) a; -- 50 years of dates (50*365) from 2005-01-01
