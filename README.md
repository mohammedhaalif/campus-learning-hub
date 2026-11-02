# Campus Learning Hub

A React + Vite educational dashboard with Supabase Auth/database and an n8n webhook chat integration.

## Features

- Student signup/login with name, email, password, school and class (1st–10th)
- Mock signup confirmation screen
- Teacher material publishing and management
- Student dashboard filtered by the student's class
- Campus AI chat wired to an n8n webhook
- Responsive layouts and Supabase Row Level Security policies
- Local preview mode when Supabase is not configured

## 1. Requirements

- Node.js 20+ recommended
- A Supabase project
- An n8n webhook configured to accept a JSON POST (for AI chat)

## 2. Run locally

```bash
npm install
cp .env.example .env
npm run dev
```

Fill `.env` with your Supabase project URL, anon key, and n8n webhook URL. You can also use `.env.local` for machine-specific settings; Vite loads it and Git ignores it. Restart Vite after changing environment variables.

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
VITE_N8N_WEBHOOK_URL=https://YOUR_N8N_HOST/webhook/YOUR_WEBHOOK_ID
```

Only the Supabase anon/publishable key belongs in frontend variables. Never expose a Supabase `service_role` key.

## 3. Set up Supabase

1. Open Supabase Dashboard → SQL Editor.
2. Run `supabase/schema.sql`.
3. In Authentication → Providers / Email, disable **Confirm email** if you want signups to sign in immediately. The app's confirmation page is only a mock UI; it does not send or verify email.
4. Set up a trusted teacher account before production. The frontend demo bypass (`admin@gmail.com` / `admin`) is intentionally not a secure production login and does not satisfy the SQL admin JWT policy.
5. For production, create a real Supabase Auth user for the teacher and set `app_metadata.role = "admin"` using a trusted server-side Admin API or Supabase Dashboard. Never grant admin via user-editable metadata or expose service-role keys in the browser.

Supabase's built-in email service is rate-limited (2 emails per hour). For production signups, configure a custom SMTP provider in the Supabase Auth settings. Disabling **Confirm email** avoids confirmation emails during local testing, but should not be used when email verification is required.

### Important profile / admin notes

- Students can insert their own profile with role `student`; students cannot create an admin profile through the provided insert policy.
- Admin policies rely on the signed JWT `app_metadata.role` claim.
- For a real teacher login, configure that account in Supabase Auth and set the trusted app metadata. You should then replace the demo bypass branch in `src/App.jsx` with regular Supabase Auth sign-in for the teacher.
- Supabase RLS policies are the real data boundary. UI routing alone is not security.

## 4. Configure n8n

Set `VITE_N8N_WEBHOOK_URL` to your n8n Webhook node's production URL. A simple workflow:

1. **Webhook** node: POST, response mode configured to return the final result.
2. **LLM / AI Agent** node: use the incoming `message` or `chatInput` field as the student question.
3. **Respond to Webhook** node: return JSON such as:

```json
{ "output": "Here is a simple explanation..." }
```

The app sends:

```json
{
  "message": "Explain fractions",
  "chatInput": "Explain fractions",
  "student": { "name": "Student Name", "school": "School", "class": "5" },
  "history": []
}
```

The chat accepts common response keys: `output`, `response`, `answer`, `text`, or `message`, including those keys nested in an array or object. The workflow must be active and use its production webhook URL.

Because the browser sends JSON, it first sends an `OPTIONS` CORS preflight request. Configure n8n (or a trusted reverse proxy) to answer `OPTIONS` for the webhook with an allowed origin matching the app (for local preview, `http://localhost:4173`), `Access-Control-Allow-Methods: POST, OPTIONS`, and `Access-Control-Allow-Headers: Content-Type`. The `POST` response must also include `Access-Control-Allow-Origin`. A CORS header on only the `POST` response does not resolve a failed preflight. Do not send sensitive student information to external AI workflows without appropriate permission and safeguards.

## 5. Admin demo credentials

- Email: `admin@gmail.com`
- Password: `123456`
- Select **Teacher access** on the sign-in screen to open the separate teacher login.

**Demo only:** this is a client-side bypass, not secure authentication. Materials published through it are stored only in the current browser and are not shared with other users or devices. Anyone who can inspect the frontend can discover the credentials, and the bypass does not provide trusted Supabase admin claims. Do not deploy it publicly. For shared production publishing, use a real Supabase Auth teacher account and grant its `app_metadata.role = "admin"` through a trusted server/Admin API.

## 6. Build

```bash
npm run build
npm run preview
```

## Project layout

```text
campus-learning-hub/
├── src/
│   ├── lib/
│   │   ├── classes.js
│   │   └── supabase.js
│   ├── App.jsx
│   ├── index.css
│   └── main.jsx
├── supabase/
│   └── schema.sql
├── .env.example
├── index.html
├── package.json
├── postcss.config.js
├── tailwind.config.js
└── vite.config.js
```
