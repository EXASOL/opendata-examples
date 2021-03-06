-- refreshing the metadata for the dataset to check for new files
-- for delta-loads re-create the staging tbl and then re-load the data
CREATE OR REPLACE TABLE PRESCRIPTIONS_UK_STAGE.stage_raw_data_urls AS
SELECT  description, TO_NUMBER(period, '999999') period, site_url, file_name
FROM   (SELECT PRESCRIPTIONS_UK_STAGE.json_parsing_datapackage()) a
ORDER BY period;

MERGE
INTO    PRESCRIPTIONS_UK_STAGE.raw_data_urls tgt
USING   PRESCRIPTIONS_UK_STAGE.stage_raw_data_urls src
ON tgt.file_name = src.file_name
WHEN NOT MATCHED THEN
INSERT
	(
		description,
		period,
		site_url,
		file_name
	)
	VALUES
	(
		description,
		period,
		site_url,
		file_name
	);

-- cleanup dead URL 
DELETE FROM PRESCRIPTIONS_UK_STAGE.raw_data_urls WHERE SITE_URL LIKE '%datagov.ic.%';

--take a look at the new files to load
SELECT  *
FROM    PRESCRIPTIONS_UK_STAGE.raw_data_urls
WHERE   loaded_timestamp IS NULL;

--TIP: all data will be loaded, that has no loaded_timestamp.
--     If you want to load the data on a small machine, you can simply set a dummy loaded_timestamp
--     for older data e.g.:
-- update PRESCRIPTIONS_UK_STAGE.raw_data_urls set loaded_timestamp='0001-01-01 00:00:00' where period < 201810;

--this script loads all new data (delta load)
EXECUTE SCRIPT PRESCRIPTIONS_UK_STAGE.PRESCRIPTIONS_LOAD();
SELECT  *
FROM    PRESCRIPTIONS_UK_STAGE.JOB_DETAILS
ORDER BY run_id DESC,
	detail_id DESC;