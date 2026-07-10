# WIOM · MBG Banner Performance & Install Funnel

Dashboard tracking the **Minimum Business Guarantee (MBG)** home-screen banner served to
425 MBG-eligible CSPs — how it converts into engagement and, ultimately, WiFi installs,
benchmarked against the rest of the CSP network.

**Live dashboard:** https://vikaswiom.github.io/wiom-mbg-banner-dashboard/

## What it shows

- **Banner engagement** — reach (% of 425 who clicked), total clicks, and click-frequency distribution.
- **Engagement → install (per CSP)** — did banner-clickers go on to book slots, get a technician assigned, and complete installs? MBG vs non-MBG.
- **Install output funnel (per connection)** — booking → slot → technician → arrived → WiFi installed, MBG vs the rest of the network (the fair benchmark).

## Data & methodology

| Step | Source |
|------|--------|
| Banner clicks | `PROD_DB.CLEVERTAP_CSP_API.EVENTS_DATA` — `event_name='banner_opened'` |
| CleverTap ID → cspid | `PROD_DB.CLEVERTAP_CSP_API.PROFILE_DATA` |
| Install funnel | `PROD_DB.DBT_CSP.TAS_INSTALL_EXECUTION_CANDIDATES` (`ETL_CURRENT=TRUE`), join on `CSP_ID` |

Stage flags: Slot = `CONFIRMED_SLOT_AT` · Technician = `EXECUTOR_ID` · Installed = `OTP_VERIFIED` / `COMPLETED_STEP>=7`.

**Notes**
- The `banner` property in `EVENTS_DATA` is a per-render UUID with no MBG label, so the MBG banner is proxied as *any* `banner_opened` fired by an MBG cspid.
- Each CleverTap ID maps to exactly one cspid (no fan-out); one cspid can own many CleverTap IDs from reinstalls/logins.
- Non-MBG banner base is small because the banner is live almost exclusively to the 425 — the per-connection funnel is the fair network comparison.

## Files

- `index.html` — the dashboard (renders from `data.js`)
- `data.js` — the numbers + `last_updated` timestamp (auto-generated hourly)
- `refresh.py` — re-runs the queries, regenerates `data.js`, commits & pushes
- `query_csp_funnel.sql` — engagement + per-CSP funnel + click distribution
- `query_connection_funnel.sql` — per-connection install output funnel

## Auto-refresh (hourly)

`refresh.py` re-runs both queries against Metabase (Snowflake, database 113),
rewrites `data.js` with fresh numbers and an IST `last_updated` stamp, then commits
and pushes — so GitHub Pages serves the latest data within a minute. The dashboard
header shows **"Auto-refreshes hourly"** and the last-updated time.

It runs unattended via **Windows Task Scheduler** (task `WIOM-MBG-Dashboard-Refresh`,
trigger: every 1 hour). Run manually any time with:

```
python refresh.py
```
