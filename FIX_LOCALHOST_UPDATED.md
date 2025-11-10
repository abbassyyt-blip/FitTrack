# Fix: Allow App to Connect to Localhost (Updated)

## The Problem
iOS blocks HTTP connections for security. We need to tell it to allow localhost.

## The Solution (2 minutes)
Add the security exception directly in Xcode:

### Steps:

1. **Open Xcode** and make sure your project is open

2. **Click on the blue "FitTrack Code" project** at the very top of the left sidebar (the icon looks like a blueprint)

3. **Select the target**
   - In the main panel, under **TARGETS** (not PROJECT), click "FitTrack Code"

4. **Go to the Info tab**
   - At the top of the main panel, click **"Info"**

5. **Add the security settings**
   - Look for the section called **"Custom iOS Target Properties"**
   - You'll see a list of settings
   - Hover over any row and click the **"+"** button to add a new row

6. **Add these exact settings** (one by one):

   **First setting:**
   - Key: `App Transport Security Settings` (Xcode might auto-suggest this - select it)
   - Type: Dictionary
   - Click the little arrow next to it to expand
   
   **Inside App Transport Security Settings, add two sub-items:**
   
   Click the "+" next to "App Transport Security Settings":
   
   a) **Sub-item 1:**
      - Key: `Allow Arbitrary Loads`
      - Type: Boolean
      - Value: **YES**
   
   b) **Sub-item 2:**
      - Key: `Allow Local Networking`
      - Type: Boolean  
      - Value: **YES**

7. **It should look like this:**
   ```
   App Transport Security Settings (Dictionary)
     ▼ Allow Arbitrary Loads (Boolean) = YES
     ▼ Allow Local Networking (Boolean) = YES
   ```

8. **Save and rebuild:**
   - Press **⌘S** to save
   - Press **⌘⇧K** (Clean Build Folder)
   - Press **⌘R** (Run)

---

## Alternative: Edit the auto-generated Info.plist

If the above is confusing:

1. In Xcode, press **⌘⇧O** (Open Quickly)
2. Type "Info.plist" and look for one in DerivedData or Build folder
3. Click on it
4. Right-click the file → "Show in Finder"
5. Open it in TextEdit
6. Add this before the closing `</dict>`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

7. Save and rebuild in Xcode

---

## Test It

After doing this, run the app and try registering with:
- Email: `hadi@gmail.com`
- Password: `password123`

You should see it connect successfully!

---

## Still Having Issues?

Take a screenshot of:
1. Xcode → Project → Target → Info tab
2. The error you're seeing

And I'll help you fix it!

