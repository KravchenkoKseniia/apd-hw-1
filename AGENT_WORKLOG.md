# Agent worklog

Tool used for all entries: Claude Code (Claude, Anthropic), run in this repository. The assistant was asked to explain and review, not to write the implementation or the tests. All production code and tests were written by me; the assistant ran `swift test` and temporary probe tests in a scratch copy of the project to check my changes.

## 1. Explain the assignment (2026-09-27)

### Tool/agent task

Asked the assistant to read the repository files and explain what the homework requires and what the AI-use rules are, explicitly without doing any tasks.

### Output reviewed

A summary of tasks 1–6 and the bonus, the submission contract, and the AI-disclosure rules from `README.md` and this file.

### Accepted/rejected/revised decision

Accepted as a reading aid. No code was generated. I checked the summary against `README.md` and `TASKS_AND_GRADES.md`.

### Verification command/result

None needed (no code changes).

### Artifact links

None.

## 2. Xcode test run behaviour (2026-09-27)

### Tool/agent task

Asked why tests run with ⌘U in Xcode neither passed nor failed while `swift test` in the terminal finished.

### Output reviewed

Explanation that `fatalError` stops the process under the Xcode debugger, while the terminal just reports the crash.

### Accepted/rejected/revised decision

Accepted. No code changes.

### Verification command/result

`swift test` — crashed on `fatalError("Implement StudyItem validation")`, as expected for the template.

### Artifact links

None.

## 3. Review of `StudyItem.init` (2026-09-27)

### Tool/agent task

Asked for a review of my first `StudyItem` initializer, where I made `id` optional and generated a UUID inside the initializer.

### Output reviewed

Review comments and a `swift test` run (3 failures).

### Accepted/rejected/revised decision

- Accepted: the optional `id` and the new `invalidID` error case changed the published API and broke `testValidItemStoresValues`; IDs must come from the caller for `markCompleted`, duplicates and deterministic sorting. I reverted to `id: String` and removed `invalidID`.
- Accepted: my title guard was inverted, `id!` could crash, and `isCompleted` was ignored. I fixed these myself.
- Revised: I later chose to store the trimmed title; this is recorded as a risk in `PLAN.md`.

### Verification command/result

`swift test` — `testBlankTitleIsRejected` and `testValidItemStoresValues` pass; the remaining test stops at the next unimplemented method.

### Artifact links

None.

## 4. Review of `StudyPlan.init(items:)` (2026-09-27)

### Tool/agent task

Asked what `StudyPlan.init(items:)` must do, then for a review of my implementation.

### Output reviewed

Explanation of "first duplicate" and title-then-ID ordering; review found a compile error (`return` inside an initializer).

### Accepted/rejected/revised decision

Accepted: removed `return`. The duplicate scan with `Set.insert(_:).inserted` and the `(title, id)` sort were kept as I wrote them.

### Verification command/result

`swift test` — build succeeds; the plan initializer passes and the next test reaches `markCompleted`.

### Artifact links

None.

## 5. Review of decoding (2026-09-27)

### Tool/agent task

Asked for a review of `StudyPlan.decode(from:)` and later of my custom `init(from:)` implementations.

### Output reviewed

Probe results from a scratch copy showing that synthesized `Codable` bypassed validation, and that my first `StudyPlan.init(from:)` read a bare array instead of `{"items": [...]}`.

### Accepted/rejected/revised decision

- Accepted: added `init(from:)` to `StudyItem` and `StudyPlan` that decode raw values and delegate to the validating initializers.
- Revised after discussion: I first thought `init(from:)` should read the array because the fixture is an array; the task lists keyed `StudyPlan` decoding and top-level array decoding as two separate behaviors, so `init(from:)` now uses a keyed container and `decode(from:)` keeps the array.

### Verification command/result

`swift test` plus probes: blank title → `blankTitle`, zero minutes → `nonPositiveEstimatedMinutes`, duplicate in `{"items": ...}` → `duplicateID`, encode/decode round trip succeeds.

### Artifact links

None.

## 6. Review of queries and `markCompleted` (2026-09-28)

### Tool/agent task

Asked for a review of `items(in:)`, `incompleteMinutes()` and `markCompleted(id:)`.

### Output reviewed

Review found a compile error (`isCompleted` has a `private(set)` setter), a possible crash on `index!`, and later that my `markAsCompleted()` changed a copy of the struct.

### Accepted/rejected/revised decision

Accepted: `guard let` throwing `unknownID`; an internal `mutating func markAsCompleted()` on `StudyItem` instead of changing `private(set)`. Kept my loop-based query implementations instead of the suggested `filter`/`reduce` style alternatives.

### Verification command/result

`swift test` — 3 of 3 starter tests pass.

### Artifact links

None.

## 7. Review of my tests (2026-09-28)

### Tool/agent task

Asked for help with failing student tests and for a review of the test file.

### Output reviewed

Explanations of each failure and review notes.

### Accepted/rejected/revised decision

- Accepted: moved my tests out of `StudyPlannerPublicTests.swift` into a separate file and restored the supplied file.
- Accepted: fixed my own wrong expectations (`165` where the correct values were `135`/`0`; blank `id` instead of blank `title` in test data); the implementation was correct.
- Accepted: asserting the exact `StudyPlanError` in `XCTAssertThrowsError`.
- Not yet done: extra tests for keyed decoding, round trip, precedence and ID tie-break (listed in `PLAN.md` risks).

### Verification command/result

`swift test` — 12 tests, 0 failures.

### Artifact links

- [`artifacts/swift-test-2026-09-28.txt`](artifacts/swift-test-2026-09-28.txt)

## 8. Drafting `PLAN.md` and `AGENT_WORKLOG.md` (2026-09-30)

### Tool/agent task

Asked the assistant to draft `PLAN.md` and this worklog in English from the work done in this repository and the review conversation.

### Output reviewed

Drafts of `PLAN.md` and `AGENT_WORKLOG.md`.

### Accepted/rejected/revised decision

I have accepted the AI suggestions, they truly describes what it have done. I have saved the session, so I can show/send it if needed :)

### Verification command/result

`swift test` — 12 tests, 0 failures (2026-09-30).

### Artifact links

- [`PLAN.md`](PLAN.md)
