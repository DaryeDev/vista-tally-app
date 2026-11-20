# Vista example apps

Two small third-party apps for [Vista](https://github.com/DaryeDev) (Halo glasses),
plus the catalog that lists them. Together they show every moving part of an app,
with the two ways of building the phone page.

| App | Phone page | Shows |
|---|---|---|
| [`apps/tally`](apps/tally) | **schema** (`phone.ui.json`) | a daily counter with a goal: kv persistence, glasses `input`, phone `phone` events, notification, bindings (`@n`, `{{n}}`, `if`, `each`) |
| [`apps/scratchpad`](apps/scratchpad) | **web** (`phone/index.html`) | a note you type on the phone and read on the glasses: HTML/CSS/JS page, `Vista.post` / `Vista.onState`, input validation in Lua |

Each app folder has the same files:

| File | Runs on | What it is |
|---|---|---|
| `manifest.json` | — | id, accent, icon, permissions **with the reason the user will read** |
| `logic.lua` | phone (sandboxed Lua) | state, `vista.kv`, `vista.render`, events |
| `view.lua` | glasses | draws whatever `logic.lua` rendered |
| `phone.ui.json` *or* `phone/` | phone | the app's phone page (schema, or a web page) |

`build.py` zips every app into `dist/` (deterministic) and rewrites `catalog.json`
with the SHA-256s. `catalog.json` is what you give Vista's Store.

## Try them

1. In Vista: **Store → Catalogs → Add a catalog**, paste

   ```
   https://raw.githubusercontent.com/DaryeDev/vista-tally-app/main/catalog.json
   ```

2. **Discover → Tally** (or **Scratchpad**) **→ Get**. The install sheet lists the
   permissions and the "Unofficial" warning (the catalog is one you added).
3. Open the app. Tally: **OK** adds, **left** undoes. Scratchpad: type a note on
   the phone; on the glasses **OK** changes the colour and **up/down** the size.

## Make your own

1. Copy an app folder under `apps/`. Change `id` (reverse-DNS, e.g.
   `dev.you.myapp`), `name` (max 16 characters), `developer`, `accent` (needs 3:1
   contrast on black) and `icon` (an SVG path on a 24×24 grid).
2. Edit `logic.lua`, `view.lua` and the phone page.
3. Set `REPO` in `build.py` to your `user/repo`, run `python build.py`, commit
   `dist/` and `catalog.json`, push. The repo must be public so the phone can
   download the files.
4. Bump `version` in `manifest.json` and run `build.py` again for each release.

### Rules the Store enforces

- The permissions in `catalog.json` must match `manifest.json` exactly (same ids,
  same reasons). `build.py` copies them, so they always do.
- The download's SHA-256 must match `catalog.json`.
- Package ≤ 2 MB, assets ≤ 256 KB, ≤ 200 files.
- `phoneUi: "schema"` needs `phone.ui.json` using only the catalogue widgets:
  `Icon`, `Button`, `Card`, `ListGroup`, `Toggle`, `Segmented`, `TrustBadge`, `Text`,
  `TextField`, `Slider`, `ImageGrid`.
- `phoneUi: "web"` needs the `webview` permission and `phone/index.html`.

### Schema phone UI

`"@n"` is replaced by the value `n` of the last `vista.render({...})` (keeps its
type), `"{{n}}"` interpolates into text, `"if": "@flag"` hides a node,
`"each": "@list"` + `"template": {...}` repeats a node (`{{item}}`, `{{index}}`).
A widget's `action` `{ "op": "x" }` arrives in Lua as
`vista.on('phone', function(cmd) … end)` with `cmd.op` and, for inputs, `cmd.value`.

### Web phone UI

Your page runs in a locked-down WebView: **no network** (a Content-Security-Policy
blocks every request), no navigation, no file access. Scripts, styles and images in
`phone/` and `assets/` are inlined at load time, so reference them with relative
paths. The page gets one global:

```js
Vista.post({ op: 'set', text: 'hi' });          // -> vista.on('phone', function(cmd) ... end)
Vista.onState(function (state) { /* ... */ });  // state = the last vista.render({...})
```

Treat everything the page sends as untrusted input in `logic.lua` (Scratchpad
validates every field). Messages are `{ "op": "<name>", … }` objects, ≤ 16 KB, at
most 30 per second.

### Lua notes

The phone runs Lua 5.3 (LuaDardo): no `utf8`, `#` does not work on strings (use
`string.len`), no bitwise operators. The glasses run Lua 5.4 with pre-rendered
ASCII fonts, so `view.lua` can only draw ASCII text.
