from pyspark.sql import SparkSession
import pyspark.sql.functions as F
from pyspark.sql import DataFrame
import json
import logging

logger = logging.getLogger(__name__)

logging.basicConfig(filename='formatter.log',level=logging.INFO)

'''
Steps:
1. Insert JSON String to a single record in a Spark DF
2. Splits the record based on jd_regex, creating multiple rows for each instance
3. Explode the column to separate all the headers under the desired section
4. Removing trailing objects between the v5_job_processed_data objects
5. Create schema based on the first job
6. Parse the data and remove duplicates
'''
def process_data(json_data: dict, spark: SparkSession, header: str)-> DataFrame:
    logger.info("Beginning to Process Data: Dumping JSON")
    json_string = json.dumps(json_data)
    logger.info("Inserting json dump into Spark DF")
    raw_df = spark.createDataFrame([(json_string,)], ["raw_json"])
    jd_regex = rf'"{header}"\s*:\s*'
    map_schema = "MAP<STRING, STRING>"
    logger.info("Splitting the DF based on JSON header: individual_jobs")
    split_df = raw_df.withColumn(
        "individual_jobs",
        F.split(F.col("raw_json"), jd_regex)
    )
    logger.info("Exploding each array within 'individual_jobs', outputting as columns 'pos' and 'job_text'")
    #Filtering out first column/position as it is a header rather than information
    explode_df = split_df.select(
        F.posexplode(F.col("individual_jobs")).alias("pos", "job_text")
    ).filter(F.col("pos") > 0)

    logger.info("Searching DF for job objects, filtering for empty objects")
    keep_only_job = explode_df.withColumn(
        "clean_job_obj",
        F.regexp_extract(F.col("job_text"), r"^(\{.*?\})", 1)
    ).filter(F.col("clean_job_obj") != "")


    sample_job = keep_only_job.select("clean_job_obj").first()["clean_job_obj"]

    logger.info("Creating DDL schema based on sample job")
    job_schema = spark.range(1).select(
        F.schema_of_json(F.lit(sample_job))
    ).collect()[0][0]

    logger.info("Creating Job object column")
    parsed_df = keep_only_job.withColumn(
        "job",
        F.from_json(F.col("clean_job_obj"), job_schema)
    )
    logger.info("Promoting core_job_title and company_name to top-level DF column")
    temp_df = parsed_df.withColumn("core_job_title", F.col("job.core_job_title")) \
        .withColumn("company_name", F.col("job.company_name"))

    initial_jobs_count = temp_df.count()

    logger.info("Dropping any duplicate jobs...")
    dedupe_df = temp_df.dropDuplicates(["core_job_title", "company_name"])

    deduped_jobs_count = dedupe_df.count()

    if (deduped_jobs_count == initial_jobs_count):
        logger.info("No duplicates identified, creating finalized DF")
    else:
        logger.info(f"Duplicates identified: {deduped_jobs_count - initial_jobs_count} rows removed")

    #Dedupe rows before rturning
    final_df = dedupe_df.dropDuplicates(["core_job_title", "company_name"])

    logger.info(f"Extracted {final_df.count()} jobs")

    return final_df

