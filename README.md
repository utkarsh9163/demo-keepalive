# demo-keepalive

Keeps client demo projects on free hosting plans awake by visiting them every 10 minutes
(GitHub Actions). Free plans like **Render** put services to sleep after ~15 minutes without
traffic, so the first visitor has to wait 30–60 seconds. Sleeping also saves free hours, so each
project only stays awake when it needs to.

## Two modes (set per line in [`urls.txt`](urls.txt))

| Line in urls.txt | Mode | When it's pinged |
|---|---|---|
| `https://x.onrender.com/health` | **Daily** | Every 10 min, 10:00 AM – 11:59 PM India time; sleeps overnight |
| `https://x.onrender.com/health  until=2026-10-11 20:00` | **Demo window** | Every 10 min, **day and night**, until that India time; then never, so it sleeps and stops using hours |

Use a demo window when you send a link to a client: e.g. 12 or 24 hours from now. After the
window the site still works, the first visit just takes 30–60 s again.

The workflow runs every 10 minutes around the clock; [`ping.sh`](ping.sh) decides which URLs are
due. India time is computed from UTC (+5:30), so it works the same on any machine.

## Current projects

| Project | Mode |
|---|---|
| KaRa By Anushree (API, Render) | Demo window until 10 Oct 2026, 8:50 AM IST |

## Add a project / start a window
Add or edit its line in `urls.txt` and commit. The workflow runs immediately on that change.

## Test locally
```bash
bash ping.sh urls.txt
NOW_EPOCH=$(date -u -d "2026-10-10 02:00 +0530" +%s) bash ping.sh urls.txt   # simulate a time
```

## Free-hours budget (Render)
Render gives 750 instance-hours/month per account and only counts hours while a service is awake.

| Usage | Hours/month |
|---|---|
| One service in daily mode | ~430 |
| One 24-hour demo window | ~24 |
| One 12-hour demo window | ~12 |

## Notes
- This repo is **public** so GitHub Actions minutes are free (144 runs a day cost nothing).
  Never put secrets or private URLs here.
- GitHub pauses scheduled workflows in a public repo after 60 days without commits. Any commit
  (e.g. starting a window) resets that.
- Every 10 minutes (not 13–14) because GitHub often starts scheduled runs a few minutes late, and
  Render sleeps after 15 minutes.
- A mistyped `until=` date makes the run fail (red in Actions) so it gets noticed. Format:
  `YYYY-MM-DD HH:MM`, India time.
- Pause everything: Actions → "Keep demos awake" → ⋯ → Disable workflow.
