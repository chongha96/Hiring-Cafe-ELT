# <u>Data Dictionary</u>

Outline of the data model (star schema) for this project.



**Fact grain:** 1 row per job posting (`job_id`).

**Keys:**
- Dimension tables use surrogate keys for enforce unique rows.
- The fact table stores foreign keys to each nonbridged dimension.
- Multi-valued attributes (e.g., locations, languages, tools, certifications, fields of study) use bridge tables to prevent M:M relationship.

**Type conventions:**
- `UUID` for surrogate keys
- `TIMESTAMP` for event time
- `BOOL` for boolean flags
- `VARCHAR(n)` for strings
- `INT` for integer measures
- `DECIMAL(p,s)` for currency-like numeric values

## <u>Table of Contents</u>

### <u>Fact</u>
* [fact_job_posting](#fact_job_posting)

### <u>Dimensions</u>
* [dim_company](#dim_company)
* [dim_work_condition](#dim_work_condition)
* [dim_work_requirement](#dim_work_requirement)
* [dim_benefits](#dim_benefits)
* [dim_education](#dim_education)
* [dim_location](#dim_location)
* [dim_language](#dim_language)
* [dim_tool](#dim_tool)
* [dim_certification](#dim_certification)
* [dim_field_of_study](#dim_field_of_study)

### <u>Bridge Tables</u>
* [bridge_job_tool](#bridge_job_tool)
* [bridge_job_certification](#bridge_job_certification)
* [bridge_job_field_of_study](#bridge_job_field_of_study)
* [bridge_job_location](#bridge_job_location)

---

## fact_job_posting
Contains the core measures and foreign keys for job postings (1 row per job posting).

| Column Name           | Data Type        | Nullable? | Description                                                                 | Example / Constraints                          |
|:----------------------|:-----------------|:---------:|:----------------------------------------------------------------------------|:-----------------------------------------------|
| `job_id`              | `UUID`           |    No     | Unique identifier and Primary Key for the job posting.                     | `f81d4fae-7dec-11d0-a765-00a0c91e6bf6`         |
| `date_posted`         | `TIMESTAMP`      |    Yes    | Timestamp when the job posting was published/estimated published.          | `2026-01-01 23:59:59 UTC`                      |
| `company_id`          | `UUID`           |    Yes    | FK to `dim_company`.                                                      | `...`                                          |
| `condition_id`        | `UUID`           |    Yes    | FK to `dim_work_condition`.                                               | `...`                                          |
| `requirement_id`      | `UUID`           |    Yes    | FK to `dim_work_requirement`.                                             | `...`                                          |
| `benefit_id`          | `UUID`           |    Yes    | FK to `dim_benefits`.                                                     | `...`                                          |
| `education_id`        | `UUID`           |    Yes    | FK to `dim_education`.                                                    | `...`                                          |
| `job_title`           | `VARCHAR(255)`   |    Yes    | Job title text as listed (degenerate dimension attribute on the fact).     | `Software Engineer`                            |
| `job_level`           | `VARCHAR(50)`    |    Yes    | Seniority level as listed.                                                | `Entry`, `Mid`, `Senior`                       |
| `job_type`            | `VARCHAR(50)`    |    Yes    | Role type as listed.                                                      | `Individual Contributor`, `People Manager`     |
| `job_yoe`             | `INT`            |    Yes    | Minimum years of experience required (if provided).                        | `1`                                            |
| `management_yoe`      | `INT`            |    Yes    | Minimum years of management experience required (if provided).             | `1`                                            |
| `compensation_format` | `VARCHAR(20)`    |    Yes    | Compensation frequency/format as listed.                                   | `Hourly`, `Weekly`, `Monthly`, `Yearly`        |
| `comp_min`    | `DECIMAL(12,2)`  |    Yes    | Minimum compensation amount in the listed format.                          | `100000.00`                                    |
| `comp_max`    | `DECIMAL(12,2)`  |    Yes    | Maximum compensation amount in the listed format.                          | `140000.00`                                    |

---

## dim_company
Contains company-level information.

| Column Name      | Data Type      | Nullable? | Description                                 | Example / Constraints                  |
|:-----------------|:---------------|:---------:|:--------------------------------------------|:---------------------------------------|
| `company_id`     | `UUID`         |    No     | Unique identifier and Primary Key.          | `f81d4fae-7dec-11d0-a765-00a0c91e6bf6` |
| `company_name`   | `VARCHAR(255)` |    Yes    | Name of the company for the job position.   | `Walmart`                              |
| `company_sector` | `VARCHAR(100)` |    Yes    | Sector/industry grouping.                   | `Retail`                               |
| `job_category`   | `VARCHAR(100)` |    Yes    | Job function/category as listed.            | `Sales`                                |

---

## dim_work_condition
Contains the work setting and environment information.

| Column Name        | Data Type      | Nullable? | Description                               | Example / Constraints  |
|:-------------------|:---------------|:---------:|:------------------------------------------|:-----------------------|
| `condition_id`     | `UUID`         |    No     | Unique identifier and Primary Key.        | `f81d4fae-...`         |
| `work_setting`     | `VARCHAR(50)`  |    Yes    | Work setting type.                        | `Onsite`, `Remote`     |
| `work_environment` | `VARCHAR(100)` |    Yes    | Physical environment type.                | `Office`, `Industrial` |

---

## dim_work_requirement
Contains core job requirements and expectations information.

| Column Name            | Data Type     | Nullable? | Description                                                | Example / Constraints                  |
|:-----------------------|:--------------|:---------:|:-----------------------------------------------------------|:---------------------------------------|
| `requirement_id`       | `UUID`        |    No     | Unique identifier and Primary Key.                         | `f81d4fae-...`                         |
| `work_morning`         | `VARCHAR(20)` |    Yes    | Morning shift expectation.                                 | `Optional`, `Required`, `Not Indicated`|
| `work_evening`         | `VARCHAR(20)` |    Yes    | Evening shift expectation.                                 | `Optional`, `Required`, `Not Indicated`|
| `work_overnight`       | `VARCHAR(20)` |    Yes    | Overnight shift expectation.                               | `Optional`, `Required`, `Not Indicated`|
| `work_weekends`        | `BOOL`        |    Yes    | Whether weekend work is required (if explicitly provided). | `True`, `False`                        |
| `work_holidays`        | `VARCHAR(20)` |    Yes    | Whether holday work is required (if explicitly provided).  | `True`, `False`      |
| `on_call`              | `BOOL`        |    Yes    | Whether on-call is expected.                               | `True`, `False`                        |
| `overtime`             | `BOOL`        |    Yes    | Whether overtime is required/expected (when provided).     | `True`, `False`                        |
| `physical_labor_level` | `INT`         |    Yes    | Physical labor intensity level (project-defined scale).    | `1` (low) … `3` (high)                 |
| `drivers_license`      | `BOOL`        |    Yes    | Whether a driver's license is required.                    | `True`, `False`                        |
| `security_clearance`   | `BOOL`        |    Yes    | Whether a security clearance is required.                  | `True`, `False`                        |
| `travel_requirements`  | `INT`         |    Yes    | Travel requirement level (project-defined scale).          | `0` (none) … `3` (extensive)           |

---

## dim_benefits
Contains workplace benefits offered for the listed position.

| Column Name                 | Data Type | Nullable? | Description                                                     | Example / Constraints                  |
|:----------------------------|:----------|:---------:|:----------------------------------------------------------------|:---------------------------------------|
| `benefit_id`                | `UUID`    |    No     | Unique identifier and Primary Key.                              | `f81d4fae-...`                         |
| `has_401k`                  | `BOOL`    |    Yes    | Whether the position includes 401k matching.                     | `True`, `False`                        |
| `has_tuition_reimbursement` | `BOOL`    |    Yes    | Whether tuition reimbursement is offered.                        | `True`, `False`                        |
| `has_relocation`            | `BOOL`    |    Yes    | Whether relocation assistance is offered.                        | `True`, `False`                        |
| `has_visa_sponsorship`      | `BOOL`    |    Yes    | Whether visa sponsorship is offered.                             | `True`, `False`                        |
| `has_retirement`            | `BOOL`    |    Yes    | Whether an employer retirement plan is offered (non-401k or any).| `True`, `False`                        |

---

## dim_education
Contains education requirements/preference.

| Column Name            | Data Type     | Nullable? | Description                                    | Example / Constraints                           |
|:-----------------------|:--------------|:---------:|:-----------------------------------------------|:------------------------------------------------|
| `education_id`         | `UUID`        |    No     | Unique identifier and Primary Key.             | `f81d4fae-...`                                  |
| `min_required_degree`  | `VARCHAR(50)` |    Yes    | Minimum required degree level (if indicated).  | `None`, `Associates`, `Bachelors`, `Masters`    |
| `max_required_degree`  | `VARCHAR(50)` |    Yes    | Maximum required degree level (if indicated).  | `None`, `Associates`, `Bachelors`, `Masters`    |
| `min_preferred_degree` | `VARCHAR(50)` |    Yes    | Minimum preferred degree level (if indicated). | `None`, `Associates`, `Bachelors`, `Masters`    |
| `max_preferred_degree` | `VARCHAR(50)` |    Yes    | Maximum preferred degree level (if indicated). | `None`, `Associates`, `Bachelors`, `Masters`    |

---

## dim_location
Contains geographic locations where the job is located.

| Column Name    | Data Type      | Nullable? | Description                         | Example / Constraints      |
|:---------------|:---------------|:---------:|:------------------------------------|:---------------------------|
| `location_id`  | `UUID`         |    No     | Unique identifier and Primary Key.  | `f81d4fae-...`             |
| `country_name` | `VARCHAR(100)` |    Yes    | Country name.                       | `United States`            |
| `state_name`   | `VARCHAR(100)` |    Yes    | State/region/province.              | `California`               |
| `city_name`    | `VARCHAR(100)` |    Yes    | City name.                          | `San Francisco`            |

---

## dim_language
Contains a language required for the job.

| Column Name     | Data Type      | Nullable? | Description                        | Example / Constraints |
|:----------------|:---------------|:---------:|:-----------------------------------|:----------------------|
| `language_id`   | `UUID`         |    No     | Unique identifier and Primary Key. | `f81d4fae-...`        |
| `language_name` | `VARCHAR(100)` |    No     | Language name.                     | `English`             |

---

## dim_tool
Contains a technical tool or technology for the job.

| Column Name | Data Type      | Nullable? | Description                        | Example / Constraints |
|:------------|:---------------|:---------:|:-----------------------------------|:----------------------|
| `tool_id`   | `UUID`         |    No     | Unique identifier and Primary Key. | `f81d4fae-...`        |
| `tool_name` | `VARCHAR(255)` |    No     | Tool/technology name.              | `Python`              |

---

## dim_certification
Contains a certification or license for the job.

| Column Name          | Data Type      | Nullable? | Description                        | Example / Constraints |
|:---------------------|:---------------|:---------:|:-----------------------------------|:----------------------|
| `certification_id`   | `UUID`         |    No     | Unique identifier and Primary Key. | `f81d4fae-...`        |
| `certification_name` | `VARCHAR(255)` |    No     | Certification/license name.         | `CPA`                 |

---

## dim_field_of_study
Contains a field of study for the job.

| Column Name   | Data Type      | Nullable? | Description                        | Example / Constraints     |
|:--------------|:---------------|:---------:|:-----------------------------------|:--------------------------|
| `field_id`    | `UUID`         |    No     | Unique identifier and Primary Key. | `f81d4fae-...`            |
| `field_name`  | `VARCHAR(255)` |    No     | Field of study name.               | `Computer Science`        |


---

## bridge_job_tool
Bridge table linking a job posting to one or more technical tools.

| Column Name | Data Type | Nullable? | Description               | Example / Constraints |
|:------------|:----------|:---------:|:--------------------------|:----------------------|
| `job_id`    | `UUID`    |    No     | FK to `fact_job_posting`. | `...`                 |
| `tool_id`   | `UUID`    |    No     | FK to `dim_tool`.         | `...`                 |

---

## bridge_job_certification
Bridge table linking a job posting to one or more certifications/licenses.

| Column Name        | Data Type | Nullable? | Description                 | Example / Constraints |
|:-------------------|:----------|:---------:|:----------------------------|:----------------------|
| `job_id`           | `UUID`    |    No     | FK to `fact_job_posting`.   | `...`                 |
| `certification_id` | `UUID`    |    No     | FK to `dim_certification`.  | `...`                 |

---

## bridge_job_field_of_study
Bridge table linking a job posting to one or more fields of study.

| Column Name     | Data Type     | Nullable? | Description                                              | Example / Constraints                    |
|:----------------|:--------------|:---------:|:---------------------------------------------------------|:-----------------------------------------|
| `job_id`        | `UUID`        |    No     | FK to `fact_job_posting`.                                | `...`                                    |
| `field_id`      | `UUID`        |    No     | FK to `dim_field_of_study`.                              | `...`                                    |

## bridge_job_location
Bridge table linking a job posting to one or more locations.

| Column Name   | Data Type     | Nullable? | Description               | Example / Constraints                    |
|:--------------|:--------------|:---------:|:--------------------------|:-----------------------------------------|
| `job_id`      | `UUID`        |    No     | FK to `fact_job_posting`. | `...`                                    |
| `location_id` | `UUID`        |    No     | FK to `dim_location`.     | `...`                                    |
 
## bridge_job_language
Bridge table linking a job posting to one or more languages.

| Column Name   | Data Type     | Nullable? | Description               | Example / Constraints                    |
|:--------------|:--------------|:---------:|:--------------------------|:-----------------------------------------|
| `job_id`      | `UUID`        |    No     | FK to `fact_job_posting`. | `...`                                    |
| `language_id` | `UUID`        |    No     | FK to `dim_language`.     | `...`                                    |
 