# Supabase Configuration for Development

## Allow Test Emails (Optional - For Development Only)

By default, Supabase validates email addresses and rejects obviously fake ones like `test@example.com`. For development, you can disable this:

### Option 1: Use Real Email Format (Recommended)
Just use a realistic email address when testing:
- ✅ `yourname@gmail.com`
- ✅ `hadi@fittrack.app`
- ✅ `test@myapp.io`
- ❌ `test@example.com` (Supabase blocks this)

### Option 2: Disable Email Confirmation (For Development)

1. Go to your Supabase Dashboard
2. Click **Authentication** → **Settings** (in the Auth section)
3. Scroll down to **Email Auth**
4. Find "Enable email confirmations"
5. **Turn it OFF** for development
6. Click **Save**

Now you can use any email format, even `test@test.com`

### Option 3: Use Disposable Email Services

For testing, you can use:
- temp-mail.org
- guerrillamail.com
- 10minutemail.com

These give you real, working email addresses for testing.

---

## Email Verification (Production)

For production, you should:
1. **Keep email confirmation ON**
2. Configure a custom SMTP provider (like SendGrid, Mailgun)
3. Supabase Settings → Auth → SMTP Settings

This ensures:
- Real users verify their emails
- Better security
- No spam accounts

---

## Current Configuration Status

Check your settings:
1. Go to Supabase Dashboard
2. Authentication → Settings
3. Verify:
   - ✅ Email auth is enabled
   - 🔧 Email confirmation (ON for prod, OFF for dev)
   - 🔧 Secure password requirements

---

## Quick Test

After changing settings, test with:

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"yourtest@gmail.com","password":"password123"}'
```

You should get a successful response with a token!

