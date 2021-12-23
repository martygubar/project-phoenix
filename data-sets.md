# Oracle Data Sets API
API will be offered in a variety of languages, including python, plsql, java, cli.


## Model

Should a data set have multiple file types?  Deliver a data set with multiple formats?

```json
{
        "name": {
            "type":"string",
            "description": "Name of the data set"
        },
        "description": {
            "type":"string",
            "description": "Description of the data set"
        },
        "id": {
            "type":"string",
            "description": "Unique id of the data set"
        },
        "table_name": {
            "type":"string",
            "description": "Name of the data set"
        },        
        "fileType": {
            "type":"string",
            "enum": ["csv","json","parquet","orc","avro","txt"]
        },
        "format": {
            "type":"string",
            "description": "The format spec for the file (uses ADB format spec)"
        },
        "attribution": {
            "type":"string",
            "description": "Source of the data set and the legal attribution"
        },
        "version": {
            "type":"date",
            "description": "Data set version. It is simply the date that it was last changed."
        },
        "schema": {
            "type":"array",
            "items": { 
                "$ref":"#/$defs/column"                
            }
        },
        "url": {
            "type":"string",
            "format": "uri"
        },
        "relatedDataSets":{
            "type":"array",
            "items":[
                {
                    "relatedId":"string"
                }
            ]
        }
    }
```

## Commands (need params)

### Common usage
* `list`

   List the available data sets.  

* `get`

   Downloads the data set
   target (local directory, database table, bucket)
   if target is database, need a connection.
   pk and indexes
   Allow related data sets to also get downloaded

* `bulk-get`

   Specify lots of data sets to download   
   Need to apply PK, FK

### Publisher Usage

* `create`

   Create a new data set

* `delete`

   Delete a data set

* `update`

   Update a data set



## Open Issues
What about things that are associated with the schema - like triggers and sequences?
* This can be part of the documentation of the data set if necessary


