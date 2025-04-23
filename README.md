# IMTP Strength Measurement System

A comprehensive system for measuring strength using the Isometric Mid-thigh Pull (IMTP) exercise. This project combines hardware sensors, microcontroller firmware, and a Flutter mobile/web application to capture, process, store, and visualize strength data.

## Project Overview

This project focuses on developing a system for measuring strength using the Isometric Mid-thigh Pull (IMTP) exercise. A load cell sensor is used to capture the force exerted during the pull. This data is then processed by a microcontroller, transmitted wirelessly, stored securely in a database, and finally accessed and visualized by users through a web or mobile application.

## System Components

### Hardware Development

- **Load Cell Sensor (Vetec)**: Primary component for measuring the force applied during the IMTP.
- **Interface/Signal Amplifier (HX711)**: Interfaces with the load cell and amplifies its output signal, making it suitable for the microcontroller to read.
- **Microcontroller (ESP32)**: Central processing unit that receives the amplified signal, pre-processes the data, and handles wireless communication.
- **Serial Peripheral Interface (SPI)**: Communication protocol used for data transfer between the amplifier and the microcontroller.
- **Wireless Communication (WiFi/Bluetooth)**: The microcontroller transmits the processed data to the cloud or a local server.

### Firmware Development

- **Load Cell Data Acquisition**: Programming the microcontroller to read data from the amplifier via SPI.
- **Data Pre-processing**: Implementing algorithms to process the raw load cell data (filtering, calibration).
- **Wireless Communication Implementation**: Developing firmware to establish a wireless connection and transmit data using MQTT.

### Server (Backend) Development

- **Database Management**: Securely storing strength data received from the microcontroller.
- **API Development**: Creating interfaces that allow the web and mobile applications to access the data.
- **MQTT Broker**: Handling the incoming data stream from microcontrollers, especially if scaling to multiple users or devices.

### App (Web/Mobile) Development

- **User Interface (UI) Design**: Creating an intuitive and user-friendly interface.
- **Data Visualization**: Implementing features to visualize strength data over time (graphs, charts).
- **User Authentication and Authorization**: Secure user accounts and login systems.
- **Data Retrieval and Display**: Fetching data from backend APIs and displaying it to users.

## Project Structure

```
lib/
  ├── components/     # Reusable UI components/widgets (buttons, text fields, etc.)
  │   ├── auth_card.dart
  │   ├── back_button.dart
  │   ├── custom_text_field.dart
  │   ├── primary_button.dart
  │   └── profile_icon.dart
  │
  ├── models/         # Data models
  │   └── user.dart   # User model for authentication and user management
  │
  ├── screens/        # UI screens
  │   ├── auth/       # Authentication screens
  │   │   ├── login_screen.dart
  │   │   └── register_screen.dart
  │   ├── admin/      # Admin screens
  │   │   ├── admin_dashboard.dart
  │   │   ├── add_user_screen.dart
  │   │   └── user_list_screen.dart
  │   └── auth_screen.dart
  │
  ├── theme/          # App theming/Styling definitions (colors, text styles)
  │   ├── colors.dart
  │   └── text_styles.dart
  │
  └── main.dart       # App entry point, defines routes and theme
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Chrome browser for web testing
- ESP32 microcontroller (for hardware integration)
- Load cell sensor and amplifier

### Running the App

1. Navigate to the project directory
   ```
   cd idrott_app
   ```

2. Get dependencies
   ```
   flutter pub get
   ```

3. Run the app with a fixed port (for convenience)
   ```
   flutter run -d chrome --web-port=8080
   ```

4. Open your browser and go to:
   ```
   http://localhost:8080
   ```

## Development Roadmap

- [ ] Complete hardware integration with ESP32 and load cell
- [ ] Implement MQTT communication between hardware and server
- [ ] Develop data visualization features
- [ ] Implement user authentication and profiles
- [ ] Add data export functionality
- [ ] Create administrative features for managing multiple users
- [ ] Implement real-time data streaming

## Resources

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

For ESP32 development, refer to [ESP32 documentation](https://docs.espressif.com/projects/esp-idf/en/latest/).
