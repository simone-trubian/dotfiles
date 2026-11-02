---
name: draft-message
description: Draft a reply, message or email for the user to paste into Outlook, Teams, Zoom, Slack or any other app. Every draft goes on a local HTML copy page in ~/Documents/Drafts with Copy (keeps formatting), Copy as plain text and Copy subject buttons; one page per thread, each revision a new card on top; once sent, the final text is filed in the case folder. Use whenever asked to draft, write, reword or answer a message, email, chat or DM, even if no page is mentioned. Trigger phrases: draft a reply, write an email, message to, reply to, answer this email, draft a Teams message, Zoom message, Slack message, reword this, make it shorter, it was sent, file the message.
---

# Draft message

The user pastes drafts into other apps. Terminal text copies badly, so every draft goes on a copy page.

## 1. Write the message

Fit the channel:

| Channel | Shape |
|---|---|
| Email (Outlook) | Subject line. Greeting by first name, short paragraphs, sign-off as the user signs earlier messages. Bold, bullets and links are fine. |
| Teams or Slack chat | No subject. "Hi Name," at most, then the point. Short; bullets are fine; no headings. |
| Zoom chat, SMS, anything plain | As chat, but assume all formatting is lost: no tables, links as bare URLs. |

For every channel:
- Never put a secret in a message: passwords, API keys, client secrets, tokens, connection strings.
- Follow the project's rules about what may go to an outside recipient.
- Match the user's voice, spelling and language from their earlier messages. No headings in a chat
  message, no tables anywhere, no sign-off that names Claude or AI.

## 2. Put it on the copy page

- **Folder:** `~/Documents/Drafts/` (Windows: `%USERPROFILE%\Documents\Drafts`). Create it if missing.
- **One page per thread:** `YYYY-MM-DD-<recipient-or-topic>.html`, dated when the thread started. A revision
  of the same message, or the next message in the same thread, goes on the same page as a new card at the
  top; never make `-2`, `-3` files. In a new session, look in the folder for the thread's page first.
- **New page:** copy `template.html` from this skill's folder, set `<title>` and the `<h1>` to the thread
  (e.g. "Reply to Ashley"), and replace the sample card.
- **Card markup**, newest first, directly after the `MESSAGES` comment:

```html
<article class="msg" data-channel="email">
  <div class="meta"><b>To: Ashley</b><span>Email</span><span>v2 · 2026-11-02 14:30</span></div>
  <div class="subject">Subject line</div>
  <div class="body">
    <p>Hi Ashley,</p>
    <p>Paragraph with <strong>bold</strong> and a <a href="https://example.com">link</a>.</p>
    <ul><li>Bullet</li></ul>
    <p>Thanks,<br>Name</p>
  </div>
</article>
```

  - `data-channel`: `email`, `chat` or `plain`. Only `email` cards have a `subject` div.
  - The body is plain semantic HTML: `p`, `br`, `strong`, `em`, `a`, `ul`/`ol`/`li`. No classes, no inline
    styles: the recipient's app applies its own font.
  - Mark earlier versions of the same message with `class="msg superseded"` so they dim.
  - The page adds the buttons itself: **Copy** puts formatted and plain text on the clipboard together,
    **Copy as plain text** and **Copy subject** put plain text only.
- **Open it:** after creating the page, open it in the browser (Windows `Start-Process <path>`, macOS
  `open <path>`). After adding a card, tell the user to refresh.

## 3. Report in chat

Give the page path, then the message text so the user can review it without switching windows, then any
point to check before sending (a fact not yet verified, a name or date to confirm).

## 4. When the user says it was sent

File the final text in the folder for the case, partner or request the message is about:

1. Ask for the sent version if the user edited it before sending; otherwise use the newest card.
2. If that folder has its own rule for sent material (a `shared\`, `sent\` or `archive\` subfolder, say),
   follow it. Otherwise save `sent-YYYY-MM-DD-<recipient>.md` in the case folder.
3. Start the file with `To:`, `Channel:`, `Sent:` (date) and, for an email, `Subject:`, then the text as
   Markdown.
4. If the folder keeps a log, add a dated line saying what was sent to whom.
5. If no case folder exists, ask where to file it. Don't commit unless asked.
