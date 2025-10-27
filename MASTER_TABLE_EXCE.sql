SELECT * FROM public.master_data;

DROP TABLE IF EXISTS "master_data";


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
    o."Batch_Code",
    o."Followup",
    o."Remark",   
    o."University" AS "Outreach_University",

    c."ID" AS "Campaign_ID",
    c."Name" AS "Campaign_Name",
    c."Category" AS "Campaign_Category",
    c."Intake" AS "Campaign_Intake",
    c."University" AS "Campaign_University",
    c."Status" AS "Campaign_Status",
    c."Start_Date",
    c."Stage"
FROM "applicant_data" a
LEFT JOIN "outreach_data" o
    ON a."App_ID" = o."Reference_ID"::BIGINT
LEFT JOIN "campaign_data" c
    ON o."University" = c."University";

SELECT * FROM "master_table";