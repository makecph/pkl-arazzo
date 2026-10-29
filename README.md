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
amends "package://github.com/makecph/pkl-arazzo/arazzo@1.0.0#/Document.pkl"
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

## License

Copyright 2026 Make Copenhagen ApS. Licensed under the [Apache License 2.0](LICENSE).
