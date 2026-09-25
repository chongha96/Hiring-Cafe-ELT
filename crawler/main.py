#Imports
import sys
from dotenv import load_dotenv, find_dotenv

from pyspark.sql import SparkSession
import logging

from crawler.src.utils.scraper import scrape_site
from crawler.src.utils.extract_data import select_data
from crawler.src.utils.formatter import process_data

#Creating basic logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - [%(name)s] - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("total_pipeline.log"),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


load_dotenv(find_dotenv())

#CONSTANTS
BASE_URL = "https://hiring.cafe/"
UNITED_STATES_SEARCH =[{"formatted_address": "United States"}]
DATE_SORT = "date"
DAYS = 1
RECONNECT_TIME = 6
TIMEOUT = 20



def init_spark_session():
    spark = (
        SparkSession.builder
        .appName("HiringCafe_GCS_Pipeline")
        .getOrCreate()
    )
    return spark



def main():
    logger.info("Running crawler...")
    raw_data = scrape_site(
        BASE_URL,
        UNITED_STATES_SEARCH,
        DATE_SORT,
        DAYS,
        RECONNECT_TIME,
        TIMEOUT
    )
    spark = init_spark_session()
    cleaned_df = process_data(raw_data, spark,'v5_processed_job_data')
    job_df = select_data(cleaned_df)
    
    job_df.write.mode("overwrite").parquet("/app/data/job_data")
    logger.info("Stopping Spark Environment...")
    spark.stop()

if __name__ == "__main__":
    main()