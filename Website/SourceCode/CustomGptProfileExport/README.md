# Custom GPT Profile Export

`CustomGptProfileExport` is a standalone `.NET Framework 4.8` console utility that exports active ProfilesRNS people into sharded plain-text files formatted for ChatGPT Custom GPT knowledge uploads.

## Purpose

The module exists to generate reviewable, upload-friendly knowledge files without adding new web endpoints or spreading export logic across the existing site runtime. The implementation is intentionally concentrated in this directory so a reviewer can understand the feature by reading one small module.

## What It Produces

At runtime the tool writes only:

- `profiles_batch_01.txt`
- `profiles_batch_02.txt`
- ...

Each file contains one or more blocks in this format:

```text
=== PROFILE START ===
Name: Jane Doe
Department: Medicine
Title: Professor
Profiles URL: https://profiles.ucsf.edu/jane.doe

Recent Publications:
- Example publication title (2024)

Research Overview:
Plain-text overview content.

Keywords and Clinical Areas:
- Keyword A
- Keyword B

=== PROFILE END ===
```

The tool does not generate manifests, JSON sidecars, or web-facing artifacts.

## Building and Deploying

This tool deploys as a single EXE. No installer, no ClickOnce, no Setup.exe.

**Build:**

```powershell
msbuild CustomGptProfileExport.csproj /p:Configuration=Release
```

Or build it from within the main `Profiles.sln` in Visual Studio (Release configuration).

**Deploy:**

Copy `bin\Release\CustomGptProfileExport.exe` to the target machine and run it directly. That is the entire deployment. The machine needs .NET Framework 4.8 installed, which is standard on any modern Windows Server.

The `App.config` ships default local connection string values. You do not need to copy it to production — use `--connection-string` at runtime instead (see below).

## Command Line

Basic usage:

```powershell
CustomGptProfileExport.exe --output-dir C:\exports\custom-gpt --scope all
```

Common usage:

```powershell
CustomGptProfileExport.exe ^
  --output-dir C:\exports\custom-gpt ^
  --scope faculty ^
  --shards 20 ^
  --publications-per-profile 10 ^
  --overwrite
```

Supported options:

- `--output-dir <path>`
- `--scope <all|faculty>`
- `--shards <n>`
- `--publications-per-profile <n>`
- `--limit <n>`
- `--overwrite`
- `--connection-string-name <name>`
- `--connection-string "<full sql connection string>"`

## Environment Expectations

This project is intended to live with the existing legacy solution and be built in the same Windows `.NET Framework 4.8` environment as the rest of the system.

Expected integrator environment:

- Visual Studio/MSBuild with `.NET Framework 4.8` targeting pack
- SQL Server connectivity to the ProfilesRNS database
- either a valid `ProfilesDataAPIDB` connection string in `App.config`
- or an explicit `--connection-string` supplied at runtime

The checked-in `App.config` mirrors the repo's legacy local defaults so the tool behaves like the surrounding solution out of the box in that environment. Real deployments can still override this with `--connection-string` or by changing the named connection string.

## Scope Rules

`--scope all` exports all active people returned by the exporter query.

`--scope faculty` uses the repo's built-in faculty model only. It does not infer faculty status from free-text job titles.

Specifically, the faculty export path relies on canonical faculty rank data already present in the system:

- `Profile.Data.Person.FacultyRank`
- `Profile.Data.Person.Affiliation.FacultyRankID`
- cached person rows that expose `p.FacultyRank`

This mirrors how the rest of the repo treats faculty rank as a first-class concept in search and cached person data, and avoids brittle matching on words like "professor" or "dean".

## Architecture

The module is deliberately split into a small number of reviewable pieces.

### Entry Point

- `Program.cs`

Responsibilities:

- parse CLI arguments
- build the DB connection factory
- load export models from the repository
- render and write shard files
- report a concise summary to stdout/stderr

### Option Parsing

- `ExportOptions.cs`

Responsibilities:

- define the narrow CLI surface
- validate required and numeric arguments
- normalize the output path
- resolve the high-level export scope

### Data Access

- `Services/DbConnectionFactory.cs`
- `Services/ProfileRepository.cs`
- `Sql/ProfileExportQueries.cs`

Responsibilities:

- open SQL Server connections using either `App.config` or an explicit CLI connection string
- keep SQL centralized in one file for review
- load export data in three passes:
  - core profile rows
  - keywords
  - recent publications

The repository intentionally does not build one giant join. The three-pass approach keeps the SQL narrower and the C# model mapping simpler.

### Text Normalization

- `Services/HtmlTextNormalizer.cs`

Responsibilities:

- HTML-decode site content
- strip simple markup from narrative fields
- normalize whitespace and blank lines
- provide single-line and fallback/coalesce helpers

This step matters because the source data mixes HTML, entities, and inconsistent whitespace, while the export target is plain text.

### Rendering

- `Services/ProfileTextRenderer.cs`
- `Models/ExportProfile.cs`
- `Models/ExportPublication.cs`

Responsibilities:

- transform the normalized model into the final profile block format
- include only non-empty sections
- keep line endings stable
- render recent publications as bullet lines with optional year suffixes

### File Output

- `Services/ShardWriter.cs`

Responsibilities:

- ensure the output directory exists
- refuse to overwrite prior shard files unless `--overwrite` is passed
- shuffle the profile list on each run
- partition the shuffled list evenly across shard files
- write UTF-8 text files without BOM

The shard count is stable, but the people inside each shard are intentionally not. Re-running the exporter with the same inputs will typically produce a different person ordering and different shard membership.

## Query Strategy

The exporter intentionally stays close to repo-native data sources instead of scraping existing JSON output.

### Core Profiles

The core profile query reads from:

- `[Profile.Cache].[Person]`
- `[Profile.Data].[Person.Affiliation]`
- `[Profile.Data].[Person.FacultyRank]`
- RDF alias and overview tables for profile URLs and narrative text

Field selection rules:

- `Name`: display name, then first + last name fallback
- `Department`: primary affiliation department, then cached department, then `Unknown`
- `Title`: primary affiliation title, then primary affiliation faculty rank, then cached faculty rank
- `ProfilesUrl`: preferred alias when present, otherwise the standard profile route
- `ResearchOverview`: only when the cached narrative is visible

### Faculty Detection

Faculty detection is now canonical:

- include the person when the selected affiliation has a `FacultyRankID`
- or when cached person data already contains a non-empty `FacultyRank`

The exporter no longer decides faculty membership by scanning title text.

### Keywords

Keyword export currently uses `[Profile.Cache].[Concept.Mesh.Person]` and selects the top weighted MeSH concepts per person. This is a pragmatic plain-text knowledge export choice, not an attempt to reproduce every site concept surface exactly.

### Publications

Recent publications are loaded from structured publication/authorship tables, ordered newest-first by entity date, then limited per person. This avoids depending on fragile citation-string parsing.

## Why This Is Separate From The Web App

This feature could have been embedded into an API endpoint, but that would make review and maintenance harder:

- export-specific SQL and formatting would be mixed into request-handling code
- file-writing concerns would leak into the web runtime
- operator-only behavior would be harder to document and test in isolation

Keeping the exporter as a standalone console module makes the boundary explicit:

- database in
- plain-text shard files out

## File Map

Main implementation:

- `Program.cs`
- `ExportOptions.cs`
- `Services/DbConnectionFactory.cs`
- `Services/ProfileRepository.cs`
- `Services/HtmlTextNormalizer.cs`
- `Services/ProfileTextRenderer.cs`
- `Services/ShardWriter.cs`
- `Sql/ProfileExportQueries.cs`
- `Models/ExportProfile.cs`
- `Models/ExportPublication.cs`

Adjacent support files:

- `App.config`
- `Examples/sample_profile_block.txt`
- `tests/Program.cs`
- `tests/CustomGptProfileExport.Tests.csproj`

## Integration Notes

The most likely follow-on improvements for an integrator are:

- swap the inline SQL strings for stored procedures if local deployment conventions strongly prefer them
- refine the keyword source if the site has a better institution-specific concept surface than cached MeSH terms
- add a Windows scheduled-task wrapper if exports need to run on a cadence
- tune shard count and publication count defaults for actual Custom GPT upload limits

Those are intentionally left outside v1 so the current module stays small, easy to review, and easy to replace if a better long-term integration point emerges.

## Testing Notes

The adjacent test runner is intentionally lightweight. It covers:

- section omission for empty profile fields
- text normalization behavior
- shard writing without dropping profiles
- scope parsing

This keeps the exporter reviewable in isolation without taking a dependency on the repo's wider test infrastructure.
