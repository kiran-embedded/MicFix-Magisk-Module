# MicFix Speaker-Mic TX (v1.2) - Ultimate Edition

Created by **kiran-embedded**

A KernelSU/Magisk module designed to fix audio routing issues during calls (preventing the "no sound" bug) and universally optimize your device's speed, battery, and storage natively.

## Features

- **Robust Audio Reset**: Re-initializes the device's audio hardware routes right before and during calls to ensure the handset microphones are always perfectly connected.
- **On-time Detection**: Extremely efficient background service detects the `MODE_RINGTONE` state to wake up audio hardware before you even press answer.
- **Boot Optimization (App Freezer)**: Force-stops resource-heavy apps automatically after the device boots.
- **Ultimate Sweep Sequence**: Exactly 90 seconds after boot, the module natively trims caches, empties massive crash logs, and clears temp folders with 0 lag.
- **Elite System Smoothness & I/O Tweaks**: Natively forces UI GPU acceleration (`debug.sf.hw=1`), expands internal storage read-ahead buffers to `2048kb` for instant load speeds, and drops kernel caches to maximize RAM.
- **GMS Telemetry Blocker**: Disables Google Play Services' hidden analytics trackers to permanently boost standby battery life.
- **Diagnostic Logging**: Automatically saves a detailed log file to your internal storage (`/sdcard/Download/MicFix_Report.log`).



## Installation
1. Install via Magisk or KernelSU.
2. Reboot the device.
3. The boot optimization will trigger shortly after the screen turns on.

## Support
Report any bugs or feature requests on my GitHub: [kiran-embedded/MicFix-Magisk-Module](https://github.com/kiran-embedded/MicFix-Magisk-Module)
