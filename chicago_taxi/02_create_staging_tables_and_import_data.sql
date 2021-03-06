-- Create staging tables and import data from sources
-- Prerequisites: your EXASOL database should be able to connect to the internet and should have a dns-server defined

CREATE OR REPLACE TABLE CHICAGO_TAXI_STAGE.TRIPS_RAW (
  TRIP_ID VARCHAR(40),
  TAXI_ID VARCHAR(255),
  TRIP_START_TIMESTAMP TIMESTAMP WITHOUT TIME ZONE,
  TRIP_END_TIMESTAMP TIMESTAMP WITHOUT TIME ZONE,
  TRIP_SECONDS DECIMAL(9),
  TRIP_MILES DECIMAL(18,4),
  PICKUP_CENSUS_TRACT VARCHAR(100),
  DROPOFF_CENSUS_TRACT VARCHAR(100),
  PICKUP_COMMUNITY_AREA DECIMAL,
  DROPOFF_COMMUNITY_AREA DECIMAL,
  FARE VARCHAR(100),
  TIPS VARCHAR(100),
  TOLLS VARCHAR(100),
  EXTRAS VARCHAR(100),
  TRIP_TOTAL VARCHAR(100),
  PAYMENT_TYPE VARCHAR(100),
  COMPANY VARCHAR(100),
  PICKUP_CENTROID_LATITUDE DECIMAL(18,9),
  PICKUP_CENTROID_LONGITUDE DECIMAL(18,9),
  PICKUP_CENTROID_LOCATION VARCHAR(100),
  DROPOFF_CENTROID_LATITUDE NUMERIC(18,9),
  DROPOFF_CENTROID_LONGITUDE NUMERIC(18,9),
  DROPOFF_CENTROID_LOCATION VARCHAR(100)
);

-- Import all staging tables directly from the Chicago Taxi site

IMPORT INTO &STAGESCM..trips_raw FROM CSV AT 'https://data.cityofchicago.org/api/views/wrvz-psew' FILE 'rows.csv?accessType=DOWNLOAD'
(1..2,3 FORMAT='MM/DD/YYYY HH12:MI:SS AM',4  FORMAT='MM/DD/YYYY HH12:MI:SS AM',5..24) SKIP=1;

CREATE OR REPLACE TABLE	&STAGESCM..CENSUS_TRACTS(
		THE_GEOM VARCHAR(2000000),
		STATEFP10 decimal(9),
		COUNTYFP10 DECIMAL(9),
		TRACTCE10 decimal(9),
		GEOID10 decimal(11),
		NAME10 DECIMAL(9),
		NAMELSAD10 varchar(100),
		COMMAREA decimal(9),
		COMMAREA_N decimal(9),
		NOTES varchar(1000)
	);
IMPORT INTO &STAGESCM..CENSUS_TRACTS FROM CSV AT 'https://data.cityofchicago.org/api/views/74p9-q2aq' FILE 'rows.csv?accessType=DOWNLOAD' SKIP=1;

CREATE OR REPLACE TABLE	&STAGESCM..COMMUNITY_AREAS(
		the_geom varchar(2000000),
		PERIMETER DECIMAL(9),
		AREA DECIMAL(9),
		COMAREA_ DECIMAL(9),
		COMAREA_ID DECIMAL(9),
		AREA_NUMBE DECIMAL(9),
		COMMUNITY varchar(100),
		AREA_NUM_1 DECIMAL(9),
		SHAPE_AREA double,
		SHAPE_LEN double
	);
IMPORT INTO &STAGESCM..COMMUNITY_AREAS FROM CSV AT 'https://data.cityofchicago.org/api/views/igwz-8jzy' FILE 'rows.csv?accessType=DOWNLOAD' SKIP=1;
