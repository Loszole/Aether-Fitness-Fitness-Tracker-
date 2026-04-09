# Privacy Policy — Aether Fitness

**Effective Date:** April 9, 2026  
**App Name:** Aether Fitness  
**Developer:** Loszole  
**Contact:** https://github.com/Loszole

---

## 1. Overview

Aether Fitness is an offline-first Android fitness tracker. This policy explains what data the app collects, how it is used, and your rights as a user.

**Summary:** All data you create in Aether Fitness stays on your device. Nothing is transmitted to external servers, third parties, or the developer.

---

## 2. Data We Collect

Aether Fitness collects and stores the following data **locally on your device only**:

| Data Type | Purpose | Storage |
|---|---|---|
| Step count | Track daily steps via phone pedometer | Local SQLite database |
| Workout logs | Manual entries: exercise type, duration, calories, notes | Local SQLite database |
| Water intake | Daily hydration tracking | Local SQLite database |
| Fitness plans | User-created plans with targets and rest days | Local SQLite database |
| App preferences | UI settings and user preferences | Local SharedPreferences |

---

## 3. Data We Do NOT Collect

- No personal identifiable information (PII) such as name, email, or age
- No location data
- No camera or microphone data
- No contact list access
- No analytics or crash reporting data sent to any server
- No advertising identifiers

---

## 4. Android Permissions

Aether Fitness requests the following Android permissions:

| Permission | Reason |
|---|---|
| `ACTIVITY_RECOGNITION` | Required to read step count from the device's built-in pedometer sensor |
| `FOREGROUND_SERVICE` | Allows step tracking to continue while the app is in the background |

These permissions are used **solely** for step tracking functionality. No data obtained from these permissions is shared externally.

---

## 5. Data Storage and Security

- All app data is stored in an SQLite database on your local device (`/data/data/com.aetherfitness.app/`).
- Preferences are stored in Android SharedPreferences.
- No data is encrypted at rest (the app holds non-sensitive fitness metrics only).
- Data is automatically deleted if you uninstall the app.

---

## 6. Data Sharing

Aether Fitness does **not** share any user data with:

- Third-party services
- Analytics providers
- Advertising networks
- The developer or any other individual

---

## 7. Third-Party Libraries

The app uses the following open-source packages. None of them collect or transmit personal data:

| Package | Purpose |
|---|---|
| `sqflite` | Local SQLite database |
| `pedometer` | Access device step counter sensor |
| `permission_handler` | Request Android runtime permissions |
| `shared_preferences` | Local key-value preferences storage |
| `fl_chart` | Render charts inside the app |

---

## 8. Children's Privacy

Aether Fitness does not knowingly collect personal data from anyone, including children under the age of 13. Because no personal data is collected, the app is safe for use by all ages.

---

## 9. Data Deletion

Because all data is stored locally on your device, you can delete it at any time by:

- Clearing app data via **Settings > Apps > Aether Fitness > Clear Data**
- Uninstalling the app

---

## 10. Changes to This Policy

If this policy changes in a future version of the app, the updated policy will be posted in this repository with a new **Effective Date** at the top.

---

## 11. Contact

If you have questions about this privacy policy, open an issue on the GitHub repository:

https://github.com/Loszole/Aether-Fitness-Fitness-Tracker-
