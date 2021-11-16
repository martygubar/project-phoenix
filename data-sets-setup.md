# Using public datasets with Oracle Database cloud services

## Introduction
You can easily load public datasets into Oracle Database cloud services. These datasets are used by demonstrations, tutorials, development and more.  Read more to learn how to set up your environment to easily find and download datasets.

A **dataset** is equivalent to an Oracle Database table.  A **dataset group** is a grouping of datasets that are related to one another.  For example, a dataset group may be the tables that comprise a star schema.

### Prerequisites
You need access to an Oracle Database 19c instance - like Autonomous Database. In addition, you need the following database privileges:
* CREATE TABLE
* CREATE VIEW
* CREATE PROCEDURE
* EXECUTE privilege on package DBMS_CLOUD

## Setup
Setup requires the installation of a package, a table and a view into your local schema.  Simply execute the snippet below a SQL Developer worksheet, SQL*Plus, sqlcl, etc.

```sql
<copy>
-- Run the following in order to install the dbms_datasets pacakge, datasets view and datasets_log table

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

## List available datasets
It is easy to view available datasets and then load the ones you want into your local schema. Run the following query to view available datasets:

```sql
<copy>
select * from datasets
</copy>
```
In the results below, you will see information about the public datasets.  As mentioned previously, a dataset maps to a table and a dataset group maps to a set of related tables. You can install a single dataset or a group with a single **dbms_dataset.get** command.

<table><thead><tr>	<th>DATASET_NAME</th>
	<th>DATASET_GROUP</th>
	<th>DESCRIPTION</th>
	<th>TABLE_NAME</th>
	<th>FILE_TYPE</th>
	<th>FORMAT</th>
	<th>URL</th>
	<th>COLUMNS</th>
</tr></thead>
<tbody id="data">

<tr valign="top">
<td>moviestream-genre</td>
<td>moviestream</td>
<td>MovieStream movie genres</td>
<td>GENRE</td>
<td>csv</td>
<td>{"dateformat":"YYYY-MM-DD","skipheaders":"1","delimiter":",","ignoreblanklines":"true","removequotes":"true","blankasnull":"true","trimspaces":"lrtrim","truncatecol":"true","ignoremissingcolumns":"true"}</td>
<td>https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_gold/o/genre/*</td>
<td>[{"column_name":"GENRE_ID","data_type":"NUMBER","data_length":22,"data_precision":null,"data_scale":null},{"column_name":"NAME","data_type":"VARCHAR2","data_length":30,"data_precision":null,"data_scale":null}]</td>
	</tr>
	<tr valign="top">
<td>moviestream-custsales</td>
<td>moviestream</td>
<td>MovieStream customer sales</td>
<td>CUSTSALES</td>
<td>parquet</td>
<td>{"type":"parquet","schema":"all"}</td>
<td>https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_gold/o/custsales/*</td>
<td>[{"column_name":"DAY_ID","data_type":"DATE","data_length":7,"data_precision":null,"data_scale":null},{"column_name":"GENRE_ID","data_type":"NUMBER","data_length":22,"data_precision":20,"data_scale":0},{"column_name":"MOVIE_ID","data_type":"NUMBER","data_length":22,"data_precision":20,"data_scale":0},{"column_name":"CUST_ID","data_type":"NUMBER","data_length":22,"data_precision":20,"data_scale":0},{"column_name":"APP","data_type":"VARCHAR2","data_length":4000,"data_precision":null,"data_scale":null},{"column_name":"DEVICE","data_type":"VARCHAR2","data_length":4000,"data_precision":null,"data_scale":null},{"column_name":"OS","data_type":"VARCHAR2","data_length":4000,"data_precision":null,"data_scale":null},{"column_name":"PAYMENT_METHOD","data_type":"VARCHAR2","data_length":4000,"data_precision":null,"data_scale":null},{"column_name":"LIST_PRICE","data_type":"BINARY_DOUBLE","data_length":8,"data_precision":null,"data_scale":null},{"column_name":"DISCOUNT_TYPE","data_type":"VARCHAR2","data_length":4000,"data_precision":null,"data_scale":null},{"column_name":"DISCOUNT_PERCENT","data_type":"BINARY_DOUBLE","data_length":8,"data_precision":null,"data_scale":null},{"column_name":"ACTUAL_PRICE","data_type":"BINARY_DOUBLE","data_length":8,"data_precision":null,"data_scale":null}]</td>
	</tr>
	<tr valign="top">
<td>moviestream-customer-contact</td>
<td>moviestream</td>
<td>MovieStream customers and their contact details</td>
<td>CUSTOMER_CONTACT</td>
<td>csv</td>
<td>{"dateformat":"YYYY-MM-DD","skipheaders":"1","delimiter":",","ignoreblanklines":"true","removequotes":"true","blankasnull":"true","trimspaces":"lrtrim","truncatecol":"true","ignoremissingcolumns":"true"}</td>
<td>https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_gold/o/customer_contact/*</td>
<td>[{"column_name":"CUST_ID","data_type":"NUMBER","data_length":22,"data_precision":null,"data_scale":null},{"column_name":"LAST_NAME","data_type":"VARCHAR2","data_length":200,"data_precision":null,"data_scale":null},{"column_name":"FIRST_NAME","data_type":"VARCHAR2","data_length":200,"data_precision":null,"data_scale":null},{"column_name":"EMAIL","data_type":"VARCHAR2","data_length":500,"data_precision":null,"data_scale":null},{"column_name":"STREET_ADDRESS","data_type":"VARCHAR2","data_length":400,"data_precision":null,"data_scale":null},{"column_name":"POSTAL_CODE","data_type":"VARCHAR2","data_length":10,"data_precision":null,"data_scale":null},{"column_name":"CITY","data_type":"VARCHAR2","data_length":100,"data_precision":null,"data_scale":null},{"column_name":"STATE_PROVINCE","data_type":"VARCHAR2","data_length":100,"data_precision":null,"data_scale":null},{"column_name":"COUNTRY","data_type":"VARCHAR2","data_length":400,"data_precision":null,"data_scale":null},{"column_name":"COUNTRY_CODE","data_type":"VARCHAR2","data_length":2,"data_precision":null,"data_scale":null},{"column_name":"CONTINENT","data_type":"VARCHAR2","data_length":400,"data_precision":null,"data_scale":null},{"column_name":"YRS_CUSTOMER","data_type":"NUMBER","data_length":22,"data_precision":null,"data_scale":null},{"column_name":"PROMOTION_RESPONSE","data_type":"NUMBER","data_length":22,"data_precision":null,"data_scale":null},{"column_name":"LOC_LAT","data_type":"NUMBER","data_length":22,"data_precision":null,"data_scale":null},{"column_name":"LOC_LONG","data_type":"NUMBER","data_length":22,"data_precision":null,"data_scale":null}]</td>
</tr>
</tbody>
</table>


## Installing a dataset into your schema
Use the **dbms_dataset.get** procedure call to install datasets into your schema:

Procedure **dbms_datasets.get**

You must enter a dataset name and/or a dataset group.
|parameter | type | description |
|---|---|---|
|p\_dataset\_name | varchar2 | Name of the dataset to install (optional).   |
|p\_dataset\_group | varchar2 | Name of the dataset group to install (optional) |
|p\_load\_data | boolean | (default true) You can load the data (true) or create an external table over the dataset (false).  <br><br>Loading data will take more time run - but queries will be fast. <br>Use external tables to quickly create datasets and then run queries directly against object storage. You can load the data later if you find the data useful.
|p\_overwrite | boolean | (default true) Overwrite the table if it already exists.

### Examples

1. Install the **moviestream-genre** dataset.

    This will create and load **GENRE** table

    ```sql
    <copy>
        exec dbms_datasets.get(p_dataset_name => 'moviestream-genre')
    </copy>
    ```
    You can now query the genre table:
    ```sql
    <copy>
        select * from genre;
    </copy>
    ```

2. Install all the tables in the **moviestream** dataset group. Create external tables only - do not load the data.

    The following snippet will create *all* the tables in the moviestream dataset group.  And, it will overwrite any tables that previously existed. Data will not be loaded; queries will run directly against object storage.
    ```sql
    <copy>
        exec dbms_datasets.get(p_dataset_group => 'moviestream', p_overwrite => true, p_load_data => false)
    </copy>
    ```

## Viewing a log of the installation
You can view a log of the dataset installation by querying the **datasets\_log** table:
```sql
<copy>
    select * from datasets_log order by 1;
</copy>
```

In addition, the loading of datasets uses **dbms\_cloud.copy\_data** and its associated logging. See the [following documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbbj/index.html#articletitle) for more details.
