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

**Papaya** is a spoken-to-sign language translation app that bridges communication between hearing and Deaf or hard-of-hearing users.  
It listens to short spoken phrases, matches each word to a photo of the corresponding sign from a local library, and displays the sequence with smooth transitions.  
Users can add missing word-sign pairs by taking their own photos, building a personalized signing library over time.

### Problem Statement (max. 500 words)

Millions of Deaf and hard-of-hearing (DHH) people rely on sign languages (around 80.000 in Germany) for natural, fluent communication. In day-to-day interactions at offices, clinics, universities, and public transit, spontaneous access to human interpreters is rare, while text chat and lip-reading are slow, inaccurate, or cognitively demanding. Hearing people often don't know even basic signs, which turns simple, time-critical exchanges into frustrating experiences and social exclusion.
My app addresses this gap by translating short spoken statements into clear, animated sign output that a signer can immediately understand. The primary users are DHH signers who need fast comprehension of what a hearing person just said. Secondary users include hearing peers, staff, educators, and family members who want to communicate respectfully without waiting for an interpreter.
Solving this matters, because accessible communication is a prerequisite for autonomy, safety, and equal participation. For instance, in university life, it affects onboarding, group work, office hours, and emergency information, moments where delays or misunderstandings can have outsized consequences.

### Requirements

#### Functional Requirements (User Stories)

1. Real-time speech capture

As a hearing person, I want to press-and-hold to record my speech so that the signer can see the translation right after I finish.
Acceptance: For ≤15 spoken words, playback begins ≤2s after I release the mic.
Word lookup & phrase assembly
As a Deaf signer, I want each spoken word matched to a photo of the corresponding sign so that a whole phrase plays as a sequence.
Acceptance: Given a 3-word phrase with all words in the library, the app shows those 3 sign photos in order with no gaps and no network required.

2. Smooth morph transitions

As a Deaf signer, I want smooth visual transitions between consecutive sign photos so that the sequence is easy to follow.
Acceptance: Between photos, a default morph/crossfade of ~300ms occurs; I can change transition duration in Settings to 0/200/300/600ms, and the choice persists per session.

3. Unknown word detection & prompt
As a user, I want the app to flag any word not found in the library and prompt me to add it so that the phrase can still be completed.
Acceptance: For an unknown word, the UI highlights it and shows “Add sign”; choosing it opens the capture flow (see next story).

4. Add word–sign pair (capture flow)
As a user, I want to create a new word–sign pair by taking a photo of myself signing the word so that it’s available immediately.
Acceptance: Capture uses the chosen camera, shows framing tips, allows retake/crop, requires entering the word label, and saves locally; after saving, the phrase replays including the new photo.

5. Replay & granular controls
As a Deaf signer, I want play/pause, previous/next word, and “replay current word” so that I can review unclear parts.
Acceptance: Controls work during playback; “replay” replays just the current photo + transition; controls remain responsive (<100ms).

6. Library management
As a user, I want to browse, search, edit, and delete my word–sign pairs so that I can keep the library clean.
Acceptance: A local list shows entries with word label and thumbnail; I can rename, replace photo, or delete; changes reflect immediately in future translations.

7. Labels under photos
As a Deaf signer, I want the word label shown under each photo so that I can confirm which sign I’m seeing.
Acceptance: Each displayed photo includes the word label; a Settings toggle turns labels on/off.

8. Offline operation
As a user, I want the app to translate using my on-device library without internet so that it works anywhere.
Acceptance: In airplane mode, known words still render; adding a new word via camera still works; nothing fails due to lack of network.

9. Privacy & local storage
As a privacy-conscious user, I want my audio and sign photos stored locally by default with a one-tap “Clear data” so that my content stays private.
Acceptance: No uploads occur unless I explicitly enable cloud backup (off by default); “Clear data” removes library, history, and cached audio (system permissions unaffected).

10. Clear error guidance
As a user, I want helpful messages when mic/camera permissions are denied or noise/blur is detected so that I know how to fix it.
Acceptance: Mic/camera denial shows an action to open Settings; noisy audio suggests retry; blurred capture suggests retake.

Performance guardrails
As a user, I want the app to feel responsive and not drain the battery during short sessions so that it’s reliable for daily use.
Acceptance: Cold start ≤3s on reference device; playback begins ≤2s after mic release; morphing stays ≥30fps; 

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
