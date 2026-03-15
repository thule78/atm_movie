# tasks/lessons.md

## Lesson Log

Add user corrections here with:
- what went wrong
- why it was wrong
- prevention rule

### 2026-03-14 - Backend rule path was left incomplete
- What went wrong: I added profile photo upload UI and mirrored user comments without adding the corresponding Firebase Storage rules/config, and I left comment persistence as separate writes instead of an atomic backend operation.
- Why it was wrong: UI completion was treated as feature completion even though the backing Firebase permissions and write consistency were not fully wired.
- Prevention rule: When a feature touches Firebase, verify the full path together: client code, Firestore or Storage rules, deploy config, and whether multi-document writes should be batched or transacted.
