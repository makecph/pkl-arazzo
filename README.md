# pkl-arazzo

Pkl modules for authoring [Arazzo](https://www.openapis.org/arazzo-specification) workflow documents,
modelled after the `org.openapis.v3` package in [pkl-pantry](https://github.com/apple/pkl-pantry).

## Layout

- `schemas/` – upstream JSON Schema for Arazzo 1.0 (covers 1.0.0 and 1.0.1) and the 1.0.0 and 1.0.1 spec texts (refresh with `scripts/fetch-schemas.sh`)
- `scripts/validate.sh` – renders the examples and validates them against the schema matching their `arazzo` version
- `*.pkl` – one module per Arazzo object (`Document`, `Info`, `SourceDescription`, `Workflow`, `Step`, ...)
- `examples/` – sample documents that double as tests
- `PklProject` – package metadata (placeholder `baseUri`, update before publishing)

## Versioning

The package version tracks the Arazzo minor version, `<spec major>.<spec minor>.<library revision>`:

| Package version | Arazzo spec | `arazzo` field accepts |
|---|---|---|
| `1.0.x` | 1.0 | `"1.0.0"`, `"1.0.1"` (default `"1.0.1"`) |
| `1.1.x` | 1.1 | `"1.1.0"` (separate `1.1` release line) |

```pkl
amends "package://makecph.github.io/pkl-arazzo/arazzo@1.0.0#/Document.pkl"
```

Spec patch releases only clarify the text and share a schema, so they share a package. Library fixes are patch bumps.
## Arazzo 1.0.0 vs 1.0.1

Both patch releases share one JSON Schema (`schemas/arazzo-1.0.schema.json`, revision 2025-10-15), so a document
differs between them only in its `arazzo` field. `tests/Versions.pkl` checks this, and also that anything else is
rejected. The spec text changed in these ways:

| Change in 1.0.1 | How this package handles it |
|---|---|
| `in` of a Parameter no longer lists `body` | Rejected in both versions. The 1.0.0 text mentioned `body`, but the schema never accepted it. |
| `$message.` removed from the runtime expression grammar | Not enforced. Runtime expressions are plain strings. |
| `workflowId` must be a runtime expression when the referenced workflow is in an `arazzo` source description (1.0.0: when several exist) | Not enforced, as above. |
| Examples fixed to `$steps.<id>.outputs.<name>`, RFC references and wording updated | Editorial, nothing to enforce. |

The schema also had an earlier revision (2024-12-16) that required `retryAfter` and a goto target for `retry`
actions. The current revision applies to every 1.0.x release, so those are not required here.

## Branches and cherry-picking

Each package line lives on its own branch: `1.0` holds the `1.0.x` line and `main` holds the `1.1.x` line. The
modules are copies of each other that have drifted apart where the specs differ (`Step`, `Criterion`, `Parameter`,
`Document` and others), so a git merge between the branches is not useful. Move fixes with `git cherry-pick`
instead:

1. Fix the problem on the branch where you found it, with tests, and check that the fix is valid for the other spec
   version (compare the two schemas in `schemas/`).
2. Commit it on its own, so the commit can be picked cleanly.
3. `git switch` to the other branch and `git cherry-pick <sha>`. Expect conflicts in files that differ between the
   lines. Resolve them by applying the same intent, not by taking either side whole.
4. Run the tests and `scripts/validate.sh` on both branches.
5. Release each line separately by bumping the library revision (the patch part) in `PklProject` and tagging
   `v<version>` on that branch.

Changes that rely on something only one spec has stay on that branch. Anything that is part of 1.1 only, such as
`Selector`, is not picked back to `1.0`.

## Releasing

Package metadata is served from GitHub Pages and the package zip from GitHub releases, because Pkl fetches the
metadata for `package://makecph.github.io/pkl-arazzo/arazzo@<version>` from
`https://makecph.github.io/pkl-arazzo/arazzo@<version>`.

1. On the branch for the line you are releasing (`1.0` or `main`), bump `version` in `PklProject`, commit, and tag
   `v<version>`.
2. Build the package: `pkl project package --skip-publish-check --output-path .out .` (this creates the zip, the
   metadata file `arazzo@<version>` and their `.sha256` files). The flag is needed because the publish check looks for
   an already-published zip at `packageZipUrl`, which does not exist yet for a new version.
3. Create a GitHub release for the tag and attach the zip and its `.sha256` file. The zip must end up at the
   `packageZipUrl` in `PklProject`.
4. Add the metadata file `arazzo@<version>` to the root of the `gh-pages` branch, which GitHub Pages serves (keep an
   empty `.nojekyll` file there), and push it.

Enable GitHub Pages once in the repository settings, from the `gh-pages` branch root.

## License

Copyright 2026 Make Copenhagen ApS. Licensed under the [Apache License 2.0](LICENSE).
