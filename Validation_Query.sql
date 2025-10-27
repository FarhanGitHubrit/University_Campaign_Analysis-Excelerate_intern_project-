SELECT * FROM public.master_table;


------ The new master_table is a consolidated dataset combining applicants, outreach activity, 
----and campaigns, along with new performance metrics:

---Applicant Info - App_ID, Country, University, etc.

---Outreach Info - call outcomes, timestamps, remarks.

---Campaign Info - campaign name, status, intake.

---Metrics - connected calls, disconnected calls, connectivity rate, and agent performance.


--This query merges applicant, outreach, and campaign data into one table, then adds calculated KPIs 
--(connectivity rate, performance categories) to evaluate how effective outreach calls were.

DROP TABLE IF EXISTS "master_table";

CREATE TABLE "master_table" AS
SELECT
    a."App_ID",
    a."Country" AS "Applicant_Country",
    a."University" AS "Applicant_University",
    a."Phone_Number",

    o."Reference_ID",
    o."Received_At",
    o."Time_Stamp",
    o."Caller_Name",
    o."Outcome",
    o."Remark",   
    o."Batch_Code",
    o."Followup",
    o."University" AS "Outreach_University",

    c."ID" AS "Campaign_ID",
    c."Name" AS "Campaign_Name",
    c."Category" AS "Campaign_Category",
    c."Intake" AS "Campaign_Intake",
    c."University" AS "Campaign_University",
    c."Status" AS "Campaign_Status",
    c."Start_Date",
    c."Stage",

    -- New Metrics
    CASE 
        WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                             'Visa Related','Application In Progress',
                             'Pending Documents','Scholarship Related',
                             'Loan/Bank Document Query','I-20 Related Issue')
        THEN 1 ELSE 0 END AS "Connected_Calls",

    CASE 
        WHEN o."Outcome" IN ('No Response','Disconnected','Invalid Number')
        THEN 1 ELSE 0 END AS "Disconnected_Calls",

    CASE 
        WHEN (CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                        'Visa Related','Application In Progress',
                                        'Pending Documents','Scholarship Related',
                                        'Loan/Bank Document Query','I-20 Related Issue')
                   THEN 1 ELSE 0 END
             +
             CASE WHEN o."Outcome" IN ('No Response','Disconnected','Invalid Number')
                  THEN 1 ELSE 0 END) > 0
        THEN ROUND(
            (CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                       'Visa Related','Application In Progress',
                                       'Pending Documents','Scholarship Related',
                                       'Loan/Bank Document Query','I-20 Related Issue')
                  THEN 1 ELSE 0 END)::numeric
            /
            ((CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                        'Visa Related','Application In Progress',
                                        'Pending Documents','Scholarship Related',
                                        'Loan/Bank Document Query','I-20 Related Issue')
                   THEN 1 ELSE 0 END)
             +
             (CASE WHEN o."Outcome" IN ('No Response','Disconnected','Invalid Number')
                   THEN 1 ELSE 0 END)),2)
        ELSE NULL END AS "Connectivity_Rate",

    CASE 
        WHEN (CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                        'Visa Related','Application In Progress',
                                        'Pending Documents','Scholarship Related',
                                        'Loan/Bank Document Query','I-20 Related Issue')
                   THEN 1 ELSE 0 END
             +
             CASE WHEN o."Outcome" IN ('No Response','Disconnected','Invalid Number')
                  THEN 1 ELSE 0 END) > 0
        THEN CASE 
            WHEN ROUND((CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                                 'Visa Related','Application In Progress',
                                                 'Pending Documents','Scholarship Related',
                                                 'Loan/Bank Document Query','I-20 Related Issue')
                              THEN 1 ELSE 0 END)::numeric
                      /
                      ((CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                                  'Visa Related','Application In Progress',
                                                  'Pending Documents','Scholarship Related',
                                                  'Loan/Bank Document Query','I-20 Related Issue')
                             THEN 1 ELSE 0 END)
                       +
                       (CASE WHEN o."Outcome" IN ('No Response','Disconnected','Invalid Number')
                             THEN 1 ELSE 0 END)),2) >= 0.7
                THEN 'Good'
            WHEN ROUND((CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                                 'Visa Related','Application In Progress',
                                                 'Pending Documents','Scholarship Related',
                                                 'Loan/Bank Document Query','I-20 Related Issue')
                              THEN 1 ELSE 0 END)::numeric
                      /
                      ((CASE WHEN o."Outcome" IN ('Interested','Not Interested','Pending Decision',
                                                  'Visa Related','Application In Progress',
                                                  'Pending Documents','Scholarship Related',
                                                  'Loan/Bank Document Query','I-20 Related Issue')
                             THEN 1 ELSE 0 END)
                       +
                       (CASE WHEN o."Outcome" IN ('No Response','Disconnected','Invalid Number')
                             THEN 1 ELSE 0 END)),2) >= 0.4
                THEN 'Average'
            ELSE 'Poor'
        END
    ELSE NULL END AS "Agent_Performance"

FROM "applicant_data" a
LEFT JOIN "outreach_data" o
    ON a."App_ID" = o."Reference_ID"::BIGINT
LEFT JOIN "campaign_data" c
    ON o."University" = c."University";




----- Deleting those fields where the app id is more than 6 in length as it is inappropriate-------------

DELETE FROM "master_table"
WHERE LENGTH("App_ID"::text) <> 6;




------- Dropped some inappropriate column which is not in use for any analysis case-------------

ALTER TABLE "master_table"
DROP COLUMN "Phone_Number",
DROP COLUMN "Reference_ID",
DROP COLUMN "Batch_Code",
DROP COLUMN "Followup",
DROP COLUMN "Outreach_University",
DROP COLUMN "Campaign_ID",
DROP COLUMN "Campaign_Status",
DROP COLUMN "Campaign_University";



------ creating some new metrics like connected, disconnected calls, and agent performance as average poor, etc.-----

UPDATE "master_table"
SET "Agent_Performance" = CASE 
    WHEN ("Connected_Calls" + "Disconnected_Calls") > 0
    THEN CASE 
        WHEN ROUND("Connected_Calls"::numeric / NULLIF(("Connected_Calls" + "Disconnected_Calls"),0), 2) >= 0.7
            THEN 'Good'
        WHEN ROUND("Connected_Calls"::numeric / NULLIF(("Connected_Calls" + "Disconnected_Calls"),0), 2) >= 0.4
            THEN 'Average'
        ELSE 'Poor'
    END
    ELSE 'Not Evaluated'   -- fallback when no calls
END;




----- deleteing field where values are null. this can sause problems in analysis -------------

DELETE FROM "master_table"
WHERE "Received_At" IS NULL
   OR "Time_Stamp" IS NULL;











 --------- Performing Validation---------------------
 -- Count total rows in cleaned table
 
SELECT COUNT(*) AS total_records 
FROM "master_table";



-- Check duplicate rows based on unique identifier

SELECT "App_ID", COUNT(*) 
FROM "master_table"
GROUP BY "App_ID"
HAVING COUNT(*) > 1;



-- Remove duplicate rows from master_table_cleaned

DELETE FROM "master_table"
WHERE ctid NOT IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY "App_ID"
                   ORDER BY "Time_Stamp" DESC   -- keep latest row
               ) AS rn
        FROM "master_table"
    ) t
    WHERE rn = 1
);


-- Count missing values column-wise
SELECT 
    SUM(CASE WHEN "App_ID" IS NULL THEN 1 ELSE 0 END) AS missing_app_id,
    SUM(CASE WHEN "Applicant_Country" IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN "Applicant_University" IS NULL THEN 1 ELSE 0 END) AS missing_university,
    SUM(CASE WHEN "Outcome" IS NULL THEN 1 ELSE 0 END) AS missing_outcome,
    SUM(CASE WHEN "Campaign_Name" IS NULL THEN 1 ELSE 0 END) AS missing_campaign
FROM "master_table";


----Checking Connectivity Rate is between 0 and 1
SELECT COUNT(*) AS invalid_connectivity
FROM "master_table"
WHERE "Connectivity_Rate" < 0 OR "Connectivity_Rate" > 1;


--- Checking Agen performance label

SELECT DISTINCT "Agent_Performance"
FROM "master_table";


-- Checking for unexpected Stage values

SELECT DISTINCT "Stage"
FROM "master_table";


-- List unique call outcomes

SELECT DISTINCT "Outcome"
FROM "master_table";



-- Check distinct campaign statuses

SELECT DISTINCT "Campaign_Intake"
FROM "master_table";
