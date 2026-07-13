-- Partner-level install EFFICIENCY, June (pre-MBG) vs July (MBG live from 01 Jul),
-- by MBG enrolment bucket. Efficiency is measured PER PARTNER PER BOOKING assigned:
--   * one candidate row = one (booking, partner) assignment; a booking is assigned to
--     ~1.84 partners on avg, and exactly one of them installs it.
--   * per partner: tasks = distinct bookings assigned; installs = those it completed.
--     e.g. booking given to P1 & P2, P2 installs -> P1 = 0/1, P2 = 1/1.
--   * efficiency = installs / tasks; 60%+ = eff >= 0.60 (floored to >=3 bookings so
--     single-booking 100%/0% flukes don't distort the partner count).
-- July bucketed 01 Jul -> CURRENT_DATE-2 (install-matured; ~97% resolve within 3 days);
-- June = full month. Bucket via CSP_ACCOUNT partner_id->csp_id from the belief-break
-- enrolment audit: enrolled = audit done (461 csp) · eligible = offered, not enrolled
-- (108 csp) · nonmbg = everyone else. Scope: new F1 OS app pipeline only.
WITH pc AS (  -- collapse to one row per (partner, booking)
  SELECT CSP_ID, CONNECTION_ID,
    MAX(CASE WHEN INSTALLATION_COMPLETED_AT IS NOT NULL THEN 1 ELSE 0 END) AS installed,
    CASE WHEN DATE_TRUNC('month', MIN(CREATED_AT)) = '2026-06-01' THEN 'june'
         WHEN MIN(CREATED_AT) >= '2026-07-01'
              AND MIN(CREATED_AT) < DATEADD('day', -2, CURRENT_DATE) THEN 'july'
    END AS period
  FROM PROD_DB.DBT_CSP.TAS_INSTALL_EXECUTION_CANDIDATES
  WHERE ETL_CURRENT = TRUE
    AND (DATE_TRUNC('month', CREATED_AT) = '2026-06-01' OR CREATED_AT >= '2026-07-01')
  GROUP BY CSP_ID, CONNECTION_ID
),
per_csp AS (
  SELECT CSP_ID, period,
    COUNT(*) AS tasks, SUM(installed) AS installs,
    SUM(installed) / COUNT(*)::float AS eff,
    CASE WHEN CSP_ID IN ('a0a6y4','a0a6y6','a0a6y9','a0a6z0','a0a6z1','a0a6z2','a0a6z3','a0a6z4','a0a6z7','a0a6z8','a0a7a0','a0a7a2','a0a7a3','a0a7a4','a0a7a5','a0a7a6','a0a7a7','a0a7a9','a0a7b1','a0a7b2','a0a7b3','a0a7b4','a0a7b5','a0a7b6','a0a7b7','a0a7b8','a0a7b9','a0a7c0','a0a7c1','a0a7c2','a0a7c4','a0a7c7','a0a7d2','a0a7d3','a0a7d4','a0a7d9','a0a7e3','a0a7e4','a0a7f5','a0a7f7','a0a7f8','a0a7g0','a0a7g2','a0a7g3','a0a7g5','a0a7g6','a0a7g7','a0a7g9','a0a7h0','a0a7h2','a0a8a5','a0a9d4','a0a9j4','a0a9m4','a0a9o4','a0a9s3','a0a9w2','a0b0a0','a0b0n9','a0b0w0','a0b1b5','a0b2w1','a0b3l5','a0b3m4','a0b5l8','a0b5l9','a0b5m0','a0b5m1','a0b5m3','a0b5m5','a0b5m6','a0b5n2','a0b5n3','a0b5n4','a0b5n7','a0b5n8','a0b5o0','a0b5o3','a0b5o4','a0b5o5','a0b5p0','a0b5p5','a0b5p7','a0b5q6','a0b5q7','a0b5r2','a0b5r4','a0b5r7','a0b5r9','a0b5s4','a0b5t0','a0b5t3','a0b5t5','a0b5t9','a0b5u1','a0b5u8','a0b5v0','a0b5v3','a0b5v4','a0b5v5','a0b5v7','a0b5v8','a0b5w1','a0b5w4','a0b5w5','a0b5w9','a0b5x0','a0b5x1','a0b5y1','a0b5y3','a0b5y5','a0b5y6','a0b5y9','a0b5z0','a0b5z1','a0b5z6','a0b5z7','a0b6a1','a0b6a3','a0b6a6','a0b6a8','a0b6a9','a0b6b0','a0b6b1','a0b6b2','a0b6b5','a0b6b8','a0b6c4','a0b6c5','a0b6c6','a0b6d0','a0b6d1','a0b6d3','a0b6d4','a0b6d8','a0b6e0','a0b6e2','a0b6e3','a0b6e6','a0b6e7','a0b6e8','a0b6f0','a0b6f1','a0b6f2','a0b6f3','a0b6f5','a0b6f6','a0b6f7','a0b6f8','a0b6f9','a0b6g1','a0b6g2','a0b6g6','a0b6g9','a0b6h2','a0b6h3','a0b6h4','a0b6h5','a0b6h6','a0b6h7','a0b6h8','a0b6h9','a0b6i0','a0b6i1','a0b6i2','a0b6i4','a0b6i8','a0b6j2','a0b6j7','a0b6j8','a0b6k4','a0b6k8','a0b6l0','a0b6l2','a0b6l3','a0b6l6','a0b6l7','a0b6m0','a0b6m3','a0b6m4','a0b6m6','a0b6n2','a0b6n3','a0b6o1','a0b6o2','a0b6o4','a0b6o5','a0b6o8','a0b6p0','a0b6p1','a0b6p3','a0b6p7','a0b6p8','a0b6p9','a0b6q3','a0b6q5','a0b6q6','a0b6q9','a0b6r1','a0b6r4','a0b6r6','a0b6r8','a0b6s7','a0b6t0','a0b6t1','a0b6t2','a0b6t3','a0b6t7','a0b6t9','a0b6u0','a0b6u2','a0b6u3','a0b6u4','a0b6u5','a0b6u7','a0b6u8','a0b6u9','a0b6v0','a0b6v1','a0b6v3','a0b6v8','a0b6w0','a0b6w1','a0b6w2','a0b6w7','a0b6w8','a0b6x2','a0b6x3','a0b6x5','a0b6x6','a0b6x8','a0b6x9','a0b6y1','a0b6y2','a0b6y3','a0b6y5','a0b6y6','a0b6y7','a0b6y8','a0b6z2','a0b6z9','a0b7a1','a0b7a2','a0b7a3','a0b7a4','a0b7a9','a0b7b1','a0b7b4','a0b7b5','a0b7b7','a0b7c1','a0b7c2','a0b7c3','a0b7c6','a0b7c7','a0b7d0','a0b7d1','a0b7d3','a0b7e3','a0b7e5','a0b7e6','a0b7e7','a0b7f2','a0b7f3','a0b7f6','a0b7g1','a0b7g4','a0b7g5','a0b7g6','a0b7g7','a0b7h0','a0b7h5','a0b7h8','a0b7i0','a0b7i4','a0b7i5','a0b7i6','a0b7i7','a0b7j1','a0b7j2','a0b7j4','a0b8o2','a0b8o3','a0b8o4','a0b8o5','a0b8o6','a0b8o7','a0b8o8','a0b8p2','a0b8p6','a0b8q2','a0b8r0','a0b8r1','a0b8r4','a0b8r5','a0b8r9','a0b8s0','a0b8s1','a0b8s3','a0b8s4','a0b8s7','a0b8u2','a0b8u9','a0b8v3','a0b8v4','a0b8v5','a0b8v8','a0b8v9','a0b8w1','a0b8w3','a0b8w5','a0b8w6','a0b8w7','a0b8w8','a0b8x0','a0b8x3','a0b8x4','a0b8x6','a0b8y0','a0b8y2','a0b8y3','a0b8y6','a0b8y7','a0b8y8','a0b8y9','a0b8z0','a0b8z1','a0b8z7','a0b9a0','a0b9a1','a0b9a2','a0b9a4','a0b9a8','a0b9a9','a0b9b5','a0b9b9','a0b9c0','a0b9c1','a0b9c2','a0b9c5','a0b9c8','a0b9c9','a0b9d2','a0b9d5','a0b9d9','a0b9e3','a0b9f2','a0b9g3','a0b9g4','a0b9g7','a0b9g8','a0b9h2','a0b9h4','a0b9h5','a0b9h6','a0b9h8','a0b9h9','a0b9i0','a0b9i5','a0b9i8','a0b9j0','a0b9j1','a0b9j3','a0b9j5','a0b9j6','a0b9j7','a0b9k1','a0b9k9','a0b9l3','a0b9l5','a0b9l6','a0b9l8','a0b9m2','a0b9m4','a0b9m6','a0b9m7','a0b9m8','a0b9n1','a0b9n2','a0b9n5','a0b9n6','a0b9n7','a0b9o4','a0b9p0','a0b9p1','a0b9p2','a0b9p4','a0b9p5','a0b9p6','a0b9p7','a0b9q0','a0b9q4','a0b9q7','a0b9r3','a0b9r4','a0b9r8','a0b9r9','a0b9s2','a0b9s4','a0b9s6','a0b9s8','a0b9t2','a0b9t7','a0b9u0','a0b9u7','a0b9v1','a0b9v5','a0b9v8','a0b9v9','a0b9w5','a0b9w7','a0b9w8','a0b9x1','a0b9x3','a0b9x5','a0b9x8','a0b9x9','a0b9y0','a0b9y2','a0b9y3','a0b9y4','a0b9y5','a0b9y9','a0b9z2','a0b9z4','a0b9z6','a0b9z7','a0b9z9','a0c0a0','a0c0a1','a0c0a2','a0c0a5','a0c0a6','a0c0a9','a0c0b1','a0c0b4','a0c0b5','a0c0b6','a0c0c0','a0c0c3','a0c0c7','a0c0c8','a0c0c9','a0c0e1','a0c0e2','a0c0e4','a0c0e6','a0c0e9','a0c0f0','a0c0f2','a0c0f3','a0c0f6','a0c0g0','a0c0g1','a0c0g4','a0c0g7','a0c0g8','a0c0g9','a0c0h3','a0c0i5','a0c0j1')   THEN 'enrolled'
         WHEN CSP_ID IN ('a0a7a1','a0a7c3','a0a7c5','a0a7c6','a0a7d1','a0a7d5','a0a7d6','a0a7e0','a0a7f3','a0a7h1','a0b2v8','a0b5m4','a0b5m8','a0b5n0','a0b5n5','a0b5n6','a0b5o1','a0b5o6','a0b5p1','a0b5p4','a0b5q8','a0b5r5','a0b5s1','a0b5s8','a0b5t4','a0b5u0','a0b5u2','a0b5u7','a0b5w6','a0b5w8','a0b5x3','a0b5x4','a0b5x6','a0b5y2','a0b6a0','a0b6b6','a0b6c7','a0b6d6','a0b6g0','a0b6j1','a0b6j4','a0b6k3','a0b6l4','a0b6n9','a0b6p6','a0b6q2','a0b6q8','a0b6r3','a0b6s9','a0b6t5','a0b6u1','a0b6v7','a0b6x4','a0b6z4','a0b6z7','a0b7a0','a0b7c0','a0b7c4','a0b7c9','a0b7f7','a0b7h1','a0b7h4','a0b7i2','a0b8o1','a0b8p3','a0b8p8','a0b8q1','a0b8q5','a0b8q8','a0b8t7','a0b8t8','a0b8u0','a0b8u7','a0b8v1','a0b8v7','a0b9a6','a0b9c7','a0b9e1','a0b9e7','a0b9f0','a0b9f6','a0b9f8','a0b9g5','a0b9i9','a0b9j9','a0b9l1','a0b9m1','a0b9o3','a0b9o9','a0b9q5','a0b9r2','a0b9r7','a0b9s0','a0b9s9','a0b9t5','a0b9v2','a0b9y6','a0b9y8','a0b9z1','a0b9z5','a0c0a8','a0c0b7','a0c0d5','a0c0e8','a0c0f9','a0c0g5','a0c0h4','a0c0h5') THEN 'eligible'
         ELSE 'nonmbg' END AS category
  FROM pc
  WHERE period IS NOT NULL
  GROUP BY CSP_ID, period
)
SELECT period AS PERIOD, category AS CATEGORY,
  COUNT(*)              AS PARTNERS,
  SUM(tasks)            AS TASKS,
  SUM(installs)         AS INSTALLS,
  ROUND(100.0 * SUM(installs) / NULLIF(SUM(tasks), 0), 1) AS AGG_EFF,
  COUNT(CASE WHEN tasks >= 3 THEN 1 END)                   AS PARTNERS_GE3,
  COUNT(CASE WHEN tasks >= 3 AND eff >= 0.60 THEN 1 END)   AS GE60,
  ROUND(100.0 * COUNT(CASE WHEN tasks >= 3 AND eff >= 0.60 THEN 1 END)
        / NULLIF(COUNT(CASE WHEN tasks >= 3 THEN 1 END), 0), 1) AS PCT60
FROM per_csp
GROUP BY 1, 2
ORDER BY 1, 2
