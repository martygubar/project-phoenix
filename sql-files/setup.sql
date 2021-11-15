-- table captures data set install log
create table datasets_log
   (	execution_time timestamp (6),
	    message varchar2(32000 byte)
   );

-- create the view over the list of datasets
CREATE OR REPLACE VIEW datasets AS 
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

-- Create packages used to install 
create or replace package dbms_datasets as 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure get (p_dataset_name in varchar2 default null,
                 p_dataset_group varchar2 default null,
                 p_load_data boolean default true,
                 p_overwrite boolean default true);

end dbms_datasets;
/

create or replace package body dbms_datasets as


  -- write to a log table
  procedure write 
    (
      message in varchar2 default ''
    ) as 
    begin
        dbms_output.put_line(to_char(systimestamp, 'DD-MON-YY HH:MI:SS') || ' - ' || message); 
        
        if message is not null then
            execute immediate 'insert into datasets_log values(:t1, :msg)' 
                    using systimestamp, message;
            commit;
        end if;
    
    end write;
    
  -- execute ddl statements  
  procedure exec 
    (
      sql_ddl in varchar2,
      raise_exception in boolean := false
      
    ) as 
    begin
        -- Wrapper for execute immediate
        -- write(sql_ddl);
        execute immediate sql_ddl;
        
        exception
          when others then
            if raise_exception then
                raise;
            else                
                write(sqlcode);
                write(sqlerrm);
            end if;        
    end exec;
  
  /*
    Takes the column spec in JSON format and returns the column definition used
    by CREATE TABLE
  */
  function get_column_spec (j_column json_object_t) return varchar2
  as
    l_column_name varchar2(100);
    l_column_type varchar2(100);
    l_column_length number;
    l_column_precision number;
    l_column_scale number;
    retval varchar2(500);
  begin
    
    l_column_name := j_column.get_String('column_name');
    l_column_type := upper(j_column.get_String('data_type'));
    l_column_length := j_column.get_String('data_length');
    l_column_precision := j_column.get_String('data_precision');
    l_column_scale := j_column.get_String('data_scale');
    
    case 
        when l_column_type in ('CHAR','VARCHAR2','NCHAR','NVARCHAR2','BLOB','CLOB','NCLOB','BFILE','ROWID','RAW','UROWID') then  
            -- e.g. VARCHAR2(10 bytes)
            retval := l_column_name || ' ' || l_column_type || '(' || l_column_length || ')';
        when l_column_type in ('NUMBER','DATE') or instr(l_column_type, 'TIMESTAMP') > 0  then
            -- e.g. NUMBER
            retval := l_column_name || ' ' || l_column_type;
            
            if l_column_scale is not null then
                -- e.g. NUMBER(10,5)
                retval := retval || '(' || l_column_precision || ', ' || l_column_scale || ')';
            elsif l_column_scale is null and l_column_precision is not null then
                -- e.g. NUMBER(10)
                retval := retval || '(' || l_column_precision || ')';
            end if;          
        else
            retval := l_column_name || ' ' || l_column_type;
    end case;
    
    return retval;
    
    
  end;
  
  
  -- Get the hosted data set  
  procedure get (p_dataset_name in varchar2,
                 p_dataset_group varchar2,
                 p_load_data boolean,
                 p_overwrite boolean) as
    
    invalid_dataset exception;
    pragma exception_init( invalid_dataset, -20001 );
    type t_datasets is table of datasets%rowtype index by pls_integer;
    l_datasets t_datasets;
    j_dataset  json_object_t;
    j_columns  json_array_t;
    j_column   json_object_t;
    start_time date;
    elapsed number;
    l_column_spec varchar2(500);
    l_column_list varchar2(32000);
    l_table_name varchar2(200);
    l_url varchar2(32000);
    l_format varchar2(32000);
    l_ddl varchar2(32000);
    
    
    begin    
        start_time := systimestamp;
        write ('Begin');
                
        if p_dataset_name is null and p_dataset_group is null then
            raise invalid_dataset;
        end if;
                
        write('> create and load tables   : ' || case when p_load_data then 'true' else 'false' end);        
        write('> overwrite existing tables: ' || case when p_overwrite then 'true' else 'false' end);
                
        write('- find the datasets');       
                    
       select *        
       bulk collect into l_datasets
       from datasets d
       where upper(d.dataset_name) = upper(p_dataset_name)
          or upper(d.dataset_group) = upper(p_dataset_group);
           
        if l_datasets.count = 0 then
            raise invalid_dataset;
        end if;
           
        for i in l_datasets.first .. l_datasets.last 
        loop
            l_table_name := l_datasets(i).table_name;
            l_url :=  l_datasets(i).url;
            l_format := l_datasets(i).format;
            
            write('- fetching properties for ' || l_datasets(i).dataset_name);
            write('    table_name: ' || l_table_name);
            write('    url       : ' || l_url);
            write('    format : ' || l_format);
            write('    columns :');
            
            j_dataset := json_object_t.parse(l_datasets(i).doc);
            j_columns := j_dataset.get_array('columns');
            
            l_column_list := null;
            
            -- loop over the table's columns and get the column specs
            for c in 0 .. j_columns.get_size - 1
            loop
                j_column      := json_object_t(j_columns.get(c));
                l_column_spec := get_column_spec(j_column);
                --write('    ... ' || l_column_spec);
                
                if c = 0 then
                    l_column_list := l_column_spec;
                else
                    l_column_list := l_column_list || ', ' || l_column_spec;
                end if;

            end loop;                

            -- here's the column spec
            write('       ' || l_column_list);
            
            -- now let's create tables
            -- overwrite if nec.
            if p_overwrite then
                write ('- dropping ' || l_table_name || ' if it exists.');
                exec ('drop table ' || l_table_name);
            end if;
            
            -- create and load the table or simply create an external table?
            if p_load_data then
                write('- creating table ' || l_table_name);
                l_ddl := 'create table ' || l_table_name || '('
                                         || l_column_list 
                                         || ')';
                write('    ' || l_ddl);
                exec (l_ddl);
                write('- loading data using dbms_cloud.copy_data');

                dbms_cloud.copy_data (
                    table_name => l_table_name,
                    file_uri_list => l_url,
                    format => l_format
                    );                                
            else
                write('- creating external table ' || l_table_name);
                dbms_cloud.create_external_table (
                    table_name => l_table_name,
                    file_uri_list => l_url,
                    format => l_format,
                    column_list => l_column_list
                    );
            end if;
                                                  
            
                        
        end loop;
        
               
        write('done.');
        elapsed := round((sysdate - start_time) * 24 * 60 * 60, 0); 
        write('elapsed time(s): ' || elapsed);


    exception
      when invalid_dataset then
            write('ERROR:  Please enter a valid dataset or dataset group name.');
            write('To see the valid datasets:');
            write('   select * from dataset;');
            write('done.');
      when others then
        write(sqlerrm);
        raise;        
    
  end get;
  
end dbms_datasets;
/