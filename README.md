# demo-keepalive

Keeps client demo projects on free hosting plans awake by visiting them every 10 minutes
(GitHub Actions schedule). Free plans like **Render** put services to sleep after ~15 minutes
without traffic, so the first visitor has to wait 30–60 seconds.

## Schedule (India time)
| IST | Pings |
|---|---|
| 10:00 AM – 11:50 PM | every 10 minutes |
| ~12:00 midnight – 10:00 AM | none, demos are allowed to sleep (first visit in this window takes 30–60 s) |

84 pings a day instead of 144. GitHub cron runs in UTC (IST = UTC + 5:30), which is why
[`keepalive.yml`](.github/workflows/keepalive.yml) has three cron lines.

## Add a project
Add its health-check URL as a new line in [`urls.txt`](urls.txt) and commit. The workflow runs
immediately on that change, then on the schedule above.

| Project | URL |
|---|---|
| KaRa By Anushree (API, Render) | https://karabyanushree-api.onrender.com/health |

## Test locally
```bash
bash ping.sh urls.txt
```

## Notes
- This repo is **public** so GitHub Actions minutes are free. Never put secrets or private URLs here.
- Render's free plan includes 750 instance-hours/month per account. With the midnight–10 AM sleep
  window one service uses about 430 hours a month, so **one** awake service fits with plenty to
  spare; two services on the same Render account (~860 hours) would still run out before the
  month ends.
- GitHub pauses scheduled workflows in a public repo after 60 days without commits. Any commit
  (e.g. adding a project) resets that.
- Runs every 10 minutes (not 14) because GitHub often starts scheduled runs a few minutes late,
  and Render sleeps after 15 minutes. The 5-minute margin covers those delays.
- Pause everything: Actions → "Keep demos awake" → ⋯ → Disable workflow.
