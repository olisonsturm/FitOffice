# FitOffice@DHBW

*![FitOffice@DHBW](https://raw.githubusercontent.com/olisonsturm/FitOffice/main/assets/logo.png)*

The original FitOffice@DHBW App. Made with ❤️ at DHBW Ravensburg. Brought to life by health management students. Developed by business information systems students.

![last-commit](https://img.shields.io/github/last-commit/olisonsturm/FitOffice?style=flat&logo=git&logoColor=white&color=0080ff)
![repo-top-language](https://img.shields.io/github/languages/top/olisonsturm/FitOffice?style=flat&color=0080ff)
![repo-language-count](https://img.shields.io/github/languages/count/olisonsturm/FitOffice?style=flat&color=0080ff)

*Built with the tools and technologies:*

![JSON](https://img.shields.io/badge/JSON-000000.svg?style=flat&logo=JSON&logoColor=white)
![Markdown](https://img.shields.io/badge/Markdown-000000.svg?style=flat&logo=Markdown&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-F05138.svg?style=flat&logo=Swift&logoColor=white)
![Gradle](https://img.shields.io/badge/Gradle-02303A.svg?style=flat&logo=Gradle&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2.svg?style=flat&logo=Dart&logoColor=white)
![C++](https://img.shields.io/badge/C++-00599C.svg?style=flat&logo=C%2B%2B&logoColor=white)

![XML](https://img.shields.io/badge/XML-005FAD.svg?style=flat&logo=XML&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B.svg?style=flat&logo=Flutter&logoColor=white)
![CMake](https://img.shields.io/badge/CMake-064F8C.svg?style=flat&logo=CMake&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-7F52FF.svg?style=flat&logo=Kotlin&logoColor=white)
![Podman](https://img.shields.io/badge/Podman-892CA0.svg?style=flat&logo=Podman&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E.svg?style=flat&logo=YAML&logoColor=white)

---

## Table of Contents
- [toc](#table-of-contents)

---

## Overview

**FitOffice** is an all-in-one developer toolkit tailored for Flutter projects, streamlining configuration, branding, and backend integration across multiple platforms. It simplifies dynamic feature toggling, backend orchestration, and asset management, enabling developers to build scalable, secure, and visually consistent applications.

**Why FitOffice?**

This project enhances your development workflow with:

- 🎨 **🖼️ Cross-Platform Icon Generation:** Automates app launcher icon creation for Android, iOS, Web, Windows, and macOS, ensuring consistent branding.
- 🔧 **🔄 Remote Config Management:** Supports dynamic feature toggling and parameter updates without redeploys.
- 🔐 **🔥 Firebase Integration:** Orchestrates backend services like Firestore, Storage, and Functions with security rules for data protection.
- 📝 **🛠️ Code Quality Enforcement:** Implements static analysis rules to maintain high standards and prevent bugs.
- ⚙️ **🌐 Modular Architecture:** Facilitates localization, theming, user management, and scalable development.

---

## Getting Started

### Prerequisites

This project requires the following dependencies:

- **Programming Language:** Dart
- **Package Manager:** Pub, CMake, Gradle
- **Container Runtime:** Podman

### Installation

Build FitOffice from the source and install dependencies:

1. **Clone the repository:**

```sh
❯ git clone https://github.com/olisonsturm/FitOffice
```

## Docs
1. **Splash Screen anzeigen, bis Daten geladen sind, und nach dem Laden `FlutterNativeSplash.remove()` aufrufen:**  
   In diesem Fall wird es in der Methode `onReady()` der `AuthenticationRepository()` entfernt.
2. **Vor dem Start der App:**  
   Firebase initialisieren und nach der Initialisierung das `AuthenticationRepository` aufrufen, um zu überprüfen, welcher Bildschirm angezeigt werden soll.
3. **Lösung für Probleme mit `Get.lazyPut` und `Get.Put()`:**  
   Alle Controller werden in `InitialBinding` definiert.
4. **Bildschirmübergänge:**  
   Verwenden Sie diese zwei Eigenschaften in `GetMaterialApp`:  
      - `defaultTransition: Transition.leftToRightWithFade,`  
      - `transitionDuration: const Duration(milliseconds: 500),`
5. **HOME-BILDSCHIRM:**  
   - Zeigen Sie einen Fortschrittsindikator oder Splash Screen an, bis alle Daten aus der Cloud geladen sind.  
   - Lassen Sie das `AuthenticationRepository` entscheiden, welcher Bildschirm als erstes angezeigt wird.
6. **Authentication Repository:**  
   - Wird für die Benutzer-Authentifizierung und Bildschirmweiterleitungen verwendet.  
   - Wird beim Start der App aus `main.dart` aufgerufen.  
   - Die Methode `onReady()` setzt den `firebaseUser`-Zustand, entfernt den Splash Screen und leitet zum entsprechenden Bildschirm weiter.  
   - Nutzung in anderen Klassen: `[final auth = AuthenticationRepository.instance;]`
