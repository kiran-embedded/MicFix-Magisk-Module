<div align="center">
  <h1>🎙️ MicFix Ultimate Robust (ZeroCPU Edition)</h1>
  <p><strong>Advanced Magisk & KernelSU Audio Hardware Re-Initialization Module</strong></p>
  <img src="https://img.shields.io/badge/Version-v45.0-blue?style=for-the-badge&logo=android" alt="Version">
  <img src="https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU-success?style=for-the-badge" alt="Root">
</div>

---

## ⚡ Overview
**MicFix Ultimate** is an advanced, hardware-level audio routing module designed to completely eradicate the infamous "no sound" race conditions and initialization delays on Android devices. This is the **most powerful and robust** iteration, built to aggressively and perfectly reconstruct the primary Handset Mic and Earpiece/Speaker paths the absolute millisecond your device receives a call.

Unlike conventional fixes that poll your device state using aggressive CPU loops, v45 introduces a **true zero-CPU event listener** using native logcat filters. It blocks efficiently while idle and springs to life instantly when `MODE_RINGTONE` or `MODE_IN_CALL` intents are fired.

---

## 🚀 Key Features

### 🎧 1. Zero-CPU Event-Driven Execution
- **Instant Pre-Priming:** The script waits using a `logcat -e` blocking listener, meaning it consumes **0% CPU** while idle.
- **Pre-Ring Initialization:** The absolute millisecond a call comes in, the entire ADC/DEC routing is built *before* you even tap answer, resulting in **zero hardware delay**.

### 🛠️ 2. Deep Hardware Initialization (Advanced)
- **Aggressive ADC Resets:** Forces ADC mixer states to `0` to flush out any stuck DSP paths before powering them on cleanly.
- **High-Pass Filter (HPF) Injection:** Enables hardware-level HPFs on the DEC streams to completely eliminate the low-frequency "pop" and "click" noises during mic initialization.
- **Perfected Isolation:** Forcibly separates `RX_MACRO` (Speaker) and `TX_DEC` (Mic) streams to eliminate cross-talk and hardware echo. 
- **Anti-Glitch Volumes:** TX/RX Volumes are set to `0` prior to reaching the `84` default output level to prevent transient distortion.

### 🧠 3. Built-In Boot RAM Optimizer
MicFix natively targets and isolates massive background RAM hogs upon boot. Unwanted tracker services and heavy background apps are restricted to execute **only when actively launched by the user**. This saves battery and keeps your launcher smooth.
*Apps Managed: WhatsApp, Facebook, Instagram, Google App, Snapchat, TikTok, Twitter, Amazon, Netflix, Spotify, LinkedIn, Twitch, Telegram, and more.*

### 🎮 4. GPU Launcher Compositing
Automatically injects hidden `SurfaceFlinger` directives and `system.prop` flags to disable inefficient hardware overlays, forcing **GPU Composition** for your launcher and UI elements for a buttery smooth experience.

### 💻 5. Native CLI Status Tool
Includes an executable CLI to monitor the module's live health.
* Open Termux (or any terminal) and run: `su -c micfix`
* View real-time audio modes, active background app restrictions, and the module's latest log output.

---

## 📦 Installation

1. Download the latest `MicFix_v45.0_Ultimate_Robust_ZeroCPU.zip` from the [Releases](#).
2. Open **Magisk Manager** or **KernelSU**.
3. Go to the Modules section -> **Install from Storage**.
4. Select the downloaded ZIP file.
5. Reboot your device.

---

## ⚙️ Terminal Interface

Check if the module is active by running the built-in command:

```bash
su
micfix
```

**Output Example:**
```text
=====================================
       MicFix v45 Status Tool        
=====================================

[*] Module Status:
  -> Service is running. Recent logs:
-------------------------------------
[2026-09-19 10:30:00] MicFix v45 (Ultimate Robust ZeroCPU Mode) started.
[2026-09-19 10:30:15] Waiting for call events via zero-CPU logcat listener...
-------------------------------------

[*] Boot RAM Optimization Status:
  -> com.whatsapp : RUN_IN_BACKGROUND: ignore
  -> com.facebook.katana : RUN_IN_BACKGROUND: ignore

[*] Current Audio Mode:
  -> Mode: MODE_NORMAL
```

---
*Created by [kirenembedded](https://github.com/kiran-embedded)*
