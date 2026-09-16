# PlantCare: 10-Minute Live Presentation & Demonstration Guide

**Course Evaluation Rubric Target**: 20/20 Marks (Presentation & Demonstration)  
**Team Members**:
- **Speaker 1**: Mi Hnin Au Shwe Yee (ID: `6632723`) — *Project Overview & Problem Domain*
- **Speaker 2**: Kaung Wai Yan (ID: `6632722`) — *Live UI Demonstration & Persistence Proof*
- **Speaker 3**: Ye Nay Thway (ID: `6736539`) — *Technical Architecture, API Integration & Security*

---

## Presentation Timeline (Total: 10:00 Minutes)

```
0:00 ─── 1:30  | Part 1: Introduction, Problem & Architecture Overview (Mi Hnin Au Shwe Yee)
1:30 ─── 4:30  | Part 2: Live App Walkthrough across 5 Screens (Kaung Wai Yan)
4:30 ─── 6:30  | Part 3: The "Kill-and-Relaunch" Persistence Proof (Kaung Wai Yan & Ye Nay Thway)
6:30 ─── 8:30  | Part 4: Technical Deep-Dive: Dual APIs, SwiftData & Security (Ye Nay Thway)
8:30 ─── 10:00 | Part 5: Conclusion & Technical Q&A (All Team Members)
```

---

## Part 1: Introduction & Problem Overview (0:00 – 1:30)
**Speaker**: Mi Hnin Au Shwe Yee

> **Script**:
> "Good morning/afternoon, Professor and classmates. Today, our team—Kaung Wai Yan, Ye Nay Thway, and myself, Mi Hnin Au Shwe Yee—is proud to present **PlantCare: Scan, Identify, and Grow**.
>
> Urban gardeners and houseplant enthusiasts often encounter two frustrating challenges:
> 1. Not knowing what species a plant is or what its specific sunlight and watering needs are.
> 2. Failing to identify early, visible signs of distress like leaf spot or underwatering before it is too late.
>
> To solve this, we engineered a multi-screen native iOS application in **SwiftUI** with a modern **Liquid Glass / Glassmorphism** design system. Our app integrates live public botanical identification APIs via `URLSession` and `async/await`, diagnoses conditions, and retains all scanned photographs and care records locally on device using **SwiftData**.
>
> Let's turn over to Kaung Wai Yan to walk through the live application."

---

## Part 2: Live Application Demonstration (1:30 – 4:30)
**Speaker**: Kaung Wai Yan  
**Action**: Projecting iPhone Simulator or physical iPhone screen onto the projector.

### Screen 1: Home & Botanical Exploration View (1:30 – 2:15)
- **Show**: Floating frosted glass header ("Hello, Plant Parent! 🌿") and dynamic ambient botanical glow mesh.
- **Explain**:
  - Point out the frosted search bar filtering flora in real time.
  - Showcase the curated **Featured Botanical Species** carousel (Monstera, Fiddle Leaf Fig, Snake Plant, Golden Pothos) and the quick care tips cards.
  - Tap the prominent **"Scan & Diagnose Plant"** liquid glass action card to transition directly to Screen 2.

### Screen 2: Scan & Viewfinder Screen (2:15 – 3:00)
- **Show**: Translucent camera viewfinder with the animated corner reticles (`[ ]`).
- **Explain**:
  - Show the **Gallery** button powered by `PhotosPicker` and the **Capture** action.
  - Select or capture a plant photo (e.g., Monstera).
  - Tap **"Identify Plant & Health"**.
  - Highlight the sleek animated loading state: *"Analyzing Botanical DNA..."* while modern Swift concurrency dispatches the multipart request.

### Screen 3: Identification Result Screen (3:00 – 3:45)
- **Show**: Instant match presentation.
- **Explain**:
  - Photo thumbnail card rendered in liquid glass with subtle drop shadow.
  - Primary species match: **Monstera Deliciosa** (*Monstera deliciosa*, Araceae family).
  - Glowing confidence progress meter displaying **96% match**.
  - Alternative candidate species pills (*Monstera adansonii*, *Epipremnum pinnatum*) allowing users to switch candidates with single tap.
  - Initial non-diagnostic health diagnosis banner.
  - Tap **"View Full Care Profile & Health"** to open Screen 4.

### Screen 4: Plant Profile & Botanical Care (3:45 – 4:30)
- **Show**: High-resolution hero image header with frosted bottom fade.
- **Explain**:
  - 4-quadrant liquid glass care metric widgets: **Watering** (*Every 1-2 weeks*), **Sunlight** (*Bright indirect*), **Growth Cycle** (*Perennial*), and Care Level.
  - Health diagnosis card with soft amber frosted glass explaining condition and preventive advice.
  - Tap the floating liquid glass **"Save to My Garden"** button: observe tactile haptic vibration and the smooth spring animation confirming *"Saved in My Garden 🌿"*.

---

## Part 3: Proving Data Persistence — The Hard Kill & Relaunch Test (4:30 – 6:30)
**Speaker**: Kaung Wai Yan & Ye Nay Thway  
**Rubric Anchor**: 20 Marks for reliable local storage persisting between complete app closures.

> **Demonstration Steps**:
> 1. Tap the bottom tab bar to open **Screen 5: My Garden**.
> 2. Show the newly saved Monstera card with its local photo thumbnail, scientific name, date saved, and health condition badge.
> 3. **The Proof Step (Call this out explicitly to the evaluator)**:
>    - *"Professor, to demonstrate strict compliance with the rubric's local data persistence requirement, we will now completely terminate the app process."*
> 4. Swipe up from the bottom bezel to reveal the iOS multitasking App Switcher.
> 5. **Swipe up firmly on PlantCare to hard-kill the process**.
> 6. Return to the iPhone Home Screen (app is completely terminated from RAM).
> 7. Tap the PlantCare app icon to launch from a cold start.
> 8. Tap **Garden** in the tab bar.
> 9. **Verify**: The saved plant record, all botanical care metrics, and the captured photo rendered from local disk sandbox are 100% intact!

---

## Part 4: Technical Architecture, API Integration & Security (6:30 – 8:30)
**Speaker**: Ye Nay Thway

### 1. Dual External REST API Integration
- **Pl@ntNet API**:
  - Uses `URLSession` and custom multipart/form-data boundary creation to upload image JPEG bytes.
  - Decoded via Swift `Codable` (`PlantNetResponse`, `PlantNetMatch`, `PlantNetSpecies`).
- **Perenual Care API**:
  - Queried asynchronously using the identified scientific name to retrieve watering frequencies, sunlight exposures, and life cycles.
- **Fail-Safe Offline Mode**:
  - Built-in `MockPlantService` ensures zero presentation interruptions regardless of venue Wi-Fi stability.

### 2. Local Storage Architecture
- **SwiftData**: Stores structured metadata in a `@Model SavedPlant` entity with strict unique UUID constraints.
- **Sandbox File System**: Captured photos are saved atomically as JPEGs inside the app's secure `<Sandbox>/Documents/PlantImages/` directory, avoiding database bloat and maintaining maximum I/O performance.

### 3. Security & Apple Privacy Compliance
- API keys isolated in `PlantCareSecrets.xcconfig` outside Git version control.
- Full compliance with Apple privacy string requirements (`NSCameraUsageDescription` & `NSPhotoLibraryUsageDescription`).

---

## Part 5: Conclusion & Technical Q&A (8:30 – 10:00)
**Speaker**: All Team Members

### Prepared Answers for Professor's Questions:

**Q1: "Why did you use SwiftData instead of Core Data or UserDefaults?"**
> *Answer*: "SwiftData is Apple's latest standard starting with iOS 17. It integrates seamlessly with SwiftUI's reactive observation system using pure Swift macros (`@Model`, `@Query`), eliminates boilerplate `NSManagedObject` subclasses, and ensures type-safe persistence with automated migration support."

**Q2: "How do you handle images without overwhelming SQLite?"**
> *Answer*: "Storing large binary blobs directly in a database degrades query performance. Following Apple best practices, our `ImageStorageService` saves JPEG images directly into the App Sandbox Documents directory under unique UUID filenames, storing only the lightweight relative filename reference inside the SwiftData model."

**Q3: "How does the app behave if the user is offline or the API rate limit is exceeded?"**
> *Answer*: "Our networking layer implements a typed `NetworkError` enum capturing status codes (404, 429 rate limit, timeouts). If network access is unavailable, the app notifies the user with contextual feedback and seamlessly utilizes our cached botanical database."
