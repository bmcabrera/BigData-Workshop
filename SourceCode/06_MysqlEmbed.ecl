IMPORT STD;
IMPORT mysql; // Used to embed sql statements
IMPORT ^ AS ROOT;


myServer := #IFDEFINED(ROOT.mysqlserver, 'my-test-server.mysql.database.azure.com');
myDb := #IFDEFINED(ROOT.mysqldb, 'demo_db');
myUser := #IFDEFINED(ROOT.mysqluser, 'azure_root');
myPassword := #IFDEFINED(ROOT.mysqldb, 'Demo123$');

/*
* Original layout of sales dataset
*/
SALES_LAYOUT := RECORD 
  INTEGER order_number;
  STRING item;
  INTEGER quantity;
  STRING price;
  STRING order_date;
END;

/*
* Result layout matching our MySQL database table columns
*/
NEWSALES_LAYOUT := RECORD
  SALES_LAYOUT;
  INTEGER date_reformat;
  STRING time;
  INTEGER time_seconds;
  INTEGER month;
  INTEGER day;
  INTEGER year;
  STRING day_of_week;
  INTEGER quarter;
  UNSIGNED monthstart;
  UNSIGNED monthend;
END;


dateTransformationsDataset := DATASET('~demo::datetransformations:superfile', NEWSALES_LAYOUT, THOR);

/*
* embedded sql within function to create mysql table 
*/
create() := EMBED(mysql :  user(myUser), database(myDb), password(myPassword), server(myServer), port('3306'))
  CREATE TABLE IF NOT EXISTS demo_table ( 
                            order_number INT, 
                            item VARCHAR(20), 
                            quantity INT, 
                            price VARCHAR(20), 
                            order_date VARCHAR(30), 
                            date_reformat DATETIME, 
                            time time,
                            month INT,
                            day INT,
                            year INT,
                            time_seconds INT,
                            day_of_week VARCHAR(20),
                            quarter INT,
                            monthstart INT,
                            monthend INT 
                          );
ENDEMBED;


/*
* embedded sql within function which inserts dataset passed into mysql table
* order_number, item, quantity, price, order_date, date_reformat, time, month, day, year, 
* time_seconds, day_of_week, quarter, monthstart, monthend
*/
insert(dataset(NEWSALES_LAYOUT) values) := EMBED(mysql :  user(myUser), database(myDb), password(myPassword), server(myServer), port('3306'))
  INSERT INTO demo_table values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
ENDEMBED;

/*
* embedded sql within function to select all records from table 'demo_table'
*/
DATASET(NEWSALES_LAYOUT) select() := EMBED(mysql :  user(myUser), database(myDb), password(myPassword), server(myServer), port('3306'))
  SELECT * FROM demo_table;
ENDEMBED;


create();
insert(dateTransformationsDataset);
select();
