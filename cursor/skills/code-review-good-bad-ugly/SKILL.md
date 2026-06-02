---
name: code-review-good-bad-ugly
description: Perform code reviews that write Good/Bad/Ugly assessments to review-notes.md in the project root, with strict testing and documentation checks and consideration of PRDs and requirements. Use when the user asks for a code review, PR review, or feedback on code changes, or mentions review-notes.md or a Good/Bad/Ugly review.
---

# Good/Bad/Ugly Code Review

## When to use this skill

Use this skill whenever:
- The user asks for a code review, PR review, or feedback on code changes.
- The user mentions `review-notes.md` or asks for a Good/Bad/Ugly style review.
- You are summarizing review findings that should be persisted for later reference.

Assume the current working directory is the project root (repository root) unless the user states otherwise.

## Review workflow

Follow this high-level workflow for every review:

1. **Determine the scope**
   - Always base the review on **all committed changes in the current branch**, not just the snippet or file currently in view.
   - Use git history and diffs against the main branch (for example: `git --no-pager log --oneline -3` and `git --no-pager diff main..HEAD --stat`) to see which commits and files have changed since the branch diverged from `main`.
   - Identify which files, modules, and features are in scope.
   - Note any user-visible behavior changes, API changes, or data model changes.
2. **Inspect the code changes**
   - Check for correctness, edge cases, and error handling.
   - Look for maintainability issues (readability, duplication, complexity).
3. **Assess testing (critical)**
   - Find and read tests that are directly related to the changes (unit, integration, end-to-end).
   - Evaluate how well they cover happy paths, edge cases, failure paths, and regressions.
4. **Assess documentation and indices (critical)**
   - Look for updated documentation relevant to the change (e.g. under `docs/` or project-specific docs directories).
   - Check that any new or changed docs are discoverable via indexes such as `AGENTS.md`, `INDEX.md`, or similar index files.
5. **Assess task tracking hygiene (critical)**
   - Verify that meaningful implementation work is represented in Beads when the repository uses Beads.
   - Check for evidence of lifecycle hygiene: task exists, was claimed, and progress/outcome is reflected.
   - If task tracking is intentionally out of scope for the review, state that assumption explicitly.
6. **Consider PRDs and requirements**
   - Search for relevant PRDs / requirements documents (for example, files with names like `MAIN-PRD.md`, `MERCHANT-PRD.md`, `PATRON-PRD.md`, or other `*PRD*` / `requirements` documents).
   - Verify that the implementation aligns with these documents; call out any mismatches.
7. **Summarize findings as Good/Bad/Ugly**
   - Classify strengths and issues into Good, Bad, and Ugly sections (see guidance below).
8. **Determine review status**
   - Decide whether the review **PASS**es or **FAIL**s, based primarily on testing and documentation sufficiency.
   - **If tests, documentation, or required task tracking are not adequate, the review must FAIL.**
9. **Write `review-notes.md`**
   - Create or overwrite `review-notes.md` in the project root using the template below.

## Output file: `review-notes.md`

Every review must be written to a markdown file named `review-notes.md` located at the project root.

- If `review-notes.md` already exists, **overwrite it** with the latest review, unless the user explicitly asks to preserve history or append.
- Use this template as the required structure:

```markdown
# Code Review Notes

**Review status**: PASS | FAIL

## Good
- ...

## Bad
- ...

## Ugly
- ...

## Testing
- Existing tests that cover these changes:
  - ...
- Missing or weak test coverage:
  - ...

## Documentation & PRDs
- Documentation updates (what changed, where it lives, and how it is indexed):
  - ...
- PRDs / requirements considered and alignment notes:
  - ...

## Task Tracking (Beads)
- Task linkage and lifecycle evidence:
  - ...
- Gaps or assumptions:
  - ...
```

### Pass / fail rules

Set the **Review status** field according to these rules:

- Default to **FAIL** unless you are confident that:
  - There is meaningful, relevant test coverage for the changes, and
  - Documentation is updated and discoverable where appropriate, and
  - Required task tracking hygiene is present where applicable, and
  - The behavior appears consistent with any available PRDs / requirements.
- The review **must FAIL** if:
  - There are no meaningful new or updated tests covering the changes, or
  - Documentation is missing, outdated, or not properly indexed / linked, where docs are warranted, or
  - Meaningful implementation work in a Beads-enabled repo has no corresponding task evidence (or no explicit rationale for omission), or
  - Relevant PRDs / requirements cannot be found, clearly conflict with the implementation, or leave major open questions.

Explicitly call out the reason for a FAIL in the **Bad** or **Ugly** sections and in the relevant section(s): **Testing**, **Documentation & PRDs**, or **Task Tracking (Beads)**.

## Testing requirements (MUST)

Treat testing as a first-class concern in every review:

- **Locate tests**
  - Search for tests near the changed code (same package/module, `test/` directories, or project-specific testing locations).
  - Consider unit tests, integration tests, and end-to-end tests as applicable.
- **Evaluate coverage**
  - Identify which scenarios are covered (happy paths, edge cases, error handling, concurrency, performance-sensitive paths).
  - Note any missing coverage that could reasonably be expected for the change.
- **Assess quality**
  - Check that tests are clear, reliable, and assert on meaningful behavior (not just implementation details).
  - Prefer tests that would catch regressions if the new code broke in the future.

**Automatic FAIL condition**:

- If there is **no meaningful testing** related to the changes, or if coverage is obviously insufficient for the risk/impact, the review must FAIL.
- Document these gaps clearly under **Bad** or **Ugly** and in the **Testing** section of `review-notes.md`.

## Documentation & PRDs (MUST)

Documentation and alignment with requirements are critical:

- **Locate relevant documentation**
  - Look for docs under directories like `docs/` or other project-specific locations.
  - Check for indexes such as `AGENTS.md`, `INDEX.md`, or similar that should reference new or updated docs.
- **Evaluate documentation quality**
  - Confirm that behavior changes, new features, or breaking changes are documented.
  - Ensure docs are clear, up to date, and discoverable via appropriate indices.
- **Check PRDs and requirements**
  - Search for PRD / requirements documents (e.g. files with `PRD` in the name or clearly-labeled requirements markdown).
  - Compare the implementation against these documents and note alignments or discrepancies.

**Automatic FAIL condition**:

- If user-visible behavior or API changes are not documented and indexed where appropriate, the review must FAIL.
- If relevant PRDs appear to be ignored, obviously out of sync, or missing for a major feature, treat this as at least an Ugly finding and strongly bias toward FAIL unless the user explicitly narrows the scope.

## Task Tracking (Beads) (MUST when applicable)

When reviewing repositories that use Beads for task memory:

- **Check task presence and scope**
  - Confirm there is a task representing the reviewed implementation scope, or an explicit note explaining why not.
- **Check lifecycle hygiene**
  - Look for evidence that the task was claimed for active work and that progress/outcome updates exist.
- **Check quality of tracking**
  - Ensure the task description reflects acceptance criteria and any discovered blockers are captured as dependencies, not buried in comments.

- **When Beads is the only remaining blocker, do a fresh Beads deep-check**
  - If code quality, tests, docs, and PRD alignment look acceptable and **only** task-tracking evidence is missing, you must perform a fresh Beads review before finalizing FAIL.
  - Do not rely only on commit metadata, branch naming, or `bd ready`.
  - At minimum, inspect broader Beads state with commands like:
    - `bd list --json`
    - `bd list --status=closed --json`
    - targeted `bd search "<feature keywords>" --json`
    - `bd show <id>` for likely matching issues
  - If this deeper check reveals valid linkage/lifecycle evidence, update the review accordingly and avoid failing solely on earlier metadata assumptions.
  - If evidence is still missing after the deep-check, keep FAIL and explicitly state which Beads commands were checked.

**Automatic FAIL condition**:

- If the repository uses Beads and the reviewed implementation has no meaningful task linkage/lifecycle evidence (without explicit, reasonable scoping justification), the review must FAIL.

## Classifying Good, Bad, and Ugly

Use these guidelines when categorizing findings:

- **Good**
  - Clear improvements to correctness, performance, or readability.
  - Strong, well-structured tests with good coverage.
  - Clean design, good separation of concerns, and intuitive naming.
  - Documentation that makes the system easier to understand and operate.
- **Bad**
  - Minor or moderate issues that should ideally be addressed before merge but are not structurally severe.
  - Style issues, moderate complexity, or small test/doc gaps.
  - Reasonable implementation that could be improved with refactoring or more tests.
- **Ugly**
  - Structural or architectural problems (tight coupling, large monolithic functions, duplicated logic).
  - Missing or dangerously weak tests for high-impact changes.
  - Missing or misleading documentation, or clear divergence from PRDs / requirements.
  - Anything that significantly increases long-term maintenance or risk.

When in doubt, err on the side of marking serious risk factors (especially around testing, documentation, and requirements alignment) as **Ugly**.

## Example `review-notes.md` (FAIL)

```markdown
# Code Review Notes

**Review status**: FAIL

## Good
- New error handling improves resilience when the payment gateway is unavailable.

## Bad
- Controller function is somewhat long and could be split into smaller helpers.

## Ugly
- No new tests were added for the new error handling paths.
- The behavior change for declined payments is not documented anywhere.

## Testing
- Existing tests:
  - Basic happy-path payment flow.
- Missing or weak coverage:
  - No tests for gateway timeouts or declined payments.
  - No regression tests for the new error handling branches.

## Documentation & PRDs
- Documentation updates:
  - None found for the new error handling behavior.
- PRDs / requirements:
  - Payment flow PRD exists but does not mention the new behavior; implementation may diverge from expectations.

## Task Tracking (Beads)
- Task linkage and lifecycle evidence:
  - No linked Beads task found for this feature branch.
- Gaps or assumptions:
  - Assuming Beads is required in this repository, this is a process gap and contributes to FAIL.
```

## Example `review-notes.md` (PASS)

```markdown
# Code Review Notes

**Review status**: PASS

## Good
- Extracted validation logic into a small, well-named helper function.
- Added comprehensive tests for valid and invalid input combinations.

## Bad
- A couple of variable names in the test suite could be clearer, but this is minor.

## Ugly
- None identified.

## Testing
- Existing tests:
  - Unit tests for all validation branches (valid, invalid, boundary values).
  - Integration test verifying the full request/response cycle.
- Missing or weak coverage:
  - None obvious for the scope of this change.

## Documentation & PRDs
- Documentation updates:
  - Updated `docs/validation.md` to describe new rules.
  - Linked from `docs/INDEX.md` so it is discoverable.
- PRDs / requirements:
  - Implementation matches the documented validation rules in the feature PRD.

## Task Tracking (Beads)
- Task linkage and lifecycle evidence:
  - Feature linked to a claimed Beads task with outcome notes.
- Gaps or assumptions:
  - No major gaps identified.
```

## Summary

Always:
- Produce a Good/Bad/Ugly style review.
- Write the results to `review-notes.md` in the project root, overwriting any previous contents unless the user requests otherwise.
- Be especially critical of testing and documentation; if they are not meaningfully addressed, the review must FAIL.
- In Beads-enabled repositories, verify task linkage/lifecycle hygiene and fail when meaningful tracking is missing without a clear rationale.
- Consider and reference relevant PRDs and requirements whenever they are available.

## Reviewer checklist (quick gate)

Before finalizing PASS/FAIL, confirm:
- [ ] Scope is based on committed branch changes, not just one file/snippet.
- [ ] Relevant tests were inspected and coverage quality was assessed.
- [ ] Relevant docs and indexes were checked for discoverability.
- [ ] Relevant PRDs/requirements were considered and alignment was evaluated.
- [ ] Beads linkage/lifecycle evidence was checked for this scope.
- [ ] If Beads is the only blocker, a fresh Beads deep-check was done (`bd list`, `bd list --status=closed`, targeted `bd search`, and `bd show` on candidate issues).

