# FINAL FIX - Allow Localhost Connections

## The Problem
Xcode is auto-generating an Info.plist AND we were trying to add one manually. This causes a conflict.

## The Solution
Remove all manual Info.plist files (done ✅) and add the settings directly in Xcode.

---

## Steps (Takes 2 minutes):

### 1. Close Xcode Completely
- Press ⌘Q to quit Xcode
- This ensures clean build

### 2. Delete Build Cache
Run this in Terminal:
```bash
cd "/Users/hadiabbas/Downloads/FitTrack/FitTrack Code"
rm -rf ~/Library/Developer/Xcode/DerivedData/FitTrack_Code-*
```

### 3. Reopen Xcode
- Open `FitTrack Code.xcodeproj`

### 4. Add Security Settings in Xcode

**Step-by-step with screenshots in mind:**

a) In Xcode, click the **blue "FitTrack Code"** icon at the very top of the left sidebar (looks like a blueprint)

b) In the main panel, you'll see two sections:
   - **PROJECT**: FitTrack Code
   - **TARGETS**: FitTrack Code ← **CLICK THIS ONE**

c) At the top of the main panel, click the **"Info"** tab (next to "General", "Signing & Capabilities", etc.)

d) You'll see a section called **"Custom iOS Target Properties"**

e) Hover over any row and you'll see a **"+"** button appear on the left

f) Click the **"+"** button

g) A dropdown will appear. Start typing: `App Transport Security Settings`

h) Select it. It will be added as type **Dictionary**

i) Click the **small triangle/arrow (▶)** next to "App Transport Security Settings" to expand it

j) You'll see it now has its own **"+"** button. Click it.

k) Add first setting:
   - Key: Type `Allow Arbitrary Loads`
   - Type: Change to **Boolean**
   - Value: Check the box to make it **YES** (or select YES from dropdown)

l) Click the **"+"** next to "App Transport Security Settings" again

m) Add second setting:
   - Key: Type `Allow Local Networking`
   - Type: Change to **Boolean**
   - Value: Check the box to make it **YES**

n) Final result should look like:
```
Custom iOS Target Properties
  ▼ App Transport Security Settings      Dictionary
    ▶ Allow Arbitrary Loads               Boolean    YES
    ▶ Allow Local Networking              Boolean    YES
```

### 5. Clean Build
- Press **⌘⇧K** (Command + Shift + K)
- This cleans all previous builds

### 6. Build and Run
- Press **⌘R** (Command + R)

---

## Test It

1. The app should launch without the build error
2. Try to register with:
   - Email: `hadi@gmail.com`
   - Password: `password123`

3. Check the Console (⌘⇧Y) - you should see:
```
🌐 Making request to: http://localhost:8080/api/v1/auth/register
📤 Request to: POST http://localhost:8080/api/v1/auth/register
📥 Received response
```

4. You should be logged in! ✅

---

## Still Getting the Error?

If you still see "Multiple commands produce Info.plist":

1. In Xcode, select the project → Target → Build Settings
2. Search for: `GENERATE_INFOPLIST_FILE`
3. Make sure it's set to **YES**
4. Search for: `INFOPLIST_FILE`  
5. Make sure it's **empty** or set to an auto-generated path
6. Clean and rebuild

---

## Alternative: Use HTTPS with ngrok (Skip localhost issues entirely)

If the above doesn't work, we can use ngrok to avoid localhost altogether:

```bash
# Install ngrok
brew install ngrok

# Run ngrok (in a new terminal, keep it running)
ngrok http 8080

# You'll get a URL like: https://abc123.ngrok-free.app
```

Then in `NetworkManager.swift`, change line 28 to:
```swift
private let baseURL = "https://abc123.ngrok-free.app/api/v1"
```

This uses HTTPS so iOS won't block it!

---

Let me know if you need help with any step!

