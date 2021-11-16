-- view list of datasets
select * from datasets;

-- Install the genre table
exec dbms_datasets.get(p_dataset_name => 'moviestream-genre')

select * from genre;

-- Create all the tables in the moviestream dataset group.  But don't load them
exec dbms_datasets.get(p_dataset_group => 'moviestream', p_overwrite => true, p_load_data => false)

select g.name, round(sum(c.actual_price),0) as sales
from genre g, custsales c
where g.genre_id = c.genre_id
group by g.name
order by 2 desc
fetch first 10 rows only;