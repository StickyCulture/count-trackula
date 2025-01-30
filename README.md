# Count Trackula

Count Trackula is an open-source iOS application that utilizes Apple's [Vision](https://developer.apple.com/documentation/vision) framework to count people entering and exiting a designated space. Designed for museums, galleries, and exhibits, the app provides a lightweight, privacy-conscious solution for visitor analytics.

## Features

- **Real-time visitor tracking:** Uses the device camera to count people entering and exiting a space.
- **Simultaneous counting:** Can detect multiple people passing simultaneously.
- **Privacy-focused:** No images or personally identifiable information are stored or transmitted.
- **Event-based reporting:** Logs Enter and Exit events for tracking visitor movement.
- **Firebase Firestore integration:** Uses [Boop](https://github.com/StickyCulture/boop) for data collection, but can be configured for other backends.
- **Optimized for fixed installations:** Ideal for use in doorways, hallways, and other controlled entry points.

## Use Case

Sticky Culture developed Count Trackula for internal use but we believe it can be valuable for other organizations looking to monitor visitor flow in a non-invasive way. This is particularly useful for:

- Small museums & galleries
- Temporary exhibitions
- Visitor experience research

## Getting Started

To use Count Trackula on your iOS device, follow these steps:

1. **Clone the Repository**
   ```sh
   git clone https://github.com/StickyCulture/count-trackula.git
   cd count-trackula
   ```

2. **Copy the Example.xcconfig** and update the values
   ```sh
   cp Configuration/Example.xcconfig Configuration/Debug.xcconfig
   cp Configuration/Example.xcconfig Configuration/Release.xcconfig
   ```

3. **Configure Firebase** if using Firestore for data collection, otherwise you can modify the [Analytics.swift](CountTrackula/Common/Analytics.swift) file to implement your own backend
   - Create a Firebase project
   - Download `GoogleService-Info.plist` and place it in the _Configuration/_ directory

4. **Build and Run**
   Open the project in Xcode and run the app on an iOS device, such as iPhone.

## Development Status

Please note that Count Trackula is currently a prototype in active development. While we use it internally, we do not assume highly accurate data at this stage. The app provides a general sense of visitation but we still have some kinks to figure out. Contributions are welcome as we continue to refine the application.