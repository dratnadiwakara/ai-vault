---
description: End-to-end literature review agent that downloads PDFs, builds a local .bib, writes a structured summary, and triggers a critique.
globs: ["*.md", "*.tex"]
---

You are coordinating an end-to-end **literature review workflow** for an academic project. Your job is to (1) search and download relevant papers as PDFs, (2) build a BibTeX file **using only the local PDFs**, (3) draft a coherent, readable markdown literature review, and (4) call a second agent to review and critique the work.

All work must be contained in a project-local folder named `related-papers` at the repository root.

## Phase 0: Interpret Arguments and Set Paths

Parse `$ARGUMENTS` as follows:

- Treat the entire `$ARGUMENTS` string as the **literature search topic / query** (e.g., `"bank branch closures and credit supply"`).
- Define constants:
  - `OUTPUT_DIR = "related-papers"` (relative to the project root).
  - `PDF_DIR = "related-papers"` (same folder; all PDFs live here).
  - `BIB_PATH = "related-papers/references.bib"`.
  - `SUMMARY_MD_PATH = "related-papers/literature-review.md"`.
  - `CRITIQUE_MD_PATH = "related-papers/literature-review-critique.md"`.
- If `$ARGUMENTS` is empty, stop and ask the user to rerun the agent with a descriptive topic (do **not** try to guess a topic).

Before proceeding:
- Ensure `related-papers` exists at the project root. If not, create it using a shell command (e.g., `mkdir -p related-papers`).

## Phase 1: Discover and Download PDFs

Your goal in this phase is to search the web and populate `related-papers/` with a curated set of PDFs relevant to the topic.

1. **Search for candidate papers**
   - Use web search tools (e.g., `WebSearch` or a browser MCP) to search for academic papers matching the topic.
   - Prioritize:
     - Peer-reviewed journal articles in economics/finance.
     - Working papers from credible sources (NBER, central banks, major universities, SSRN, arXiv).
   - Collect a candidate list of URLs with titles and short snippets.

2. **Filter to PDF-backed sources**
   - For each candidate, determine whether a **PDF is directly available**:
     - Prefer final published versions (journal sites) when accessible.
     - Otherwise use reputable working paper sources (NBER, SSRN, arXiv, institutional repositories).
   - Discard items with no accessible PDF.

3. **Create stable filenames**
   - For each PDF you decide to download, construct a filename slug based on:
     - First author surname
     - Publication year (if known or inferable from the page/PDF)
     - 1–3 short keywords from the title
   - Use lower case, hyphens instead of spaces, and strip punctuation (e.g., `smith-2021-bank-closures.pdf`).
   - Ensure uniqueness by appending a numeric suffix if needed.

4. **Download PDFs into `related-papers/`**
   - Use a shell command (e.g., `curl -L "<PDF_URL>" -o "related-papers/<slug>.pdf"`) or an equivalent file download mechanism.
   - Only download into `related-papers/`. Do not write files outside this folder.
   - Maintain a simple text index file `related-papers/sources.md` with two clearly labeled sections:
     - `## Downloaded PDFs`: for each successfully downloaded PDF, log:
       - The local filename.
       - The source URL.
       - Any visible metadata such as title, authors, journal, year (as seen on the web page).
     - `## Failed or Non-PDF Sources`: for each candidate where a PDF was not accessible or the download failed, log:
       - The page title or short description.
       - The URL.
       - The reason the PDF could not be downloaded (e.g., "no PDF link", "paywalled", "download error").

The output of Phase 1 is:
- A set of `*.pdf` files under `related-papers/`.
- A `sources.md` file documenting where each PDF came from and a separate list of papers whose PDFs could not be downloaded.

## Phase 2: Build a BibTeX File Using Only Local PDFs

In this phase you will construct `references.bib` **using only information obtainable from the local PDFs in `related-papers/`**. Do not use web search or remote metadata lookups in this phase.

1. **Enumerate local PDFs**
   - Use a glob pattern like `related-papers/*.pdf` to list all PDFs.
   - For each PDF, perform metadata extraction based **only** on:
     - Embedded PDF text (by reading the file via the file-reading tool; the system will convert the PDF to text).
     - Any visible front-matter in the text (title page, header/footer, first 1–2 pages).

2. **Infer bibliographic fields heuristically**
   For each PDF, infer:
   - `title`:
     - Typically the largest or first prominent line on the first page.
     - Ignore running headers like journal names or page numbers.
   - `author`:
     - Look for a line or block immediately under the title containing personal names.
     - Parse into "Last, First" format; multiple authors separated by `and`.
   - `year`:
     - Look for a year in the copyright footer, journal header, or citation information.
   - `journal` or `booktitle`:
     - Look for phrases like "Journal of …", "Review of …", "Working Paper", "NBER Working Paper", etc. in the header/footer or title page.
   - `volume`, `number`, and `pages`:
     - If clearly visible (e.g., `Vol. 35, No. 2, pp. 123–145`), extract them; otherwise omit.
   - `publisher` (for books) when identifiable from a title page.

   If any field cannot be confidently inferred, omit it rather than guessing. Use `@misc` as a fallback entry type when the article vs. book vs. chapter status is unclear.

3. **Choose BibTeX entry types and keys**
   - Use:
     - `@article` for journal articles.
     - `@book` for books.
     - `@incollection` for chapters in edited volumes.
     - `@misc` for working papers, reports, or ambiguous cases.
   - Use the filename slug (without `.pdf`) as the BibTeX key (e.g., `smith-2021-bank-closures`).

4. **Write `references.bib`**
   - Create or overwrite `related-papers/references.bib`.
   - Add one BibTeX entry per PDF.
   - Ensure valid BibTeX syntax:
     - Comma-separated fields.
     - Strings in `{}`.
     - No trailing commas after the last field.
   - At the top of the file, include a brief comment block explaining that entries were auto-generated from local PDFs and may require manual cleanup.

The output of Phase 2 is:
- `related-papers/references.bib` containing one entry per local PDF.

## Phase 3: Draft a Structured Markdown Literature Review

Now you will read the PDFs and the `.bib` file to write a coherent, human-readable literature review in markdown.

1. **Extract per-paper summaries**
   - For each PDF:
     - If the PDF is **long** (e.g., more than ~15–20 pages), use subagents to read it in parallel:
       - Split the document into contiguous chunks of roughly **5 pages each**.
       - In a single message, launch one general-purpose subagent per chunk, passing it:
         - The PDF (or extracted text) for its page range.
         - Instructions to produce a short summary for that chunk (question, data, method, main findings, and any limitations evident in that part).
       - When all subagents return their chunk-level summaries, synthesize them into a **single, coherent 2–5 sentence summary** for the entire paper, avoiding repetition.
     - For shorter PDFs, read enough of the text (at least the abstract, introduction, and where possible the conclusion) to understand:
       - The core research question.
       - Data and sample.
       - Empirical or theoretical approach.
       - Main findings.
     - Draft a concise 2–5 sentence summary highlighting:
       - What the study asks and why it matters.
       - How it answers the question (design, model, or data).
       - The key results and any notable limitations.
   - Link each summary to its BibTeX key.

2. **Identify themes and organize the review**
   - Group papers into **thematic clusters** based on:
     - Topic (e.g., bank branch closures, credit supply, household finance, financial stability).
     - Method (e.g., diff-in-diff, event study, structural model, RCT).
     - Mechanism (e.g., information frictions, market power, liquidity constraints).
   - Create 2–5 themes and assign each paper to at least one theme.

3. **Write `literature-review.md`**
   - Create or overwrite `related-papers/literature-review.md` with the following structure:

   ```markdown
   # Literature Review: [Topic]

   **Date**: [Today's date]  
   **Search Query**: "[Original topic string]"  
   **Number of Papers Reviewed**: [N]

   ## Overview

   [1–3 paragraphs summarizing the overall state of the literature, major themes, and why this body of work matters.]

   ## Thematic Discussion

   ### Theme 1: [Descriptive name]

   [Short paragraph introducing the theme.]

   - **[BibKey1] Author1 et al. (Year)**: [Summary of question, method, findings, and limitations.]
   - **[BibKey2] Author1 & Author2 (Year)**: [Summary...]

   ### Theme 2: [Descriptive name]

   [...]

   ## Gaps and Directions for Future Work

   [Discuss what is missing in the existing literature, tensions across findings, and promising directions for future research, based only on the reviewed papers.]

   ## References

   [Formatted reference list drawing only on `references.bib`. For each entry, include at least: Authors, Year, Title, Journal/Book/Source, and BibTeX key.]
   ```

   - The **References** section must reference only entries that exist in `references.bib` (no external or uncited works).
   - Ensure the document reads as a continuous, coherent narrative, not just a list of bullet points.

The output of Phase 3 is:
- `related-papers/literature-review.md`, a readable, organized literature review.

## Phase 4: Launch a Second Agent to Review and Critique the Literature Review

Finally, you will call a **second agent** to act as a critical reviewer of the literature review you just created.

1. **Prepare inputs for the critic agent**
   - The critic agent must read:
     - `related-papers/literature-review.md`
     - `related-papers/references.bib`
   - Optionally, it may consult the PDFs in `related-papers/` if needed to verify interpretations.

2. **Call the critic agent via the Agent tool**
   - In a single message, launch a new subagent with `subagent_type: "general-purpose"`.
   - Provide a prompt describing its role:
     - It is a **senior researcher** evaluating the quality of the literature review.
     - It should assess:
       - Coverage (Are key strands well represented, given the PDFs available?)
       - Thematic organization and coherence.
       - Balance and fairness in summarizing results.
       - Clarity and readability of the markdown document.
       - Quality and correctness of the references section relative to `references.bib`.
     - It should provide:
       - A short overall assessment.
       - 3–8 major comments (structure, themes, missing connections, misinterpretations).
       - 5–15 minor comments (clarity, style, ordering, small corrections).
       - Concrete, actionable suggestions for improving the literature review.

3. **Save the critique**
   - Take the critic agent's output and save it as `related-papers/literature-review-critique.md`.
   - The critique file should be structured with headings:
     - `## Overall Assessment`
     - `## Major Comments`
     - `## Minor Comments`
     - `## Suggested Revisions`

4. **Report back to the user**
   - After saving, summarize to the user:
     - The number of PDFs downloaded and used.
     - The paths to:
       - `related-papers/references.bib`
       - `related-papers/literature-review.md`
       - `related-papers/literature-review-critique.md`
     - A brief list of the top 3 issues raised by the critic agent.

