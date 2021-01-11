Create Ingestion Tables

-- Create Users Extract table
CREATE TABLE user_extract
(
 id          varchar NOT NULL,
 postcode    varchar NOT NULL,
 insert_date datetime NOT NULL
);

--Create Pageview Extract table
CREATE TABLE pageview_extract
(
 user_id           varchar NOT NULL,
 url               varchar NOT NULL,
 pageview_datetime datetime NOT NULL,
 insert_date       datetime NOT NULL
);



Create Staging Tables 
*-- Create Staging Pageview table
CREATE TABLE staging_pageview
(
 user_id           varchar NOT NULL,
 url               varchar NOT NULL,
 pageview_datetime datetime NOT NULL,
 insert_date       datetime NOT NULL
); 

Create Dimension Tables 
*-- Create User Dimension Tables (slowly changing dimension)
CREATE TABLE dim_users_type1
(
 user_id     varchar NOT NULL,
 postcode    varchar NOT NULL,
 insert_date datetime NOT NULL,
 CONSTRAINT PK_dim_users_type1 PRIMARY KEY ( user_id )
);

create or replace sequence dim_user_id_seq;
CREATE TABLE dim_users_type2
(
 dim_user_id number(38,0) NOT NULL,
 user_id     varchar NOT NULL,
 postcode    varchar NOT NULL,
 start_date  datetime NOT NULL,
 end_date    datetime NOT NULL,
 CONSTRAINT PK_dim_users_type1_clone PRIMARY KEY ( dim_user_id )
);

*-- Create URL dimension table 
CREATE TABLE dim_url
(
 url_id number(38,0) NOT NULL,
 url    varchar NOT NULL,
 CONSTRAINT PK_dim_page PRIMARY KEY ( url_id )
);

*-- Create Date dimension table
CREATE OR REPLACE SEQUENCE DATE_ID_SEQ;
CREATE OR REPLACE TABLE dim_date (
  DATE_ID           NUMBER  NOT NULL primary key,
  MY_DATE          DATETIME        NOT NULL
  ,YEAR             SMALLINT    NOT NULL
  ,MONTH            SMALLINT    NOT NULL
  ,MONTH_NAME       CHAR(3)     NOT NULL
  ,DAY_OF_MON       SMALLINT    NOT NULL
  ,DAY_OF_WEEK      VARCHAR(9)  NOT NULL
  ,WEEK_OF_YEAR     SMALLINT    NOT NULL
  ,DAY_OF_YEAR      SMALLINT    NOT NULL
  ,HOUR             SMALLINT    NOT NULL
)
AS
  WITH CTE_MY_DATE AS (
    SELECT DATEADD(HOUR, SEQ4(), '2020-01-01') AS MY_DATE
      FROM TABLE(GENERATOR(ROWCOUNT=>20000))  -- Number of days after reference date in previous line
  )
  SELECT DATE_ID_SEQ.NEXTVAL DATE_ID
        ,MY_DATE
        ,YEAR(MY_DATE)
        ,MONTH(MY_DATE)
        ,MONTHNAME(MY_DATE)
        ,DAY(MY_DATE)
        ,DAYOFWEEK(MY_DATE)
        ,WEEKOFYEAR(MY_DATE)
        ,DAYOFYEAR(MY_DATE)
        ,HOUR(MY_DATE)
    FROM CTE_MY_DATE
;

*-- Create Fact Pageview table
CREATE TABLE fact_pageview
(
 dim_user_id     number(38,0) NOT NULL,
 user_id         varchar NOT NULL,
 url_id          number(38,0) NOT NULL,
 date_id         number(38,0) NOT NULL,
 no_of_pageviews integer NOT NULL,
 postcode        varchar NOT NULL,
 CONSTRAINT PK_fact_pageview PRIMARY KEY ( dim_user_id, user_id, url_id, date_id ),
 CONSTRAINT fk_date_id FOREIGN KEY ( date_id ) REFERENCES dim_date ( date_id ),
 CONSTRAINT fk_dim_user_id FOREIGN KEY ( dim_user_id ) REFERENCES dim_users_type2 ( dim_user_id ),
 CONSTRAINT fk_url_id FOREIGN KEY ( url_id ) REFERENCES dim_url ( url_id ),
 CONSTRAINT fk_user_id FOREIGN KEY ( user_id ) REFERENCES dim_users_type1 ( user_id )
);
