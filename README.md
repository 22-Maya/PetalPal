# PetalPal

PetalPal is a smart plant pot system paired with a companion iOS app that helps users manage watering schedules and plant care.

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift&logoColor=white">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-iOS%2016%2B-blue?logo=apple&logoColor=white">
  <img alt="Xcode" src="https://img.shields.io/badge/Xcode-15%2B-1575F9?logo=xcode&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green.svg">
</p>

---

## Features

- **Smart Pot Integration** — The app pairs with a connected smart pot to provide guided, hardware-informed plant care.
- **Beginner-Friendly Guidance** — Clear explanations and care tips designed for users new to plant ownership.
- **Watering Reminders and Tracking** — Simple scheduling and tracking to help busy users stay on top of plant maintenance.
- **Modular Architecture** — A clean, modular codebase structured to support future feature expansion.
- **Native Swift Experience** — Built entirely in Swift for a smooth, responsive iOS interface.

## Requirements

| Requirement | Version |
|---|---|
| iOS | 16.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |

## Installation

PetalPal is distributed as a standalone Xcode project rather than a library, so the primary way to get started is to clone and build it directly.

### Clone the repository

```bash
git clone https://github.com/22-Maya/PetalPal.git
cd PetalPal
open PetalPal.xcodeproj
```

Select a simulator or device in Xcode and run the project (`⌘R`).

## Usage

PetalPal is a self-contained app, so usage primarily consists of building and running it in Xcode. The general application entry point follows the standard SwiftUI app lifecycle:

```swift
import SwiftUI

@main
struct PetalPalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Once running, the app connects to a paired smart pot to surface plant status, watering reminders, and care guidance.

For a product overview, see the [PetalPal pitch deck](https://www.canva.com/design/DAGt6AVYIB4/-r9frlrhGgifQqxNvLB5-g/view).

## Contributing

This project is maintained as a personal and academic effort. Guidelines for external contributions are not currently defined.

## License

This project is licensed under the MIT License.

---
<p align="center">Designed and developed by Maya Itskovich</p>
