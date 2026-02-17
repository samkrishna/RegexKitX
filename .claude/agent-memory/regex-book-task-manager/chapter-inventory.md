# MRE3 Chapter Inventory - All Chapters Covered

## Chapter 4: The Mechanics of Expression Processing (pp.143-184)
**Status**: COMPLETED (26 tests, 2026-02-11)
**Complexity**: Moderate-Complex
**Dependencies**: None (foundational for Ch6)
**Estimated Tests**: 15-20

### Topics to Cover:
1. **Start of Match** (p.148): How the engine decides where to start trying
2. **Character-by-Character Processing** (p.149): Transmission bumps along the string
3. **Backtracking** (pp.151-160): NFA engine backtracking behavior
   - Greedy quantifier backtracking (gives back chars)
   - Alternation backtracking (tries next alternative)
   - Nested quantifier backtracking
4. **Greediness vs Laziness Internals** (pp.161-167)
   - How greedy .* consumes then backtracks
   - How lazy .*? advances minimally then extends
   - Performance implications
5. **Ordered Alternation** (pp.167-169): NFA left-to-right alternation
   - First match wins (leftmost match)
   - Alternation order affects what is matched
6. **Backtracking and Atomic Grouping** (pp.169-173)
   - (?>...) prevents backtracking
   - How possessive quantifiers relate
7. **Lookahead and Lookbehind Mechanics** (pp.173-177)
   - Zero-width assertions don't consume text
   - Backtracking within lookahead
8. **Match Attempt at Each Position** (p.178): Transmission tries each position

## Chapter 6: Crafting an Efficient Expression (pp.221-284)
**Status**: COMPLETED (19 tests, 2026-02-11)
**Complexity**: Complex
**Dependencies**: Chapter 4 concepts
**Estimated Tests**: 15-25

### Topics to Cover:
1. **The Unrolling-the-Loop Technique** (pp.261-271)
   - Normal* (Special Normal*)* pattern
   - Applied to quoted strings, comments, HTML
2. **Possessive Quantifiers for Efficiency** (pp.271-273)
   - x++ vs x+ when no backtracking needed
3. **Leading Character Discrimination** (pp.245-248)
   - Anchoring patterns with literal start characters
4. **Exposing Literal Text** (pp.248-250)
   - Helping the engine find fixed strings
5. **Lazy vs Greedy for Performance** (pp.252-256)
   - When lazy is faster, when greedy is faster
6. **Splitting Quantifiers** (pp.257-259)
   - Breaking up large quantified expressions
7. **Atomic Grouping for Performance** (pp.259-261)
   - Preventing exponential backtracking
   - Catastrophic backtracking avoidance
8. **Benchmarking and Comparison Patterns** (pp.275-280)
   - Equivalent regexes with different performance

## Chapters 7-10: Language-Specific (ICU-Compatible Extractions)
**Status**: COMPLETED (24 tests, 2026-02-11)
**Complexity**: Moderate
**Dependencies**: None
**Estimated Tests**: 15-20 total across all four

### ICU-Compatible Topics from Ch7 (Perl, pp.285-370):
- Dynamic regex: building patterns from data
- Named captures (?<name>...) and backreferences \k<name>
- Lookaround combinations (multiple lookaheads, lookbehind+lookahead)
- Conditional patterns (if supported by ICU -- likely NOT)
- Complex text processing pipelines with multiple regex steps

### ICU-Compatible Topics from Ch8 (Java, pp.371-434):
- Unicode-aware matching (closest to ICU)
- \p{} property support (already partially in Ch3)
- Boundary matchers \b, \G
- Quantifier types comparison (greedy/lazy/possessive)
- Multi-step find-and-replace patterns
- Region-based matching (similar to RKX range: parameter)

### ICU-Compatible Topics from Ch9 (.NET, pp.435-482):
- Named captures (same syntax)
- Lookaround patterns
- Regex-based splitting with captures
- Right-to-left matching concepts (if testable)

### ICU-Compatible Topics from Ch10 (PHP, pp.483-528):
- PCRE-compatible patterns (many overlap with ICU)
- Unicode mode patterns
- Complex delimiter matching
- Recursive patterns (NOT supported in ICU -- skip)
