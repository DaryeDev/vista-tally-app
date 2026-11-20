# Tally — an example Vista app

A small daily counter with a goal. It exists to show every moving part of a
third-party [Vista](https://github.com/DaryeDev) app in one place:

| File | Runs on | What it shows |
|---|---|---|
| `manifest.json` | — | id, accent, icon, permissions **with the reason the user will read** |
| `logic.lua` | phone (sandboxed Lua) | state, `vista.kv` persistence, `vista.render`, `vista.notify`, glasses `input` and phone `phone` events |
| `view.lua` | glasses | draws whatever `logic.lua` rendered |
| `phone.ui.json` | phone (Flutter) | the app's phone page: Card, Text, Segmented, Button, Slider, Toggle, ListGroup with `each`/`template` |
| `catalog.json` | — | the file you give Vista's Store to list the app |
| `build.py` | your machine | zips the app (deterministic) and rewrites `catalog.json` with the SHA-256 |

## Try it

1. In Vista: **Store → Catalogs → Add a catalog**, paste

   ```
   https://raw.githubusercontent.com/DaryeDev/vista-tally-app/main/catalog.json
   ```

2. **Discover → Tally → Get**. The install sheet lists the two permissions and
   the "Unofficial" warning (it comes from a catalog you added).
3. Open Tally. On the glasses: **OK** adds, **left** undoes. On the phone: use
   the page body.

## Make your own

1. Copy this folder, change `id` (reverse-DNS, e.g. `dev.you.myapp`), `name`
   (max 16 characters), `developer`, `accent` (needs 3:1 contrast on black) and
   `icon` (an SVG path on a 24×24 grid).
2. Edit `logic.lua`, `view.lua`, `phone.ui.json`.
3. Set `REPO` in `build.py` to your `user/repo`, run `python build.py`, commit
   `dist/` and `catalog.json`, push. The repo must be public so the phone can
   download the files.
4. Bump `version` in `manifest.json` and run `build.py` again for each release.

### Rules the Store enforces

- The permissions in `catalog.json` must match `manifest.json` exactly (same ids,
  same reasons). `build.py` copies them, so they always do.
- The download's SHA-256 must match `catalog.json`.
- `phone.ui.json` may only use the catalogue widgets: `Icon`, `Button`, `Card`,
  `ListGroup`, `Toggle`, `Segmented`, `TrustBadge`, `Text`, `TextField`, `Slider`,
  `ImageGrid`.
- Package ≤ 2 MB, assets ≤ 256 KB.

### Phone UI bindings

`"@n"` is replaced by the value `n` of the last `vista.render({...})` (keeps its
type), `"{{n}}"` interpolates into text, `"if": "@flag"` hides a node,
`"each": "@list"` + `"template": {...}` repeats a node (`{{item}}`, `{{index}}`).
Widget actions `{ "op": "x" }` arrive in Lua as `vista.on('phone', function(cmd)`
with `cmd.op` and, for inputs, `cmd.value`.
