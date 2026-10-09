# demo-keepalive

Keeps client demo projects on free hosting plans awake by visiting them every 10 minutes
(GitHub Actions schedule). Free plans like **Render** put services to sleep after ~15 minutes
without traffic, so the first visitor has to wait 30–60 seconds.

## Add a project
Add its health-check URL as a new line in [`urls.txt`](urls.txt) and commit. The workflow runs
immediately on that change, then every 10 minutes.

| Project | URL |
|---|---|
| KaRa By Anushree (API, Render) | https://karabyanushree-api.onrender.com/health |

## Test locally
```bash
bash ping.sh urls.txt
```

## Notes
- This repo is **public** so GitHub Actions minutes are free. Never put secrets or private URLs here.
- Render's free plan includes 750 instance-hours/month per account, enough for **one** service
  awake 24/7. Keeping several Render services awake on one account will use up those hours.
- GitHub pauses scheduled workflows in a public repo after 60 days without commits. Any commit
  (e.g. adding a project) resets that.
- Runs every 10 minutes (not 14) because GitHub often starts scheduled runs a few minutes late,
  and Render sleeps after 15 minutes. The 5-minute margin covers those delays.
- Pause everything: Actions → "Keep demos awake" → ⋯ → Disable workflow.
