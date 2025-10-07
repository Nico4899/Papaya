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

**Papaya** is a spoken-to-sign language translation app that bridges communication between hearing and deaf users.  
It listens to short spoken phrases, matches each word to a photo of the corresponding sign from a local sign library, and displays the sequence with smooth transitions.  
Users can add missing sign entries by taking their own photos, building a personalized sign library over time.

### Problem Statement

Millions of deaf signers rely on sign languages for natural, fluent communication. In day-to-day interactions at offices, clinics, universities, and public transit, spontaneous access to human interpreters is rare, while text chat and lip-reading are slow, inaccurate, or cognitively demanding. Hearing people often don't know even basic signs, which turns simple, time-critical exchanges into frustrating experiences and social exclusion.
Papaya addresses this gap by translating short spoken statements into a transcript, matching each word to a sign entry in a sign library, and presenting an ordered sign sequence with smooth transitions. The primary users are deaf signers who need fast comprehension of what a hearing person just said. Secondary users include hearing users, staff, educators, and family members who want to communicate respectfully without waiting for an interpreter.
Solving this matters, because accessible communication is a prerequisite for autonomy, safety, and equal participation. Papaya keeps audio and sign photos local by default and offers clear data to remove all stored content with one tap.

### Requirements

#### Functional Requirements (User Stories)

1. **Real-time speech capture** <br />
As a hearing user, I want to capture speech (press-and-hold) so that the deaf signer can see the sign sequence right after I finish.

2. **Word lookup & sequence assembly** <br />
As a Deaf signer, I want each spoken word in the transcript matched to a sign entry so that a whole sign sequence plays in order.

3. **Smooth transitions** <br />
As a Deaf signer, I want smooth transitions between consecutive sign photos so that the sequence is easy to follow.

4. **Missing word detection & prompt** <br />
As a user, I want the app to detect missing words prompt add entry so that the sequence can still be completed.

4. **Add sign entry** <br />
As a user, I want to capture image of the sign and save entry so the new sign entry is available immediately.

5. **Playback controls** <br />
As a Deaf signer, I want play/pause, previous/next word, and replay current so I can review unclear parts.

6. **Sign library management** <br />
As a user, I want to search, edit, and delete sign entries so that I can keep the sign library clean.

9. **Privacy & local storage** <br />
As a privacy-conscious user, I want my audio and sign photos stored locally by default with a one-tap clear data action so my content stays private.

10. **Clear error guidance** <br />
As a user, I want helpful error messages when permissions are denied or noise/blur is detection triggers so I know how to fix it.

#### Quality Attributes & External Constraints

*TODO: For each required quality attribute or constraint (e.g., HIG usability, dark mode, responsiveness, persistence, logging, error handling, responsible AI usage), add a short subsection that summarizes your solution, links to supporting evidence (file, screenshot, test, or slide), and notes any follow-up work. When documenting responsible AI usage, summarize prompts you ran, how you reviewed/adapted the output, and the guardrails (manual testing, peer review, etc.) you applied.*

* **Responsible AI usage:** *TODO — add this once you document your AI-supported work (prompt highlights, review steps, guardrails, evidence links).*
* **Other attributes / constraints:** *TODO — add concise subheadings with one-paragraph summaries and supporting links or screenshots.*

#### Glossary (Abbott’s Technique)

| Terms    | Definition      |
| ------------- | ------------- | 
| User | Any person using Papaya. Is either a hearing user or a deaf signer |
| Hearing User | Person who speaks into Papaya. Creates a spoken statement. | 
| Deaf Signer | A deaf or hard-of-hearing person who reads the sign sequence. |
| Spoken Statement | A short, recorded segment of speech recorded by the hearing user. Becomes a transcript. | 
| Transcript | The text produced from the spoken statement. Used to build a sign sequence from the sign librry and may reveal missing signs. |
| Sign Photo | Image showing a sign. Included in a sign entry and displayed within a sign sequence. |
| Sign Entry | A stored word-sign pair kept in the sign library and referenced by sign sequences. | 
| Sign Library | Collection of sign entries on the device. Supplies entries to build sign sequence and accepts new sign entries. |
| Sign Sequence | Ordered sequence of sign photos. Built from a transcript via the sign library and viewed by the deaf signer. | 
| Missing Word | Word in the transcript without a matching sign entry. Triggers a prompt to add one. | 
| Prompt | Message asking to add a sign. Leads to capturing a sign photo to create sign entry. | 

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
