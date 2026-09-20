# PlantCare: Sign In & Sign Up (Authentication & Onboarding) Specification

**Course Target**: 100/100 Marks Rubric Alignment  
**Document Purpose**: Official proposal write-up, technical specification, and presentation script for the Sign In / Sign Up feature in **PlantCare: Scan, Identify, and Grow**.

---

## 1. Project Proposal Section (Drop-in for 2-Page Proposal / Report)

### Screen Description: Sign In & Sign Up (Authentication & User Profile)
The **Sign In / Sign Up** screen serves as the user onboarding and account management gateway for *PlantCare*. It personalizes the botanical care experience while enabling secure cross-device synchronization of the user's digital garden, custom care schedules, and health diagnostic history.

#### Key Features & User Flow:
1. **Frictionless Onboarding with "Guest Mode" (Apple HIG Compliant)**:
   - Users can choose **"Continue as Plant Guest"** to immediately access the core plant scanner, search encyclopedia, and care guides without being forced to create an account.
   - Any plants saved during guest mode are securely stored in local device storage (**SwiftData**) and can be seamlessly merged into a newly created account later.

2. **Sign In with Apple Integration**:
   - One-tap biometric authentication using **Face ID / Touch ID** via Apple's native `AuthenticationServices` framework.
   - Respects user privacy through Apple's private relay email masking, providing the highest level of trust and Apple ecosystem compliance.

3. **Email & Password Authentication**:
   - Clean, validated input fields for traditional sign-in and account registration.
   - Features real-time client-side email format validation, secure password masking with show/hide toggle, and dynamic password strength indicators.

4. **Gardening Profile Personalization**:
   - During registration, users can personalize their plant parent profile by selecting their gardening experience level (*Beginner*, *Intermediate*, *Master Gardener*).
   - The app dynamically tailors care tips and watering notification complexity based on this profile.

5. **Signature Liquid Glass Aesthetic**:
   - Built with the app's signature **Liquid Glass / Glassmorphism** design language.
   - Features translucent frosted text fields (`.ultraThinMaterial`), subtle specular border reflections, an ambient botanical glow background, and fluid spring animations when toggling between "Sign In" and "Create Account".

---

## 2. Technical Architecture & Security (Rubric Marks Alignment)

### A. State Management & Session Flow
```
                     ┌──────────────────────────────┐
                     │       PlantCare Launch       │
                     └──────────────┬───────────────┘
                                    │
                                    ▼
                     ┌──────────────────────────────┐
                     │    Check Authentication     │
                     │ (Keychain / @AppStorage)     │
                     └──────┬────────────────┬──────┘
            Authenticated   │                │ Guest / First Launch
                            │                │
                            ▼                ▼
                     ┌──────────────┐ ┌──────────────┐
                     │ MainTabView  │ │  Auth View   │
                     │ (Full Sync)  │ │ (Sign In/Up) │
                     └──────────────┘ └──────┬───────┘
                                             │
                       ┌─────────────────────┴─────────────────────┐
                       ▼                                           ▼
             [Sign in with Apple]                         ["Continue as Guest"]
             • Face ID / Touch ID                         • Instant Zero-Friction Access
             • Apple Private Relay Email                  • Local SwiftData Garden
             • Secure Keychain Session                    • Persistent on Device
```

### B. Security & Apple Privacy Standards
1. **iOS Keychain Storage (`Security.framework`)**:
   - User authentication tokens and session refresh credentials are stored strictly in the encrypted iOS **Keychain Services** (`kSecClassGenericPassword`), ensuring zero exposure in plaintext `UserDefaults` or disk files.
2. **Apple Human Interface Guidelines (HIG) Compliance**:
   - Adheres to Apple's mandatory guidelines for Sign in with Apple: displays the standard `ASAuthorizationAppleIDButton` without altering Apple's trademarked styling.
   - Avoids mandatory registration walls by providing a clear, prominent "Continue as Guest" path so evaluators and users can test all features instantly.
3. **Seamless SwiftData Migration**:
   - Unauthenticated guest plants stored in SwiftData carry an optional `ownerID: String?`. When a guest transitions to an authenticated user, existing local plant records are preserved and assigned to the authenticated user ID without data loss.

---

## 3. Screen Layout & Hand-Drawn Wireframe Guide

For team members creating or updating the hand-drawn wireframe sketches for the proposal document:

```
┌──────────────────────────────────────────────┐
│  9:41                             ▲ 5G 100%  │
│                                              │
│                  🌿 [Logo]                   │
│                  PlantCare                   │
│         "Scan, Identify, and Grow"           │
│                                              │
│      ┌────────────────────────────────┐      │
│      │ [ Sign In ]    [ Create Account ]│      │  <- Frosted Glass Segmented Toggle
│      └────────────────────────────────┘      │
│                                              │
│      ┌────────────────────────────────┐      │
│      │ ✉️  Email Address               │      │  <- Frosted Input Field (.ultraThinMaterial)
│      └────────────────────────────────┘      │
│      ┌────────────────────────────────┐      │
│      │ 🔒 Password                 👁️ │      │  <- Frosted Input Field with Show/Hide
│      └────────────────────────────────┘      │
│                                              │
│                 Forgot Password?             │
│                                              │
│      ┌────────────────────────────────┐      │
│      │          Sign In 🌿            │      │  <- Emerald Glow Primary Button
│      └────────────────────────────────┘      │
│                                              │
│                 ─── or ───                   │
│                                              │
│      ┌────────────────────────────────┐      │
│      │       Sign in with Apple      │      │  <- Native Apple ID Button
│      └────────────────────────────────┘      │
│                                              │
│             Continue as Plant Guest  →       │  <- Guest Bypass (Apple HIG)
│                                              │
└──────────────────────────────────────────────┘
```

---

## 4. 10-Minute Live Presentation Script & Evaluator Q&A

### Presentation Talking Points (Speaker 1 or 2):
> *"In addition to our botanical scanner and plant profile systems, PlantCare includes a dedicated, privacy-focused Authentication and Onboarding flow. Built in full compliance with Apple Human Interface Guidelines, it provides one-tap **Sign in with Apple** using Face ID alongside standard email credentials. Crucially, we also engineered a **'Continue as Guest'** mode, ensuring that users can immediately scan and diagnose plants without being forced through a registration barrier. Any plants saved during a guest session are safely stored in **SwiftData** and seamlessly link to the user's profile upon sign-up."*

### Prepared Evaluator Q&A:

**Q: "Why did you include a Guest Mode instead of requiring an account before scanning?"**
> **Answer**: *"According to Apple's Human Interface Guidelines for App Store review, apps should allow users to explore core functionality before requiring account registration. By offering a 'Continue as Guest' option, users can immediately experience the core value of PlantCare—scanning and identifying plants—while still having the option to sign in later to backup their garden."*

**Q: "How are authentication tokens and credentials secured?"**
> **Answer**: *"We never store sensitive tokens in `UserDefaults` or plaintext files. Authentication tokens are saved inside the hardware-encrypted iOS Keychain using `kSecClassGenericPassword` with `kSecAttrAccessibleAfterFirstUnlock`. Furthermore, Sign in with Apple utilizes Apple's native two-factor authentication and biometric validation via Face ID."*

**Q: "How does authentication interact with your SwiftData persistence model?"**
> **Answer**: *"Our SwiftData `@Model SavedPlant` architecture is designed with local-first persistence. Plants saved during guest mode reside securely in the local SQLite container. When a user creates an account or signs in, their existing records remain fully accessible on the device, ensuring zero data loss during onboarding."*
