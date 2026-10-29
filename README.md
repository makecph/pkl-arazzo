# pkl-arazzo

Pkl modules for authoring [Arazzo](https://www.openapis.org/arazzo-specification) workflow documents,
modelled after the `org.openapis.v3` package in [pkl-pantry](https://github.com/apple/pkl-pantry).

## Layout

- `schemas/` – upstream JSON Schemas (1.0 covers 1.0.0 and 1.0.1, 1.1 covers 1.1.0) and the spec texts (refresh with `scripts/fetch-schemas.sh`)
- `scripts/validate.sh` – renders the examples and validates them against the schema matching their `arazzo` version
- `*.pkl` – one module per Arazzo object (`Document`, `Info`, `SourceDescription`, `Workflow`, `Step`, ...)
- `examples/` – sample documents that double as tests
- `PklProject` – package metadata (placeholder `baseUri`, update before publishing)

## Versioning

The package version tracks the Arazzo minor version, `<spec major>.<spec minor>.<library revision>`:

| Package version | Arazzo spec | `arazzo` field accepts |
|---|---|---|
| `1.0.x` | 1.0 | `"1.0.0"`, `"1.0.1"` (default `"1.0.1"`), on the `1.0` branch |
| `1.1.x` | 1.1 | `"1.1.0"` (default), on `main` |

```pkl
amends "package://github.com/makecph/pkl-arazzo/arazzo@1.1.0#/Document.pkl"
```

Spec patch releases only clarify the text and share a schema, so they share a package. Library fixes are patch bumps.
## What 1.1 adds over 1.0

Arazzo 1.1.0 is a minor release, but its JSON Schema is not a superset of the 1.0 one, so this line only accepts
`arazzo: "1.1.0"`. Use the `1.0.x` package line for 1.0.0 and 1.0.1 documents. Compared to 1.0:

- `$self` identifies the document.
- Source descriptions can be of type `asyncapi`.
- Steps come in three kinds: OpenAPI (`operationId` or `operationPath`), AsyncAPI (`action` plus `operationId` or
  `channelPath`, with `correlationId` for `receive`) and workflow (`workflowId`). They also gain `timeout` and a
  step-level `dependsOn`.
- The new `Selector` object picks data out of structured data. It can be a parameter value, a payload replacement
  value or a step or workflow output.
- `ExpressionType` is the nested `{type, version}` form for a criterion or selector `type`, with a new `jsonpointer`
  type and the `rfc9535` JSONPath and `xpath-31` versions. The 1.0 package used a flat `version` on the criterion
  instead, because that is what the 1.0 schema validates.
- Parameters can be located in `querystring` or `channel`, and their value can no longer be a plain object.
- Success and failure actions that `goto` a workflow can pass `parameters`.
- Payload replacements can name a `targetSelectorType`.

`tests/Rules.pkl` covers each of these, and `tests/Versions.pkl` covers version handling. Output keys must match
`[a-zA-Z0-9._-]+` as the spec text says, although the JSON Schema itself does not enforce this.

## License

Copyright 2026 Make Copenhagen ApS. Licensed under the [Apache License 2.0](LICENSE).
