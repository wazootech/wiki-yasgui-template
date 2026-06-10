# wiki-sparql-sandbox

[![Use this template](https://img.shields.io/badge/Use%20this%20template-2ea44f?style=for-the-badge)](https://github.com/wazootech/wiki-sparql-sandbox/generate)

Explore [Wiki CLI](https://github.com/wazootech/wiki) vault RDF with [YASGUI](https://yasgui.org/). This template ships a minimal typed sample vault, a pre-exported Turtle graph for static hosting, and GitHub Actions to refresh the export and deploy a browser demo.

## Quick start

```bash
git clone https://github.com/wazootech/wiki-sparql-sandbox.git
cd wiki-sparql-sandbox
pip install wazootech-wiki  # or: pip install git+https://github.com/wazootech/wiki.git@main
bash scripts/export-graph.sh
```

Open `index.html` locally or use the [GitHub Pages demo](https://wazootech.github.io/wiki-sparql-sandbox/) after enabling Pages on this repo.

## Two wiring modes

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
