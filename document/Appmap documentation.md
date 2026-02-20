# AppMap: what it is + how to view AppMap diagrams in your IDE (Feb 20, 2026)

## What is AppMap?
**AppMap** is a developer tool that records an application’s runtime behavior (code execution + framework/service calls) and turns it into **interactive maps/diagrams** you can explore.

In practice, AppMap can help you:
- Understand request flows (controller → service → database → external API)
- See which endpoints, SQL queries, and dependencies are exercised
- Generate sequence-like traces from real executions (tests, local runs)
- Troubleshoot performance and unexpected behavior by inspecting call trees

AppMap is commonly used with:
- Java / Spring Boot
- Ruby, Python, JavaScript/TypeScript (support varies by ecosystem)

---

## How AppMap works (high level)
A typical AppMap workflow is:
1. **Install AppMap agent/recorder** in your project/runtime.
2. **Run your app or tests** (locally or in CI).
3. AppMap writes recordings (often `.appmap.json` files) to an output folder.
4. Open them in the IDE extension to view:
   - interactive call graphs / trace views
   - HTTP endpoints involved
   - database queries
   - code locations and method calls

> Think of an AppMap as a “recording” of what your app actually did.

---

## Viewing AppMap diagrams in an IDE
People often say “Visual Studio” and mean either:
- **Visual Studio Code (VS Code)** (most common for AppMap), or
- **Visual Studio (full IDE)**.

AppMap’s best-supported developer experience is typically in **VS Code**.

---

## Option A (recommended): VS Code
### Install the AppMap extension
1. Open **Extensions** in VS Code (Ctrl+Shift+X)
2. Search for: **AppMap**
3. Install the extension published for AppMap.

### Open AppMap recordings
Once you have `.appmap.json` recordings:
- Open them directly in VS Code, or
- Use the AppMap sidebar/activity view (if the extension adds one).

### Typical project layout
Many setups write recordings under a folder like:
- `tmp/appmap`
- `build/appmap`
- `.appmap/`

(This depends on language and project configuration.)

---

## Option B: Visual Studio (full IDE)
### Reality check
Visual Studio’s extension ecosystem is different from VS Code’s. AppMap support may not be available (or may be limited) in the full Visual Studio IDE.

### What to do if you can’t find an AppMap extension
1. Use **VS Code** to view recordings (recommended).
2. Or render/export diagrams using AppMap tooling and open the output files.

If your team standard is Visual Studio only, a workable compromise is:
- record AppMaps during tests/runs
- commit/export artifacts (or keep them local)
- review them in VS Code when needed

---

## Java / Spring Boot notes (recording AppMaps)
Because AppMap is most valuable when it records real executions, you’ll usually enable it for:
- integration tests
- local runs (dev only)
- CI test runs

### Important safety note
Only record what you’re allowed to record.
Runtime recordings can contain:
- SQL query texts
- request parameters
- path variables
- possibly sensitive values if not filtered

Treat AppMaps like logs/traces: **avoid recording secrets and personal data**.

---

## Troubleshooting
### “I installed the extension but no diagrams appear”
- Confirm you actually generated recordings (e.g., `.appmap.json` files).
- Check the output folder configured by AppMap.
- Rerun tests/app with AppMap enabled.

### “There are recordings, but VS Code doesn’t recognize them”
- Ensure the file extension matches what AppMap expects (commonly `*.appmap.json`).
- Try opening the file directly.
- Reload VS Code window.

### “Visual Studio doesn’t show anything”
- If there’s no official extension for Visual Studio (full IDE), use VS Code.

---

## Links (official docs)
- AppMap website/docs: https://appmap.io/

> If you tell me your exact setup (Java version, Maven/Gradle, Spring Boot version, and whether you want AppMaps from tests or from a running server), I can add a project-specific section with the exact configuration files and commands.
