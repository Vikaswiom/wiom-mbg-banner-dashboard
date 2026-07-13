-- CSP completion-rate distribution: June vs July (month-to-date), two events only
-- (task assigned = a TAS candidate row; final WiFi install = OTP verified / step>=7).
-- Per CSP: rate = installs / tasks_given. Filtered to CSPs with >=5 tasks (a real
-- workload; avoids 1-task 100% flukes). July excludes the last 2 days so its tasks
-- have had time to resolve (~97% of installs land within 3 days) — a fair match to
-- fully-matured June. NOTE: measures the new F1 OS app pipeline only.
WITH j AS (
  SELECT CSP_ID,
    CASE WHEN CREATED_AT >= '2026-06-01' AND CREATED_AT < '2026-07-01' THEN 'June'
         WHEN CREATED_AT >= '2026-07-01' AND CREATED_AT < DATEADD('day',-2,CURRENT_DATE) THEN 'July' END AS period,
    COUNT(*) AS tasks,
    SUM(CASE WHEN OTP_VERIFIED=TRUE OR COMPLETED_STEP>=7 THEN 1 ELSE 0 END) AS installs
  FROM PROD_DB.DBT_CSP.TAS_INSTALL_EXECUTION_CANDIDATES
  WHERE ETL_CURRENT=TRUE AND CREATED_AT >= '2026-06-01'
  GROUP BY CSP_ID, period
),
r AS ( SELECT period, tasks, installs, installs/tasks::float AS rate FROM j WHERE period IS NOT NULL AND tasks>=5 )
SELECT period,
  COUNT(*) AS csps, SUM(tasks) AS tasks, SUM(installs) AS installs,
  ROUND(100.0*SUM(installs)/SUM(tasks),1) AS overall_rate,
  COUNT(CASE WHEN rate=0 THEN 1 END)                  AS b0,
  COUNT(CASE WHEN rate>0 AND rate<0.2 THEN 1 END)     AS b1,
  COUNT(CASE WHEN rate>=0.2 AND rate<0.4 THEN 1 END)  AS b2,
  COUNT(CASE WHEN rate>=0.4 AND rate<0.6 THEN 1 END)  AS b3,
  COUNT(CASE WHEN rate>=0.6 AND rate<0.8 THEN 1 END)  AS b4,
  COUNT(CASE WHEN rate>=0.8 THEN 1 END)               AS b5,
  COUNT(CASE WHEN rate>=0.6 THEN 1 END)               AS ge60
FROM r GROUP BY period ORDER BY period
