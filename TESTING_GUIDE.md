# FitTrack Testing Guide

## Phase 0: Testing Authentication

### Prerequisites
- ✅ Backend server is running on http://localhost:8080
- ✅ Supabase database is set up

### Test 1: Register a New Account

1. **Build and run the app** in Xcode
   - Open `FitTrack Code.xcodeproj` in Xcode
   - Select your simulator or device
   - Press ⌘R to run

2. **You should see the login screen** with:
   - FitTrack logo
   - Toggle between Login and Register
   - Email and password fields

3. **Create a new account:**
   - Click "Register" tab
   - Enter email: `test@example.com`
   - Enter password: `password123` (minimum 8 characters)
   - Confirm password: `password123`
   - Click "Create Account"

4. **Expected result:**
   - Loading spinner appears briefly
   - You're automatically logged in
   - You see the main app (Activities, Summary, etc.)

### Test 2: Verify Account in Supabase

1. Go to your Supabase dashboard
2. Click "Authentication" in the left sidebar
3. You should see your new user (`test@example.com`) in the list

### Test 3: Logout

1. In the app, swipe to the "Summary" tab
2. You should see your email at the top
3. Tap the logout icon (→|) in the top right
4. Confirm logout
5. You should return to the login screen

### Test 4: Login with Existing Account

1. On the login screen, make sure "Login" tab is selected
2. Enter email: `test@example.com`
3. Enter password: `password123`
4. Click "Login"
5. You should be logged in and see the main app

### Test 5: Wrong Password

1. Logout if logged in
2. Try to login with wrong password
3. You should see an error message: "Invalid email or password"

### Test 6: Password Persistence

1. Login successfully
2. Close the app completely (swipe up in app switcher)
3. Reopen the app
4. You should still be logged in (no login screen)

---

## Common Issues

### "Failed to create account"
- Check that your backend server is running
- Check the Xcode console for error messages
- Verify your Supabase credentials in backend/.env

### "Invalid URL" error
- If testing on a real device (not simulator):
  - Find your Mac's IP address (System Settings → Network)
  - Update `NetworkManager.swift` line 21 to use your IP:
    ```swift
    private let baseURL = "http://YOUR_IP_ADDRESS:8080/api/v1"
    ```

### Backend connection issues
- Make sure backend server is running: `cd backend && go run cmd/api/main.go`
- Check that port 8080 is not blocked by firewall

---

## Next Phase

Once authentication is working:
- ✅ You can create an account
- ✅ You can login
- ✅ You can logout
- ✅ Session persists after closing app

**We'll move to Phase 1: Syncing workouts to the cloud!**

