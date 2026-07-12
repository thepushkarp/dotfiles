# Global Instructions for Agents

These are global defaults. Follow the user's current request and applicable project instructions.
More-specific project instructions, repository conventions, configured tools, and lockfiles take
precedence where they conflict.

## Working Style

- Inspect relevant code and configuration before changing anything.
- Explain consequential decisions and tradeoffs before implementation. Keep routine updates brief.
- Ask only when missing information materially affects scope, architecture, safety, or the result;
  otherwise state reasonable assumptions and proceed.
- Act on small, reversible changes without asking. Ask before destructive operations or writes to
  external services. Once required approval is given, execute without reopening routine planning.
- Make the smallest complete change. Avoid speculative features, unnecessary dependencies,
  abstractions without demonstrated reuse, and compatibility layers without a concrete need.
- Preserve unrelated user changes. Do not revert or overwrite work you did not create.
- Continue through implementation and focused verification unless blocked or explicitly paused.
- When corrected, re-read the request, acknowledge the mismatch, and adjust without defending the
  previous approach.
- Use parallel native subagents when substantial work splits into independent tasks and coordination
  costs less than the expected gain. Continue useful independent work while they run.
- Avoid delegation for small or tightly coupled tasks. Prevent overlapping concurrent edits, using
  worktrees only when isolation materially reduces conflict risk.
- For long work, provide brief updates at meaningful milestones or when findings, risks, blockers, or
  the critical path change.

## Engineering

- Remove replaced implementations rather than keeping dead code or unrequested compatibility shims.
- Fail fast with actionable errors that identify the operation and relevant input.
- Do not swallow exceptions. Add comments only when intent cannot be made clear through code.
- For bugs, verify the root cause and error path before fixing symptoms. If two attempts fail, stop and
  reconsider the assumptions rather than stacking patches.
- For performance work, measure first and compare results after the change.
- Update documentation when behavior, public interfaces, setup, or user workflows change.

## Editing And Verification

- Read each file before editing it. Prefer one coherent edit over repeated small patches.
- Use structure-aware search for code constructs and text search for literals or logs.
- Run the smallest representative checks that cover changed behavior, relevant boundaries, and likely
  regressions. Prefer live UI checks, benchmarks, smoke tests, or reference comparisons when they
  better approximate real use.
- Mock external, slow, or nondeterministic boundaries rather than internal logic.
- Do not expand test suites mechanically. Fix warnings introduced by the change, and report checks
  intentionally skipped or unavailable.
- For reviews, present findings first, ordered by severity, with file and line references. Do not modify
  code unless asked.
- Treat review comments as hypotheses; verify them against current code, requirements, and
  documentation before changing anything.

## Preferred Commands

Respect the repository's configured tools. When no toolchain is established and the tools are
available, prefer:

- Search: `rg` for text and `ast-grep` for code structure.
- Python: `uv` for environments and dependencies; `ruff check` and `ruff format` for linting and
  formatting.
- JavaScript/TypeScript: `bun install`, `bun add`, `bun remove`, `bun run`, `bun test`, and `bunx`.
- JavaScript/TypeScript CI: commit `bun.lock` and use `bun ci` for frozen-lockfile installs.
- JavaScript/TypeScript security: use `bun audit`; trust dependency lifecycle scripts only after
  verifying why they are required. Use the project's type-check and lint scripts because Bun's
  transpiler does not replace static type checking or linting.
- Rust: `cargo fmt`, `cargo clippy --all-targets --all-features -- -D warnings`, and `cargo test`.
- Prefer `trash` over `rm` for ad hoc local deletions when available. Do not rewrite project scripts
  or commands to use it, and ask before permanently deleting non-generated user data.

## Git And External Actions

- Do not commit, push, create pull requests, or modify remote services unless explicitly requested.
- Never commit secrets, credentials, tokens, or unreviewed generated files.
- Do not amend, rebase, force-push, or rewrite shared history unless explicitly requested.
- Before a requested commit, inspect status and diff, run focused checks, and stage only intended files.
- Follow the repository's commit convention. When none exists, use a concise conventional commit
  with an imperative subject no longer than 72 characters.
- Follow the repository's branch and review workflow. When none exists, prefer a feature branch and
  pull request. Push directly to the default branch only when explicitly requested and after
  verifying the intended diff.

## Search And Documentation

- Prefer authoritative, source-native documentation and tools. Fetch a known official page directly;
  use search for discovery or comparison.
- Use the search, fetch, connector, or MCP capabilities available in the current environment rather
  than assuming a particular provider or tool name.
- If a provider returns a quota or payment error, use another suitable source rather than retrying.
- Before sending content to external tools or syncing local configuration, exclude unnecessary
  secrets, personal data, proprietary content, absolute personal paths, and machine identifiers.

## Communication

- Be direct, factual, and concise. State assumptions when they affect the solution.
- Report what changed, why, and the verification result. Mention residual risks or blockers plainly.
- Use deeper explanations, examples, or diagrams when requested or when the concept is genuinely hard.
