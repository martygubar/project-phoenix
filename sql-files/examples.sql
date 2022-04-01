-- list datasets
select * from datasets;

-- Get genre
exec dbms_datasets.get(p_dataset_name => 'moviestream-genre')
select * from genre;

-- check out customer contact without loading
exec dbms_datasets.get(p_dataset_name => 'moviestream-customer-contact', p_overwrite => true, p_load_data => false)
select * from customer_contact where rownum < 10;

-- check out a dataset group without loading
exec dbms_datasets.get(p_dataset_group => 'moviestream', p_overwrite => true, p_load_data => false)

-- Query the group
select g.name, round(sum(c.actual_price),0) as sales
from genre g, custsales c
where g.genre_id = c.genre_id
group by g.name
order by 2 desc
fetch first 10 rows only;