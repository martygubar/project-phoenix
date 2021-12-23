select json_object('dataset_name' value d.name,
                   'dataset_group' value d.dataset_group,
                   'description' value d.description,
                   'table_name' value u.table_name, 
                   'file_type' value d.file_type,
                   'format' value d.format,
                   'url' value d.url,                   
                   'columns' value json_arrayagg(
                             json_object('column_name' value u.column_name,
                                         'data_type' value u.data_type,
                                         'data_length' value u.data_length,
                                         'data_precision' value u.data_precision,
                                         'data_scale' value u.data_scale)
                             order by u.table_name, d.table_name)
                   )
from user_tab_cols u, dataset_properties d
where u.table_name = upper(d.table_name)
group by u.table_name, name, description, file_type, url, dataset_group, d.format;

select * from dataset_properties;

create or replace view datasets as
select 
       a.doc.dataset_name as dataset_name,
       a.doc.dataset_group as dataset_group,
       a.doc.description as description,
       a.doc.table_name as table_name,
       a.doc.file_type as file_type,
       a.doc.url as url
from external (
 (
    doc varchar2(32000)     	   
 ) 
 type ORACLE_BIGDATA
 default directory DATA_PUMP_DIR
 access parameters (
    com.oracle.bigdata.fileformat=textfile
    com.oracle.bigdata.csv.rowformat.fields.terminator='\n'
 )
 LOCATION ('https://raw.githubusercontent.com/martygubar/project-phoenix/master/data-sets.json')
) a;

create table dataset_format (
  file_type varchar2(100),
  key varchar2(100),
  value varchar2(100)
);


select * from datasets;
