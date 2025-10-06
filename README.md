# Nicolas Fliegel's Intro Course App

Hi there, I'm Nico :wave:
I'm a current master student in Computer Science.

## Local development
For your Intro Course App, you will use XcodeGen to manage your Xcode Project. 

**What is XcodeGen?** XcodeGen is a tool that automatically generates Xcode project files from a simple configuration file. Instead of manually managing complex Xcode project settings, you define your project structure in the provided `project.yml` file, and XcodeGen creates the `.xcodeproj` file for you. This makes it easier to manage your Xcode project under version control (git), and resolve any merge conflicts that arise.

**Why do we need this?** When you clone this repository, you won't find a ready-to-use `.xcodeproj` file, which you can directly open with Xcode. Instead, you'll find a `project.yml` configuration file that describes how the Xcode project should be set up. You need to generate the actual Xcode project file before you can open and work on the app in Xcode.

1. Install xcodegen
    ```bash
    brew install xcodegen
    ```
2. Generate .xcodeproj
    ```bash
    xcodegen generate
    ```
    
    After running this command, you'll see a new `.xcodeproj` file appear in your project folder. You can then double-click this file to open your project in Xcode.

Since the `xcodegen generate` command must be run when the project is cloned and whenever changes affect the project structure, you can enable Git hooks to run the command automatically after merges and pulls.

Run the following command to point `git` to the hooks:
```bash
git config core.hooksPath .githooks
```

## Submission Procedure

1. **Personal Repository**
   You have been given a personal repository on GitLab to work on your app.

2. **Issue-Based Development**

    * Follow the issue-based development process from the Git Basics and Software Engineering sessions.
    * For every task, open or update the matching GitLab **issue** (or checklist item) before writing code.
    * Inside the issue or task, press **Create branch**. Confirm that **Source branch = `main`** and let GitLab generate the feature-branch name so the branch stays linked to the issue.
    * After GitLab creates the branch, sync your local repo and check out that branch (GitLab already created it on the server, so you only need to fetch it locally):

     ```bash
     git checkout main
     git pull origin main
     git fetch origin
     git checkout <branch-name>
     ```

3. **Merge Requests (MRs)**

   * For each completed issue / task, open an **MR targeting `main`** (source: your feature branch → target: `main`).
   * Add your tutor as a reviewer and collaborate on requested changes.
   * Keep MRs focused and small where possible; ensure CI/build checks are green.
   * **Do not commit directly to `main`.** Use MRs only.
   * It is **your responsibility to press "Merge"** once the MR is approved.

**Deadline:** **2025-10-14 20:00**

**All MRs must be merged into `main` by the deadline.** The version on `main` at the deadline is considered your final submission. Your app must satisfy all required **quality attributes & external constraints**. During the first four days there are intermediate deadlines for software engineering artifacts to help you stay on track.

---

## Project Documentation

This README serves as your primary documentation. Update it as your project evolves.

### Problem Statement (max. 500 words)

Millions of Deaf and hard-of-hearing (DHH) people rely on sign languages (around 80.000 in Germany) for natural, fluent communication. In day-to-day interactions at offices, clinics, universities, and public transit, spontaneous access to human interpreters is rare, while text chat and lip-reading are slow, inaccurate, or cognitively demanding. Hearing people often don't know even basic signs, which turns simple, time-critical exchanges into frustrating experiences and social exclusion.
My app addresses this gap by translating short spoken statements into clear, animated sign output that a signer can immediately understand. The primary users are DHH signers who need fast comprehension of what a hearing person just said. Secondary users include hearing peers, staff, educators, and family members who want to communicate respectfully without waiting for an interpreter.
Solving this matters, because accessible communication is a prerequisite for autonomy, safety, and equal participation. For instance, in university life, it affects onboarding, group work, office hours, and emergency information, moments where delays or misunderstandings can have outsized consequences.

### Requirements

#### Functional Requirements (User Stories)

*TODO: List the user stories that your app fulfills. These should be added to the GitLab product backlog as issues. Discuss and refine them with your tutor.*

- As a [user], I want to [action] so that [goal].

For Example (an Expense Tracking App): As a [student], I want to [see all my monthly transactions] so that [I can make better financial decisions].

#### Quality Attributes & External Constraints

*TODO: For each required quality attribute or constraint (e.g., HIG usability, dark mode, responsiveness, persistence, logging, error handling, responsible AI usage), add a short subsection that summarizes your solution, links to supporting evidence (file, screenshot, test, or slide), and notes any follow-up work. When documenting responsible AI usage, summarize prompts you ran, how you reviewed/adapted the output, and the guardrails (manual testing, peer review, etc.) you applied.*

* **Responsible AI usage:** *TODO — add this once you document your AI-supported work (prompt highlights, review steps, guardrails, evidence links).*
* **Other attributes / constraints:** *TODO — add concise subheadings with one-paragraph summaries and supporting links or screenshots.*

#### Glossary (Abbott’s Technique)

*TODO: Define key terms and concepts used in your project. Clarify domain-specific language or abbreviations.*

| Terms    | Definition      |
| ------------- | ------------- |
| example: Transaction | A transaction is when money moves out of one account in exchange for a product or service. |
| ... | ... |

#### Analysis Object Model

*TODO: Add an analysis object model diagram showing relationships between key entities in your app.*

* **Instructions:** Create with [apollon](https://apollon.ase.cit.tum.de), [draw.io](https://draw.io) or alternatives, export as an **image** and insert it directly (no links, **no SVG**).

Inserting an image in Markdown:
``` 
![Alt text](image path)
``` 

### Architecture

#### Subsystem Decomposition

*TODO: Break down your app into its main subsystems (e.g., UI layer, networking, data/persistence, domain/logic, feature modules). Describe responsibilities, main data flows, and key dependencies. A simple diagram is encouraged.*

* Subsystem A — responsibilities, key types, inbound/outbound data
* Subsystem B — ...
* ...

---

*Replace placeholders and keep this document current. It’s both your planning guide and part of your final deliverable.*

Happy coding!
