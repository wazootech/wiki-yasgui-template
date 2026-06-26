# wiki-yasgui-template

[![Use this template](https://img.shields.io/badge/Use%20this%20template-2ea44f?style=for-the-badge)](https://github.com/wazootech/wiki-yasgui-template/generate)

Explore [Wiki CLI](https://github.com/wazootech/wiki) vault RDF with [YASGUI](https://yasgui.org/). This template ships a minimal typed sample vault, a pre-exported Turtle graph for static hosting, and GitHub Actions to refresh the export and deploy a browser demo.

Ecosystem registry: [Wiki CLI templates](https://github.com/wazootech/wiki/blob/main/docs/wiki/Wiki_CLI.md#ecosystem-templates).

## Quick start

```bash
git clone https://github.com/wazootech/wiki-yasgui-template.git
cd wiki-yasgui-template
pip install wazootech-wiki
bash scripts/export-graph.sh
```

Open `index.html` locally or use the [GitHub Pages demo](https://wazootech.github.io/wiki-yasgui-template/) after enabling Pages on this repo.

## Three wiring modes

| Mode | When | Steps |
| ---- | ---- | ----- |
| **Live dev** | Local exploration with full inferred graph | `wiki serve -c sample/wiki.yaml` with `sparql_service.enabled: true` → `/api/sparql` |
| **Static export** | GitHub Pages, no backend | `wiki export` Turtle/TriG → `data/vault.ttl`; YASGUI loads the file URL |
| **Persistent backend** | Production SPARQL over a loaded graph | Export vault RDF, load into [OpenLink Virtuoso](https://virtuoso.openlinksw.com/) (see below) |

### 1. Static (Pages-friendly)

The repository includes `data/vault.ttl`, regenerated from `sample/` by `scripts/export-graph.sh` (and the Export graph workflow).

- **Hosted UI:** GitHub Pages serves `index.html` plus `data/vault.ttl` with no backend.
- **Default URL:** `?mode=static` (default on `*.github.io`) points YASGUI at the exported Turtle URL.
- **Run queries locally against the file:**

```bash
wiki -c sample/wiki.yaml query "PREFIX schema: <https://schema.org/>
SELECT ?given ?family WHERE { ?s schema:givenName ?given ; schema:familyName ?family }"
```

Re-export after editing the sample vault:

```bash
bash scripts/export-graph.sh
# or: wiki -c sample/wiki.yaml query "CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o }" -f turtle -o data/vault.ttl
```

YASGUI expects an HTTP SPARQL endpoint. For interactive browser queries against the full inferred graph, use **live mode** below or load `data/vault.ttl` in your favorite RDF tooling.

### 2. Live (`wiki serve` + SPARQL HTTP)

Enable the read-only SPARQL endpoint in `sample/wiki.yaml` (already on by default):

```yaml
sparql_service:
  enabled: true
  path: /api/sparql
```

Start the dev server from the repo root:

```bash
wiki serve -c sample/wiki.yaml
```

Open the sandbox UI in live mode:

```
index.html?mode=live&endpoint=http://127.0.0.1:8080/api/sparql
```

`mode=live` is the default on `localhost`. The endpoint matches [Wiki_Subcommand_serve](https://github.com/wazootech/wiki/blob/main/docs/wiki/Wiki_Subcommand_serve.md#sparql-endpoint): `SELECT`, `ASK`, `CONSTRUCT`, and `DESCRIBE` over the vault graph with OWL-RL inference (unless you pass `inference=false`).

Example `curl` against the live endpoint:

```bash
curl "http://127.0.0.1:8080/api/sparql?query=ASK%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D" \
  -H "Accept: application/sparql-results+json"
```

### 3. Persistent backend (optional Virtuoso)

For a durable SPARQL endpoint (not `wiki serve`), export the vault graph and load it into Virtuoso. There is no separate `wiki-virtuoso-template` — this repo covers all three modes ([#81](https://github.com/wazootech/wiki/issues/81)).

1. Export Turtle from your vault:

```bash
wiki -c sample/wiki.yaml export -f turtle -o data/vault.ttl
# or: bash scripts/export-graph.sh
```

2. Load into Virtuoso (example — adjust paths and DBA credentials for your install):

```bash
# Bulk load from Turtle (see Virtuoso bulk loader / ISQL docs)
isql 1111 dba <password> exec="DB.DBA.TTLP_MT('file://path/to/vault.ttl', '', 'http://example.org/graph/wiki', 1)"
```

3. Point YASGUI at your Virtuoso SPARQL endpoint:

```
index.html?mode=live&endpoint=http://localhost:8890/sparql
```

References: [Virtuoso RDF load](https://docs.openlinksw.com/virtuoso/), [Wiki Subcommand export](https://github.com/wazootech/wiki/blob/main/docs/wiki/Wiki_Subcommand_export.md).

## URL parameters (`index.html`)

| Parameter   | Default (localhost)              | Default (GitHub Pages)     | Description                          |
| ----------- | -------------------------------- | -------------------------- | ------------------------------------ |
| `mode`      | `live`                           | `static`                   | `live` or `static` wiring hint       |
| `endpoint`  | `http://127.0.0.1:8080/api/sparql` | `data/vault.ttl` (absolute URL) | SPARQL endpoint or data URL override |
| `data`      | `data/vault.ttl`                 | `data/vault.ttl`           | Turtle export path for static mode   |

## Sample vault

| File | Type | Purpose |
| ---- | ---- | ------- |
| `sample/wiki/Alice_Chen.md` | `schema:Person` | Person SELECT demos |
| `sample/wiki/Bob_Martinez.md` | `schema:Person` | Multi-row results |
| `sample/wiki/SPARQL_Demo.md` | `schema:TechArticle` | Filter / ASK demos |

Validate the sample vault when [Wiki CLI](https://pypi.org/project/wazootech-wiki/) is installed:

```bash
wiki -c sample/wiki.yaml check --strict
```

## GitHub Actions

| Workflow | Purpose |
| -------- | ------- |
| [export.yml](.github/workflows/export.yml) | Regenerate `data/vault.ttl` on sample changes; optional `wiki check` |
| [pages.yml](.github/workflows/pages.yml) | Deploy `index.html` and `data/` to GitHub Pages |

After forking, enable **Settings → Pages → Source: GitHub Actions**, then push to `main`.

## Use as a template

1. Click **Use this template** on GitHub.
2. Replace `sample/wiki/` with your vault (or point `wiki.yaml` at your paths).
3. Run `bash scripts/export-graph.sh` and commit `data/vault.ttl`.
4. Enable Pages and share `?mode=live` when running `wiki serve` locally.

## Related

- [Wiki CLI](https://github.com/wazootech/wiki)
- [SPARQL sandbox docs](https://github.com/wazootech/wiki/blob/main/docs/wiki/SPARQL_Sandbox.md)
- [wiki serve SPARQL endpoint](https://github.com/wazootech/wiki/blob/main/docs/wiki/Wiki_Subcommand_serve.md#sparql-endpoint)

## Alternative hosting

Beyond GitHub Pages, the static export works on any provider:

- **Vercel:** Import the repo, build command \pip install wazootech-wiki && bash scripts/export-graph.sh\, output directory \.\, deploy
- **Netlify:** Same build command, publish directory \.\
- **Cloudflare Pages:** Same build command, output directory \.\

For live SPARQL mode, use \wiki serve -c sample/wiki.yaml\ on your server and point YASGUI at the endpoint.
