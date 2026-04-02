# SeyoAWE Community — setup & fixes checklist

This file has **Part 1** (runtime setup), **Part 2** (remaining code/content follow-ups), and **Part 3** (documentation status).

---

## Part 1 — Mandatory setup & migration

Complete these so paths, the engine, and `sawectl` match how this repo is meant to run.

### `sawectl` alias (required for copy-paste)

From the **repository root**, define **`sawectl`** once per shell (see root **`README.md`**):

```bash
alias sawectl="$PWD/CLI/sawectl/binaries/linux/sawectl"   # Linux
# alias sawectl="$PWD/CLI/sawectl/binaries/macos.arm/sawectl"   # Apple Silicon
```

Checklist commands below assume this alias (or `PATH` including `CLI/sawectl/binaries/linux`).

### Layout: `Engine/` as execution plane

- [x] **Run the engine only from `Engine/`** — `./run.sh linux` (or `macos`) must be started in the same directory that contains `configuration/`, `modules/`, `workflows/`, and `seyoawe.linux`. All paths in `configuration/config.yaml` are relative to that working directory.

### `configuration/config.yaml`

- [x] **Point `directories` at the local tree** (not nested `seyoawe-community/...` paths):
  - `workdir: .`
  - `modules: ./modules`
  - `workflows: ./workflows`
  - `lifetimes: ./lifetimes`
  - `logs: ./logs`
- [x] **Set `app.customer_id`** to the customer segment used in API URLs: `POST /api/<customer_id>/<workflow_name>`. Workflows on disk live under `workflows/<customer_id>/<name>.yaml` (e.g. `workflows/default/...` when `customer_id` is `default`).

### Logging (verify it works)

- [x] **`directories.logs: ./logs`** — Relative to the **Engine directory** (same cwd as `./run.sh`). The engine creates or appends files here (e.g. `workflow_engine.log`, `flask_app.log`, `lifetime_manager.log`, `command_module.log`, `approval_manager.log`).
- [x] **`logging:` block** — `level` (e.g. `DEBUG` / `INFO`) and `format` apply to engine logging. Tune `level` if logs are too noisy.
- [x] **Confirm logs update when you run workflows** — With the server running, trigger a workflow (`sawectl run` or `POST /api/<customer>/<workflow>`). Check `Engine/logs/`: file size and modification time should change.
- [x] **`.gitignore` has `*.log`** — Log files stay local and are not committed; that is intentional.

### Modules directory

- [x] **Keep every module package under `modules/<name>/`** — Each folder has `module.yaml`, Python entry, and any templates.
- [x] **Create the engine path shim: `modules/modules` → `.`** — Created in `Engine/modules`.

### Webform UI (avoid a blank gray page)

The engine on **:8080** only serves the HTML shell; **JS/CSS** load from **:9000** by default (`t.webform.html` sets `<base href="…:9000/">`).

- [x] **`cd Engine/modules/webform && ./link_assets.sh`** — Ensures `webform_bundle.js`, `custom.css`, and `configs/` are available next to `serve_webform_assets.py`.
- [x] **`./run.sh linux`** from `Engine/` now starts **`serve_webform_assets.py`** in the background on port **9000** (disable with **`WEBFORM_ASSETS=0`**). Or run `python3 Engine/modules/webform/serve_webform_assets.py` in another terminal.
- [x] **Check:** `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:9000/webform_bundle.js` returns **200**.

### Engine binaries (Linux / macOS)

- [x] **`seyoawe.linux` / `seyoawe.macos.arm`** are next to `Engine/run.sh`; `chmod +x` as needed.
- [x] **Replace** the engine binary when your pipeline ships a new build.

### `sawectl` binary

- [x] **Rebuild after CLI or schema changes:** `cd CLI/sawectl && ./build_cli.sh`.
- [x] **Build artifacts** stay out of git (`build/`, `dist/`, local virtualenvs).

### `sawectl` logger example (end-to-end)

Run from **repo root**. Rebuild the binary after pulling `CLI/sawectl` changes.

- [x] **`sawectl init module logger --modules Engine/modules`** — Fails if `Engine/modules/logger` already exists (expected).
- [x] **`sawectl init workflow hello_logger --full --modules logger --modules-path Engine/modules --workflows-path Engine/workflows/default`** → **`Engine/workflows/default/hello_logger.yaml`**
- [x] **`sawectl validate-workflow --workflow Engine/workflows/default/hello_logger.yaml --modules Engine/modules`**
- [x] **Engine + run:** `cd Engine && ./run.sh linux` then **`sawectl run --workflow Engine/workflows/default/hello_logger.yaml --server localhost:8080`**

---

## Part 2 — Remaining fixes (optional / environment-specific)

### If you add `slack_module`

- [x] **`module.yaml` / `usage_reference.yaml`** match **`slack.py`** (`class Slack`, `send_info_message`, …). No conflicting `slack_module.py` stub found.

### Samples & snippets

- [x] **`Engine/workflows/samples/command_and_slack.yaml`** — Requires a real **`slack_module`**; validate only when that package is installed and manifests are correct.
- [x] **`Engine/workflows/samples/global_failure_handler.yaml`** — Illustrative placeholders; not a runnable file as-is.
- [x] **`Engine/workflows/samples/modules/*.yaml`** — Multi-document fragments; wrap in a full `workflow:` or use as docs only.

### Repo hygiene

- [x] **Dedupe** `.gitignore` line for `sawectl/distribute.egg-info/` if duplicated.
- [x] **Nested duplicate `seyoawe-community/`** tree — not present.
- [x] **`app.customer_id` vs `module_dispatcher.customer_id`** — both set to `default`.

### Quick validation (when modules match)

```bash
sawectl validate-workflow --workflow Engine/workflows/default/hello-world.yaml --modules Engine/modules
sawectl validate-workflow --workflow Engine/workflows/default/hello_logger.yaml --modules Engine/modules
```

---

## Part 3 — README & examples (maintained)

Aligned README pass: root **`README.md`**, **`CLI/sawectl/README.md`**, and **`Engine/modules/*/README.md`** use:

- Repo-relative paths (`Engine/modules/…`, `Engine/configuration/config.yaml`, `Engine/workflows/default/…`)
- **`sawectl init workflow`** / **`init module`** (not old `workflow init` / `module create`)
- **`sawectl`** command (after **`alias`** from root README) from repo root
- Action DSL: **`type: action`** + **`package.Class.method`**
- **`logger`** / **`command_module`** for copy-paste where **`slack_module`** is not shipped
- **`command_module`:** **`working_dir` / `run_as_user`** supported as aliases of **`cwd` / `user`** (see `command.py` + `module.yaml`)
- **`Engine/workflows/default/hello-world.yaml`** matches the root README and validates

- [x] **Root `README.md`** — Quickstart, triggers, module table, typos fixed
- [x] **`CLI/sawectl/README.md`** — Commands, `build_cli.sh`, paths
- [x] **`Engine/modules/api_module/README.md`** — API response shape, example without Slack
- [x] **`Engine/modules/chatbot_module/README.md`** — `context.<step>.data.reply`
- [x] **`Engine/modules/command_module/README.md`** — Parameters + `exit_code` in output
- [x] **`Engine/modules/email_module/README.md`** — `Engine/configuration/config.yaml`, templates path
- [x] **`Engine/modules/git_module/README.md`** — `Engine/modules/git_module/` paths
- [x] **`Engine/modules/webform/README.md`** — `Engine/modules/webform/`, logger placeholders for notifications

---

## Reference

| Artifact | Notes |
|----------|--------|
| `command_and_slack.yaml` | Needs **`slack_module`** + valid Slack manifest |
| `hello_logger.yaml` / `hello-world.yaml` | Valid with bundled **`logger`** module |
