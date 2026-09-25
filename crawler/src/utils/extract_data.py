from pyspark.sql import DataFrame
from pyspark.sql.types import LongType, StringType, BooleanType, TimestampType
import pyspark.sql.functions as F

def select_data(df: DataFrame) -> DataFrame:
    return df.select(
        #Strings
        F.col("job.associates_degree_requirement").cast(StringType()).alias("associates_degree"),
        F.col("job.bachelors_degree_requirement").cast(StringType()).alias("bachelors_degree"),
        F.col("job.doctorate_degree_requirement").cast(StringType()).alias("doctorate_degree"),
        F.col("job.masters_degree_requirement").cast(StringType()).alias("masters_degree"),
        F.col("job.company_name").cast(StringType()).alias("company"),
        F.col("job.company_sector_and_industry").cast(StringType()).alias("company_sector"),
        F.col("job.listed_compensation_frequency").cast(StringType()).alias("compensation_format"),
        F.col("job.job_category").cast(StringType()).alias("job_category"),
        F.col("job.seniority_level").cast(StringType()).alias("job_level"),
        F.col("job.core_job_title").cast(StringType()).alias("job_title"),
        F.col("job.role_type").cast(StringType()).alias("job_type"),
        F.col("job.physical_labor_intensity").cast(StringType()).alias("physical_labor_level"),
        F.col("job.security_clearance").cast(StringType()).alias("security_clearance"),
        F.col("job.workplace_physical_environment").cast(StringType()).alias("work_environment"),
        F.col("job.workplace_type").cast(StringType()).alias("workplace"),
        F.col("job.land_travel_requirement").cast(StringType()).alias("travel_requirement"),
        F.col("job.morning_shift_work").cast(StringType()).alias("work_morning"),
        F.col("job.evening_shift_work").cast(StringType()).alias("work_evening"),
        F.col("job.overnight_work").cast(StringType()).alias("work_overnight"),
        F.col("job.weekend_availability_required").cast(StringType()).alias("work_weekends"),

        #Integers (INT64)
        F.col("job.bi-weekly_max_compensation").cast(LongType()).alias("biweekly_comp_max"),
        F.col("job.bi-weekly_min_compensation").cast(LongType()).alias("biweekly_comp_min"),
        F.col("job.daily_max_compensation").cast(LongType()).alias("daily_comp_max"),
        F.col("job.daily_min_compensation").cast(LongType()).alias("daily_comp_min"),
        F.col("job.hourly_max_compensation").cast(LongType()).alias("hourly_comp_max"),
        F.col("job.hourly_min_compensation").cast(LongType()).alias("hourly_comp_min"),
        F.col("job.monthly_max_compensation").cast(LongType()).alias("monthly_comp_max"),
        F.col("job.monthly_min_compensation").cast(LongType()).alias("monthly_comp_min"),
        F.col("job.weekly_max_compensation").cast(LongType()).alias("weekly_comp_max"),
        F.col("job.weekly_min_compensation").cast(LongType()).alias("weekly_comp_min"),
        F.col("job.yearly_max_compensation").cast(LongType()).alias("yearly_comp_max"),
        F.col("job.yearly_min_compensation").cast(LongType()).alias("yearly_comp_min"),
        F.col("job.min_industry_and_role_yoe").cast(LongType()).alias("job_yoe"),
        F.col("job.min_management_and_leadership_yoe").cast(LongType()).alias("management_yoe"),

        #Booleans
        F.col("job.is_driver_license_required").cast(BooleanType()).alias("drivers_license"),
        F.col("job.401k_matching").cast(BooleanType()).alias("has_401k"),
        F.col("job.is_high_school_required").cast(BooleanType()).alias("hs_degree"),
        F.col("job.on_call_requirement").cast(BooleanType()).alias("on_call"),
        F.col("job.overtime_required").cast(BooleanType()).alias("overtime"),
        F.col("job.relocation_assistance").cast(BooleanType()).alias("relocation_assistance"),
        F.col("job.retirement_plan").cast(BooleanType()).alias("retirement"),
        F.col("job.visa_sponsorship").cast(BooleanType()).alias("sponsorship"),
        F.col("job.tuition_reimbursement").cast(BooleanType()).alias("tuition_reimbursement"),
        F.col("job.holiday_availability_required").cast(BooleanType()).alias("work_holidays"),

        #Timestamp
        F.col("job.estimated_publish_date").cast(TimestampType()).alias("date_posted"),

        #Nested/Complex
        F.col("job.associates_degree_fields_of_study").alias("associates_field"),
        F.col("job.bachelors_degree_fields_of_study").alias("bachelors_field"),
        F.col("job.licenses_or_certifications").alias("certifications"),
        F.col("job.workplace_cities").alias("city"),
        F.col("job.commitment").alias("commitment"),
        F.col("job.company_activities").alias("company_activities"),
        F.col("job.workplace_continents").alias("continent"),
        F.col("job.workplace_countries").alias("country"),
        F.col("job.doctorate_degree_fields_of_study").alias("doctorate_field"),
        F.col("job.role_activities").alias("job_activities"),
        F.col("job.language_requirements").alias("language"),
        F.col("job.masters_degree_fields_of_study").alias("masters_field"),
        F.col("job.workplace_states").alias("state"),
        F.col("job.technical_tools").alias("technical_tools")
    )