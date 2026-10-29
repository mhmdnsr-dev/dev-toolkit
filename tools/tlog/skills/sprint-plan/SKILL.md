---
name: sprint-plan
description: Plan and create my Azure DevOps tasks for the current sprint with the tlog CLI. Use when the user asks to create/plan their sprint tasks, fill their sprint capacity, or "create my tasks for sprint N" (optionally with a total-hours target).
argument-hint: "[total hours] [notes]"
---

# Sprint plan

Create the user's tasks for the current sprint using the `tlog` CLI (on PATH as `tlog`; settings in
`~/.config/tlog/config.env`).

## Steps

1. Read the user's planning rules from `~/.config/tlog/planning.md` if it exists (role, default sprint
   total, ceremonies item, task title patterns, which stories to skip). These rules win over the
   defaults below. If the file doesn't exist, ask the user for their role and target total.

2. Get the sprint and its stories: `tlog stories --json`.
   If the user already has tasks in the sprint (`tlog`), show them and plan only the remaining hours.

3. Draft a plan that sums **exactly** to the target total. Defaults when planning.md says nothing:
   - **Ceremonies**: one `type: "Meetings"` item under the sprint's scrum/operations story.
   - **Idle**: don't create an idle task in the plan. Idle time is logged daily with `tlog idle <hours>`,
     which creates a `<TLOG_NAME> - DD Mon YYYY` task under the sprint's idle/capacity story. Show the
     leftover hours as "expected idle capacity" in the table.
   - **Work tasks**: only stories that match the user's role; `type: "Task"` (activity defaults to
     `TLOG_DEV_ACTIVITY`); clear titles like `<Feature> (<Role> implementation)`.
   - Size work by story points and how much other-discipline effort the story already carries.

4. Show the plan as a table (parent story ID, task title, type, activity, hours, total) and
   **wait for the user's approval**. Apply their edits and show the table again. Never create before they
   explicitly say to create.

5. On approval write the plan to the scratchpad as JSON and create it:
   ```json
   [
     {"parent": 1001, "type": "Meetings", "title": "Ceremonies (...)", "hours": 7.5},
     {"parent": 1002, "title": "Login page (Frontend implementation)", "hours": 16, "description": "optional"}
   ]
   ```
   `tlog create --from <file> --dry-run` first, then `tlog create --from <file>`.

6. Run `tlog` and report the created IDs and the total.
