# University_Campaign_Analysis-Excelerate_intern_project-
University Campaign Analysis focused on validating and cleaning a massive multi-source dataset (initial ~24 lakh rows) using PostgreSQL. The project created a clean, accurate Master Table (594 rows) by removing duplicates, handling nulls, and enforcing business rules.

# University Campaign Analysis: Data Validation and Readiness

## 🎯 Project Overview

This project focuses on a comprehensive **University Campaign Analysis**, with a primary goal of ensuring **data integrity, accuracy, and reliability** before performing in-depth exploratory data analysis (EDA) and visualization.

The core of this work involved consolidating and rigorously validating a large-scale dataset (~24 lakh initial records) compiled from multiple sources related to a university's outreach and application campaign. The outcome is a clean, consistent, and decision-ready **Master Table** that serves as a trustworthy foundation for strategic decision-making and reporting.

---

## ✨ Key Features & Methodology

The project follows a rigorous data pipeline to transform raw data into a reliable source of truth.

### Data Sources Consolidation
[cite_start]The Master Table was built by integrating three core datasets[cite: 5, 466]:
* **Applicant Data:** Contains core applicant details.
* **Outreach Data:** Includes records of calls and interactions with applicants.
* [cite_start]**Campaign Data:** Details on the specific campaigns, categories, and intakes (e.g., GR GS FA24 Campaign, AY2024)[cite: 3].

### Data Validation and Cleaning Steps
[cite_start]The initial dataset contained nearly **24 lakh rows** [cite: 6, 8, 466] [cite_start]and was reduced to a final, validated count of **594 rows**[cite: 10, 26, 32].

Key cleaning operations performed include:

1.  **Duplicate Handling:**
    * [cite_start]Duplicates were identified using `App_ID` as the unique identifier[cite: 12].
    * [cite_start]For applicants with multiple entries (due to repeated outreach), only the **latest record** was preserved based on the `Time_Stamp` field[cite: 14, 15].

2.  **Missing Value Treatment (Nulls):**
    * [cite_start]**High-Null Column Pruning:** Columns with excessive null values, such as `Phone_Number`, `Reference_ID`, `Batch_Code`, `Followup`, `Outreach_University`, `Campaign_ID`, `Campaign_Status`, and `Campaign_University`, were permanently removed[cite: 16, 17, 27].
    * [cite_start]**Timestamp Validation:** Rows with missing values in critical time fields (`Received_At` or `Time_Stamp`) were deleted to maintain chronological integrity[cite: 18, 30].

3.  **Business Rule Checks:**
    * [cite_start]**App_ID Format:** Enforced a **6-digit structure** for all `App_ID` values[cite: 39, 27].
    * [cite_start]**Connectivity Rate:** Ensured all calculated connectivity rates fall strictly between 0 and 1[cite: 40].
    * [cite_start]**New Metrics Creation:** Introduced calculated columns for `Connected Calls`, `Disconnected Calls`, `Connectivity Rate`, and `Agent Performance` for richer analysis[cite: 47].

---

## 💻 Technology Stack

| Category | Tool | Purpose |
| :--- | :--- | :--- |
| **Database/Data Processing** | **PostgreSQL** | [cite_start]Used for data storage, all Exploratory Data Analysis (EDA), and executing complex SQL queries for data cleaning and validation (e.g., duplicate removal, null treatment, and business rule checks)[cite: 1, 27, 30, 468]. |
| **Data Visualization** | **Looker** (or Looker Studio/other BI) | [cite_start]Planned for creating meaningful visualizations, accurate metrics, and actionable insights based on the validated `Master_Table`[cite: 50]. |
| **Scripting Language** | **SQL** | Core language used for all data manipulation, validation, and transformation within the PostgreSQL environment. |
| **Documentation** | **Markdown** | Used for this comprehensive project README. |

---

## 📈 Results and Impact

The rigorous data validation process significantly improved the dataset's quality and usability:

* [cite_start]**Data Reduction:** The total row count was reduced from approximately **2,467,563** to **594**[cite: 9, 26], eliminating inflated and erroneous records.
* [cite_start]**Accurate Metrics:** Metrics like "Application In Progress" dropped from **11,178** records to **209**[cite: 32], providing a true count for the campaign outcomes.
* [cite_start]**Efficiency:** The resulting dataset is smaller, more manageable, and computationally efficient for downstream analysis[cite: 10].
* [cite_start]**Foundation for Decisions:** The clean and consistent data supports a strong basis for informed decisions, strategy development, and operational improvements[cite: 51].

---

## 🚀 Getting Started

To replicate the data validation and begin analysis:

### Prerequisites

* Install **PostgreSQL** 
* Access to **Looker** for visualization.

### Data Validation Steps (Conceptual SQL)

1.  **Load Data:** Import the `applicant_data`, `outreach_data`, and `campaign_data` into your PostgreSQL instance.
2.  **Create Master Table:** Join the three datasets into a single `master_table`.
3.  **Run Validation Scripts:** Execute the following high-level SQL commands (as demonstrated in the project):

    ```sql
    -- 1. Remove rows with missing critical timestamps
    DELETE FROM "master_table"
    WHERE "Received_At" IS NULL OR "Time_Stamp" IS NULL;

    -- 2. Enforce App_ID business rule (e.g., must be 6 digits)
    DELETE FROM "master_table"
    WHERE LENGTH("App_ID"::text) <> 6;

    -- 3. Remove high-null and redundant columns
    ALTER TABLE "master_table"
    DROP COLUMN "Phone_Number",
    DROP COLUMN "Reference_ID",
    DROP COLUMN "Batch_Code",
    ... -- (other high-null columns)

    -- 4. Eliminate Duplicates (The actual process involves identifying and keeping the latest record)
    -- (This step is more complex, typically involving window functions to select the latest timestamp per App_ID)
    ```

### Visualization

1.  Connect your **Looker** (or Looker Studio) instance to the validated **PostgreSQL Master Table**.
2.  Develop dashboards focused on campaign performance, applicant demographics, and outreach effectiveness.

---

## 🛠️ Recommendations for Future Data Governance

[cite_start]To maintain data quality moving forward[cite: 52, 53, 54]:

* **Automate Validation Pipelines:** Set up recurring scripts to continuously detect and handle duplicates, nulls, and invalid records.
* **Establish Data Quality KPIs:** Define metrics (e.g., Duplicate Ratio, Null Percentage) to monitor dataset health.
* **Implement Strong Data Entry Controls:** Enforce field validations at the source to prevent errors.

---

## 👥 Contributors

[cite_start]This project was developed by Team 016[cite: 463].
*(Include names of your team members here)*
* Farhan Hussain
* M. Nouman Arshad
* Shivansh Rajput
* Dia Agarwal
* Yuva Mirsha
* ...and others
