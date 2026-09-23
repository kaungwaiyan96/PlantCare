# Firebase Authentication Setup

The app now uses Firebase Authentication for email/password and Google sign-in. The guest button remains local-only.

## 1. Create the Firebase iOS app

1. Open the [Firebase Console](https://console.firebase.google.com/) and create or select a project.
2. Click **Project overview → Add app → iOS**.
3. Enter the bundle ID exactly as `com.plantcare.PlantCare`.
4. Download `GoogleService-Info.plist`.
5. Drag that file into the `PlantCare` group in Xcode and select the **PlantCare** target under **Target Membership**. Do not commit it if this repository is public.
6. Open the downloaded plist and copy its `REVERSED_CLIENT_ID` value into `GOOGLE_REVERSED_CLIENT_ID` in `PlantCareSecrets.xcconfig` (copy `Secrets.xcconfig.template` first if needed).

## 2. Enable email/password

1. Go to **Build → Authentication → Sign-in method**.
2. Enable **Email/Password**.
3. Save.

## 3. Enable Google

1. In the same **Sign-in method** page, enable **Google**.
2. Select a project support email and save.
3. In **Project settings → Your apps → iOS app**, confirm the iOS bundle ID is `com.plantcare.PlantCare`.
4. The Google button uses the client ID from `GoogleService-Info.plist`; the reversed client ID must also be present in the app URL scheme as described above.

## 4. Test

1. In Firebase Console → Authentication → Users, verify that a test account appears after email/password sign-up.
2. Test Google on a real device or simulator with a valid Google account.
4. If a provider is not configured yet, the app displays the Firebase error instead of silently logging in locally.
