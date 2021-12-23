create table datasets_log
   (	execution_time timestamp (6),
	    message varchar2(32000 byte)
   );



create or replace view datasets as
select 
       a.doc.dataset_name as dataset_name,
       a.doc.dataset_group as dataset_group,
       a.doc.description as description,
       a.doc.table_name as table_name,
       a.doc.file_type as file_type,
       a.doc.format as format,
       a.doc.url as url,
       a.doc.columns as columns,
       a.doc as doc
from external (
 (
    doc clob     	   
 ) 
 type ORACLE_BIGDATA
 default directory DATA_PUMP_DIR
 access parameters (
    com.oracle.bigdata.fileformat=textfile
    com.oracle.bigdata.csv.rowformat.fields.terminator='\n'
 )
 LOCATION ('https://raw.githubusercontent.com/martygubar/project-phoenix/master/data-sets.json')
) a;


select * from datasets;