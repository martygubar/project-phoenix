# Load public datasets

## Introduction
You can easily load data into Oracle Database cloud services. These datasets are used by demonstrations, tutorials, development and more.

### Prerequisites
You need access to an Oracle Database 19c instance - like Autonomous Database. 

## Setup
After connecting to your database, run the following in either SQL Worksheet or SQLCl.

```sql
<copy>
-- Run the following in order to install the dbms_datasets pacakge and view
-- Click F5 to run all the scripts at once

-- Define the scripts found in the labs table.
declare
    b_plsql_script blob;            -- binary object
    c_plsql_script clob;    -- converted to clob
    uri varchar2(2000) := 'https://raw.githubusercontent.com/martygubar/project-phoenix/master/sql-files/setup.sql';

begin

    dbms_output.put_line('downloading datasets setup script');

    b_plsql_script := dbms_cloud.get_object(object_uri => uri);

    dbms_output.put_line('....creating plsql package dbms_stats ');
    -- convert the blob to a varchar2 and then create the procedure
    c_plsql_script :=  to_clob( b_plsql_script );

    -- generate the procedure
    execute immediate c_plsql_script;
    
    exception
        when others then
            dbms_output.put_line('Unable to install the setup routines.');
            dbms_output.put_line('');
            dbms_output.put_line(sqlerrm);
 end;
 /
 
-- run the script that was just downloaded and created
exec  dbms_datasets_setup;

</copy>
```
