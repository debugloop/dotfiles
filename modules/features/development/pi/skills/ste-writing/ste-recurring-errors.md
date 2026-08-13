# The 39 recurring errors

ASD-STE100 Issue 9 closes its dictionary introduction with a list of the errors
that writers make most often — the words people reach for on autopilot, with the
approved replacement for each. This file is that list, as data. It is a small
factual excerpt; the full standard is free at https://asd-ste100.org.

Approved replacements are UPPERCASE, the way the dictionary prints them. Some
replacements change the part of speech (check as a verb becomes CHECK the noun:
"do a check") — those need a different sentence construction, not a
word-for-word swap.

| # | Do not write | Write |
|---|---|---|
| 1 | acceptable (adj) | PERMITTED |
| 2 | alternate (adj) | ALTERNATIVE |
| 3 | any (adj) | none, or a different sentence construction |
| 4 | avoid (v) | PREVENT |
| 5 | both (adj) | THE TWO |
| 6 | check (v) | CHECK (n) — "do a check" |
| 7 | cover (v) | COVER (n) |
| 8 | complete (adj) | COMPLETED |
| 9 | damage (v) | DAMAGE (n) |
| 10 | ensure (v) | MAKE SURE |
| 11 | fit (v) | INSTALL |
| 12 | follow (v) | OBEY |
| 13 | further (adj) | MORE |
| 14 | further (adv) | MORE |
| 15 | have to (v) | an action verb in the imperative form |
| 16 | however (adv) | BUT |
| 17 | insert (v) | PUT |
| 18 | main (adj) | PRIMARY |
| 19 | may (v) | CAN |
| 20 | need (v) | NECESSARY (adj) |
| 21 | now (adv) | AT THIS TIME |
| 22 | old (adj) | REMAINING, USED, EXPIRED |
| 23 | over (prep) | ABOVE, ON, ALONG |
| 24 | people (n) | PERSON, PERSONNEL |
| 25 | perform (v) | DO |
| 26 | portion (n) | PART |
| 27 | press (v) | PUSH |
| 28 | reach (v) | GET |
| 29 | repeat (v) | DO … AGAIN |
| 30 | required (v) | NECESSARY (adj) |
| 31 | rotate (v) | TURN |
| 32 | secure (v) | ATTACH, SAFETY |
| 33 | shall (v) | MUST |
| 34 | should (v) | MUST |
| 35 | since (conj) | BECAUSE |
| 36 | test (v) | TEST (n) |
| 37 | therefore (adv) | THUS, AS A RESULT |
| 38 | under (prep) | BELOW, IN, LESS THAN |
| 39 | using (v) | USE, WITH |

## The ones that matter for software docs

Most of this list is aerospace muscle memory. Ten entries show up constantly in
engineering prose and are worth internalizing even in flavored mode:

- **ensure → make sure** — the single most common one in READMEs.
- **however → but** and **therefore → thus / as a result** — cheaper connectors,
  same logic.
- **since → because** — "since" is banned because it can mean time or cause. In
  docs this ambiguity is real: "since the server restarted" is both.
- **may → can** and **should / shall → must** — permission and obligation
  language. If it is optional, say "can". If it is not, say "must".
- **perform → do** — "perform an analysis" is the nominalization pattern.
- **using → use / with** — "Using the CLI, run…" hides the actor. "Run … with
  the CLI."
- **check / test as verbs** — STE makes them nouns ("do a check", "do a test")
  so the action verb stays unambiguous. In software prose, keeping "check" as a
  verb is fine — but pick one word for the action and never rotate synonyms.

The `--strict` flag of `ste-lint.py` enforces the strict subset (however,
since, may, should, shall, using, follow). Flavored mode leaves them alone.
