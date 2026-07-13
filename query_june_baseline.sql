-- June (pre-banner, pre-MBG) baseline: whole active CSP network, full month.
-- Same funnel definitions as the segment query — used as the "before" reference.
SELECT
  COUNT(DISTINCT CSP_ID)                                                              AS active_csps,
  COUNT(DISTINCT CASE WHEN CONFIRMED_SLOT_AT IS NOT NULL THEN CSP_ID END)             AS slot_csps,
  COUNT(DISTINCT CASE WHEN EXECUTOR_ID IS NOT NULL THEN CSP_ID END)                   AS tech_csps,
  COUNT(DISTINCT CASE WHEN OTP_VERIFIED=TRUE OR COMPLETED_STEP>=7 THEN CSP_ID END)    AS install_csps,
  COUNT(*)                                                                            AS tasks,
  COUNT(CASE WHEN PROPOSED_SLOT_DATE IS NOT NULL THEN 1 END)                          AS t_slot_prop,
  COUNT(CASE WHEN CONFIRMED_SLOT_AT IS NOT NULL THEN 1 END)                           AS t_slot_conf,
  COUNT(CASE WHEN EXECUTOR_ID IS NOT NULL THEN 1 END)                                 AS t_tech,
  COUNT(CASE WHEN CURRENT_STATE='ARRIVED_AT_SITE' OR COMPLETED_STEP>=1 THEN 1 END)    AS t_arrived,
  COUNT(CASE WHEN OTP_VERIFIED=TRUE OR COMPLETED_STEP>=7 THEN 1 END)                  AS t_install
FROM PROD_DB.DBT_CSP.TAS_INSTALL_EXECUTION_CANDIDATES
WHERE ETL_CURRENT=TRUE AND CREATED_AT >= '2026-06-01' AND CREATED_AT < '2026-07-01'
