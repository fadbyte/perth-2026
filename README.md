# Perth Road Trip — Dec 2026

A single-page dashboard for a family road trip in Western Australia, 13–27 December 2026.
Bookings, day-by-day plan with weather and suggestions, Google Maps links, and a shared cost tracker.

No build step. No dependencies. It is static HTML.

## Files

| File | What it does |
|---|---|
| `index.html` | The entire app — markup, CSS and JavaScript inline |
| `manifest.json` | App name, icon and colours so it installs to the home screen |
| `sw.js` | Service worker — caches the app so it opens with no signal |
| `icons/` | 192px and 512px app icons |
| `fonts/` | Source Serif 4 (SIL Open Font License) — self-hosted so it works offline |
| `robots.txt` | Asks search engines not to crawl the site |
| `travellers.json` | Starting list of travellers, used until Supabase is connected |
| `config.js` | Supabase address and public key — the only file you edit to switch on shared editing |
| `supabase-setup.sql` | Run once in Supabase to create the shared travellers list |

## Deploy to GitHub Pages

1. Sign in at github.com.
2. Top right **+** → **New repository**.
3. Name it `perth-trip`. Pick **Private** if you want the addresses and booking codes kept off the open web — Pages on a private repo needs GitHub Pro. Otherwise **Public**, and strip those details out first.
4. Leave everything else at its default. **Create repository**.
5. On the empty repo page, click **uploading an existing file**.
6. Drag in `index.html`, `manifest.json`, `sw.js`, `robots.txt` and the whole `icons` folder. Keep the folder structure — `icons/icon-192.png` must stay inside `icons`.
7. Type a message like `first version` in the box at the bottom, then **Commit changes**.
8. **Settings** → **Pages** in the left sidebar.
9. Under **Build and deployment**: Source = **Deploy from a branch**, Branch = **main**, folder = **/ (root)**. **Save**.
10. Wait about a minute, then reload the Pages settings page. Your URL appears at the top.

`https://<your-username>.github.io/perth-trip/`

## Install it on a phone

Open the URL, then:

- **iPhone (Safari)** — Share button → *Add to Home Screen*.
- **Android (Chrome)** — menu → *Add to Home screen* or *Install app*.

It then opens full screen with no address bar, and works offline after the first visit.

## Making changes

In the repo, click the file → pencil icon → edit → **Commit changes**.
GitHub redeploys in under a minute.

If you edit `index.html`, also bump the cache name in `sw.js` (`perth-trip-v1` → `v2`),
or phones will keep serving the old cached copy.

## What this cannot do

GitHub Pages serves files. It does not run server code and has no database.

- The expense log saves in one browser only — it does not sync between phones. A shared log needs Firebase or similar.
- Anything committed here is readable by anyone who can reach the site. **Never commit API keys, card numbers or passport details.**

## Custom domain (optional)

Buy a domain, add GitHub's four `A` records at your registrar, then put the domain in
**Settings → Pages → Custom domain**. HTTPS is issued automatically.

## Taking it down after the trip

Any one of these stops the site being served:

- **Unpublish:** Settings → Pages → Source → **None**. The URL stops working; the repo stays.
- **Hide everything:** Settings → General → Danger Zone → **Change visibility → Private**.
- **Delete:** Settings → General → Danger Zone → **Delete this repository**. Gone from GitHub entirely.

Copies someone already saved, or an old snapshot on a web archive, are outside GitHub's control.
The `noindex` tag and `robots.txt` make those far less likely.

## Shared traveller editing (Supabase)

Lets anyone with the trip passcode add, edit or remove travellers from the site itself.
Every phone sees the change on its next refresh.

1. Sign up at supabase.com (free) → **New project**. Pick region **Southeast Asia (Singapore)**. Save the database password somewhere safe — you won't need it for this.
2. Open `supabase-setup.sql`. Change `CHANGE-ME-before-running` to your trip passcode — 8+ characters, not a birthday.
3. Supabase → **SQL Editor** → **New query** → paste the whole file → **Run**. You should see "Success. No rows returned".
4. Supabase → **Table Editor** → `travellers`. Check the nine names are there.
5. Supabase → **Project Settings → API**. Copy the **Project URL** and the **anon public** key.
6. On GitHub, edit `config.js` and paste them between the quotes. Commit.
7. Open the site → Travellers tab. The status line should say *Live list*.
8. Share the passcode in the family chat — not in the repo.

**Never paste the `service_role` key anywhere in this repo.** Only the `anon` key belongs in `config.js`.

To change the passcode later, run this in the SQL Editor:

```sql
update trip_settings set value = 'new-passcode' where key = 'edit_passcode';
```

Every phone will be asked for the new one the next time it tries to save.

Offline, the tab shows the last list that phone saw. Editing needs a connection.

## Versions

| Version | Date | What changed |
|---|---|---|
| 1.3 | 23 Sep 2026 | Serif font (offline), larger text, Title Case, ≡ menu + breadcrumbs, new Overview tiles, live countdown, Booked For column, Board/Calendar toggle, Costs & Finances with filters, split slider and add/edit sheet, no-lag service worker |
| 1.2 | 23 Sep 2026 | Shared traveller editing via Supabase |
| 1.1 | 23 Sep 2026 | Travellers tab |
| 1.0 | 23 Sep 2026 | First live version |

The version shown under Settings → About must match the latest row here.

## Known limits (v1.3)

- Costs & Finances saves on each phone separately. Shared sync is planned for the next version.
- `config.js` is not included in release zips — the live copy holds the Supabase key. Never overwrite it with a blank one.
