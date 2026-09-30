# Plan

## Scope

Implement the required domain behavior of the `StudyPlanner` package (tasks 1–4) behind the published API in `Sources/StudyPlanner/StudyPlanner.swift`, without changing any public signature, the `StudyPlanError` cases, or the supplied tests in `StudyPlannerPublicTests.swift`.

In scope:

- `StudyItem` validation in its throwing initializer.
- Validated decoding: `StudyItem`, keyed `StudyPlan` (`{"items": [...]}`), and the top-level JSON array via `StudyPlan.decode(from:)`.
- Duplicate-ID detection and deterministic ordering in `StudyPlan.init(items:)`.
- Queries (`items(in:)`, `incompleteMinutes()`) and the `markCompleted(id:)` mutation.
- Student-authored XCTest cases in a separate file (`Tests/StudyPlannerTests/StudePlannerStudentTests.swift`).

Out of scope: the optional `importMerging(_:)` bonus is **not implemented** and still calls `fatalError`.

Only non-public additions were made to support the implementation: custom `init(from:)` decoders (part of the existing `Codable` conformance) and an `internal mutating func markAsCompleted()` on `StudyItem`.

## Acceptance criteria

Validation (task 1):

- A title that is empty or contains only whitespace/newlines throws `StudyPlanError.blankTitle`.
- `estimatedMinutes <= 0` throws `StudyPlanError.nonPositiveEstimatedMinutes`.
- When both are invalid, `blankTitle` is thrown (title is checked before minutes).
- A valid item keeps the given `id`, `category`, `estimatedMinutes` and `isCompleted`.

Decoding (task 2):

- Decoding a `StudyItem` from JSON runs the same validation as the initializer.
- `JSONDecoder().decode(StudyPlan.self, …)` reads the keyed form `{"items": [...]}` and applies plan validation.
- `StudyPlan.decode(from:)` reads a top-level JSON array (as in `Fixtures/study-items.json`) and applies plan validation.
- A plan encoded with `JSONEncoder` can be decoded back to an equal plan.

Duplicates and ordering (task 3):

- The first ID that repeats while scanning the input in order is reported as `duplicateID(id)` (for IDs `[a, b, c, b, a]` → `duplicateID("b")`).
- `items` is sorted by `title`, then by `id` for equal titles.

Queries and completion (task 4):

- `items(in:)` returns only items of that category, in plan order.
- `incompleteMinutes()` sums `estimatedMinutes` of items that are not completed (0 when all are completed).
- `markCompleted(id:)` throws `unknownID(id)` for an unknown ID.
- Calling `markCompleted(id:)` again on a completed item does not throw or change anything else (idempotent).

## Implementation steps

1. `StudyItem.init` — guard blank title, then non-positive minutes; assign all stored properties including `isCompleted`. File: `Sources/StudyPlanner/StudyPlanner.swift`.
2. `StudyPlan.init(items:)` — scan with a `Set<String>` to find the first duplicate, then sort by `(title, id)`. Same file.
3. `StudyPlan.decode(from:)` — decode `[StudyItem]` and pass it to `StudyPlan(items:)`. Same file.
4. Custom `init(from:)` for `StudyItem` and `StudyPlan` that decode raw values from a keyed container and delegate to the validating initializers, so JSON cannot bypass validation. Same file.
5. `items(in:)` and `incompleteMinutes()`. Same file.
6. `markCompleted(id:)` — `guard let` on `firstIndex(where:)` throwing `unknownID`, then an internal `mutating` helper on `StudyItem` (needed because `isCompleted` has a `private(set)` setter). Same file.
7. Student tests in `Tests/StudyPlannerTests/StudePlannerStudentTests.swift`; `StudyPlannerPublicTests.swift` left unchanged.

## Risks

- **Title trimming.** The stored title is trimmed of surrounding whitespace (`" Read "` → `"Read"`), both in the initializer and when decoding. The task only requires rejecting blank titles, so a grader could expect the title unchanged. Trimming also makes `" B"` and `"B"` sort as equal titles.
- **Missing `isCompleted` in JSON.** Decoding currently requires the key; an item without it fails to decode instead of defaulting to `false`. The task does not define this case.
- **Sort comparison.** Titles are compared with the default `String <`, which is case-sensitive (`"Zebra"` sorts before `"apple"`). This is deterministic, but not locale- or case-aware.
- **Empty plan.** An empty array is accepted as a valid, empty plan.
- **Blank IDs.** IDs are not validated (e.g. `" "` is accepted); the task does not require it.
- **Two JSON shapes.** Keyed `StudyPlan` decoding and `StudyPlan.decode(from:)` intentionally accept different shapes (object vs. top-level array). Mixing them up produces a `DecodingError.typeMismatch`.
- **Bonus ordering.** `importMerging` (not implemented) would keep replaced items in place and append new ones by ID, which differs from the title-then-ID order produced by `init(items:)`.
- **Test coverage gaps.** Keyed `StudyPlan` decoding, encode/decode round trip, title-before-minutes precedence, and the `id` tie-break in sorting were checked manually during review but are not yet covered by student tests.

## `swift test` verification

| Date | Command | Result | Follow-up |
| --- | --- | --- | --- |
| 2026-09-27 | `swift test` | Starter tests crash on `fatalError("Implement StudyItem validation")` | Expected for the template. |
| 2026-09-27 | `swift test` | 3 failures: title guard was inverted, generated UUID replaced the given `id` | Fixed the guard condition and restored the `id` parameter. |
| 2026-09-27 | `swift test` | Build error: `'nil' is the only return value permitted in an initializer` | Removed `return` from `StudyPlan.init(items:)`. |
| 2026-09-27 | `swift test` | Decoding accepted blank titles, zero minutes and duplicates in `{"items": ...}` | Added custom `init(from:)` for both types that delegates to the validating initializers. |
| 2026-09-28 | `swift test` | `testIncompleteMinutesAndCompletion`: `30` is not equal to `20` | `markAsCompleted()` changed a copy; made it `mutating`. |
| 2026-09-28 | `swift test` | Student test failures caused by wrong expectations (`165`, blank `id` instead of blank `title`) | Corrected the test data/expectations; the implementation was right. |
| 2026-09-28 | `swift test` | 12 tests, 0 failures | Saved as `artifacts/swift-test-2026-09-28.txt`. |
| 2026-09-30 | `swift test` | 12 tests, 0 failures | — |
