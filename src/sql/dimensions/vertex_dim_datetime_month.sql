DROP TABLE IF EXISTS vertex_dim_datetime_month;

SELECT YEAR(full_date)*100 + MONTH(full_date) as datetime_month_id,
        full_date,
        full_time, 
        year, 
        quarter, 
        month,
        year_label,
        quarter_label_short,    quarter_label_long,     quarter_label_human,
        month_label_short,      month_label_long,       month_label_human,
        year_quarter,
        year_quarter_month
into vertex_dim_datetime_month
from vertex_dim_datetime_day
where day=1;

select count(*) from vertex_dim_datetime_month
order by datetime_month_id
limit 10

select * from verse_dim_datetime_month
order by v_id
limit 10