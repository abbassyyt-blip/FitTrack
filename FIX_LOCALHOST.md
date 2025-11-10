# Fix: Allow App to Connect to Localhost

## The Problem
iOS blocks apps from connecting to HTTP servers (not HTTPS) for security. This includes localhost (your backend server).

## The Solution
I've created an `Info.plist` file that tells iOS to allow these connections. Now we need to add it to your Xcode project.

## Steps to Fix (2 minutes):

### Option 1: Using Xcode (Recommended)

1. **Open your project in Xcode**
   - Open `FitTrack Code.xcodeproj`

2. **Select the project in the navigator**
   - Click "FitTrack Code" at the very top of the left sidebar (the blue icon)

3. **Select the target**
   - In the center panel, under "TARGETS", click "FitTrack Code"

4. **Go to Info tab**
   - Click the "Info" tab at the top

5. **Add the Info.plist file**
   - Look for "Custom iOS Target Properties" section
   - You should see a "+" button to add entries
   - OR: At the bottom, look for "Generate Info.plist File" toggle - turn it OFF if it's on

6. **Point to the Info.plist file**
   - In the "TARGETS" section, under "Build Settings" tab
   - Search for "Info.plist"
   - Find "Info.plist File" setting
   - Set it to: `FitTrack Code/Info.plist`

7. **Clean and rebuild**
   - Press `⌘⇧K` (Clean Build Folder)
   - Press `⌘R` (Run)

### Option 2: Manual XML Edit (If Option 1 doesn't work)

If you already have an Info.plist somewhere:

1. Find your existing Info.plist file in Xcode
2. Right-click it → "Open As" → "Source Code"
3. Add this inside the `<dict>` tag (before the closing `</dict>`):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

4. Save and rebuild

---

## Verify It's Working

After rebuilding, try to register again. In the console you should now see:

```
🌐 Making request to: http://localhost:8080/api/v1/auth/register
📤 Request to: POST http://localhost:8080/api/v1/auth/register
📥 Received response
```

Instead of "Could not connect to the server"

---

## Alternative: Use ngrok (If above doesn't work)

If you're still having issues:

1. Install ngrok: `brew install ngrok`
2. Run: `ngrok http 8080`
3. You'll get a URL like: `https://abc123.ngrok.io`
4. Update `NetworkManager.swift` line 28 to use this URL:
   ```swift
   private let baseURL = "https://abc123.ngrok.io/api/v1"
   ```

---

## Need Help?

Take a screenshot of your Xcode project settings (Build Settings tab, search for "Info.plist") and I can help debug!

