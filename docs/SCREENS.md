# Screen registry

Use the written screen specifications in the prompt as the source for implementation.

## Shared section top bar

Used by section screens: menu button on the left; centered title with a date subtitle (reserve a slot but do not show weather); new-study plus button on the right. The section name appears only in this top bar; the page heading is separate.

## Screens

### 1. App drawer

- **Name:** App drawer
- **Route:** `/app-drawer` (`app-drawer`)
- **Feature folder:** `lib/features/navigation/screens/app_drawer/`
- **Elements, top to bottom:** Dark-green drawer over a dimmed page; VIDE wordmark and search icon; navigation with Chat active, Flashcards, Focus timer, and Study profile; divider; “Recents” label; scrollable recent chats, each with an icon and title; pinned bottom account avatar with initial opening an account menu; account menu items Upgrade to Pro, Settings, Dark theme, and Sign out (red); amber “New study” button. Do not include RGEN (beta) until its feature is defined.
- **States:** Loading, recents empty, error, offline; drawer open/closed and account menu open/closed.
- **Status:** not built

### 2. Chat home

- **Name:** Chat home
- **Route:** `/chat-home` (`chat-home`)
- **Feature folder:** `lib/features/chat/screens/chat_home/`
- **Elements, top to bottom:** Top bar with menu on the left and timer on the right; centered VIDE logo and greeting headline; composer pinned at the bottom with field “Ask anything, or paste a screenshot,” plus button, voice button, “Casual” mode chip with chevron, and round send button disabled until there is text; footer “VIDE can make mistakes. Check important information.”
- **States:** Loading, initial/empty chat, error, offline; send disabled/enabled based on text.
- **Status:** not built

### 3. Study mode sheet

- **Name:** Study mode sheet
- **Route:** `/study-mode-sheet` (`study-mode-sheet`)
- **Feature folder:** `lib/features/study_mode/screens/study_mode_sheet/`
- **Elements, top to bottom:** Bottom sheet with drag handle; “Study mode” title; “Choose how Vide structures your learning” helper; close X; mode cards. Casual is shown with an “Active” badge and “Normal chat, banter & downtime.” Other modes seen as filters on All chats are Tutor, Socratic, Quiz Master, and Exam; the complete mode list is pending.
- **States:** Loading, mode list empty, error, offline; selected/active mode and closed.
- **Status:** not built

### 4. Attach menu

- **Name:** Attach menu
- **Route:** `/attach-menu` (`attach-menu`)
- **Feature folder:** `lib/features/attachments/screens/attach_menu/`
- **Elements, top to bottom:** Popover above the composer; “Upload a file” with PDF, Word, slides, and text support; “Add photos” with PNG/JPG and up-to-10-MB limit; divider; “Add chat” with “Pick up a past conversation” and a “1 left today” quota pill. The composer plus changes to X while open. Do not include the desktop paste/drag tip.
- **States:** Loading, no eligible past chats, error, offline; open/closed and quota available/exhausted.
- **Status:** not built

### 5. Focus session popover

- **Name:** Focus session popover
- **Route:** `/focus-session-popover` (`focus-session-popover`)
- **Feature folder:** `lib/features/focus/screens/focus_session_popover/`
- **Elements, top to bottom:** Opens from the timer icon; “Focus session” title; helper text; duration chips for 15, 25, 45, and 60 minutes, with selected duration dark green; minus/value/plus stepper; amber “Start focus” button.
- **States:** Loading, empty preset data, error, offline; selected duration and session starting/ready.
- **Status:** not built

### 6. Flashcards

- **Name:** Flashcards
- **Route:** `/flashcards` (`flashcards`)
- **Feature folder:** `lib/features/flashcards/screens/flashcards/`
- **Elements, top to bottom:** Shared section top bar with date subtitle and plus; “Flashcards” page heading and subtitle; tabs All, Needs review, and Mastered with counts; empty-state icon tile; “No flashcards yet” message and helper text.
- **States:** Loading, no flashcards, error, offline; All/Needs review/Mastered filters and counts.
- **Status:** not built

### 7. Focus timer

- **Name:** Focus timer
- **Route:** `/focus-timer` (`focus-timer`)
- **Feature folder:** `lib/features/focus/screens/focus_timer/`
- **Elements, top to bottom:** Page heading and subtitle; card with “Ready to study” status pill, ring timer “25:00” and “25 min session”; 2×2 duration presets: 15 “Quick sprint,” 25 “Pomodoro,” 45 “Standard lecture,” and 60 “Deep dive” (selected preset dark green); stepper; amber “Start focus” button with play icon; three stat cards for Total time studied, Completed sprints, and Study points; study technique tip card.
- **States:** Loading, empty stats, error, offline; ready/running/completed session and selected preset.
- **Status:** not built

### 8. Study profile

- **Name:** Study profile
- **Route:** `/study-profile` (`study-profile`)
- **Feature folder:** `lib/features/profile/screens/study_profile/`
- **Elements, top to bottom:** Page heading and “Edit profile” button; Academic identity section with name, email, level, university, and department; Current focus; Teaching style with “Active preferences 0/5” and dashed “Add” chip; Review queue; Context bio. Each section has an empty-state line.
- **States:** Loading, empty profile sections, error, offline.
- **Status:** not built

### 9. Study profile edit

- **Name:** Study profile edit
- **Route:** `/study-profile-edit` (`study-profile-edit`)
- **Feature folder:** `lib/features/profile/screens/study_profile_edit/`
- **Elements, top to bottom:** Form sections matching the profile: first name, last name, student email, academic-level dropdown, current-focus field (placeholder must not be cut off), and multiline context bio; sticky bottom bar with “Cancel” and “Save changes.”
- **States:** Loading existing profile, empty fields, error, offline; editing, validation errors, saving, and saved.
- **Status:** not built

### 10. All chats

- **Name:** All chats
- **Route:** `/all-chats` (`all-chats`)
- **Feature folder:** `lib/features/chat/screens/all_chats/`
- **Elements, top to bottom:** Shared section top bar; “All chats” heading and count; search field without a “/” badge; horizontally scrolling filters All, Tutor, Socratic, Quiz Master, and Exam; chats grouped under “Today” and “Previous 30 days.” Each chat card has a title, mode badge, one-line preview, and time or date.
- **States:** Loading, no matching chats, error, offline; search/filter selection and empty date groups.
- **Status:** not built
