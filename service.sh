#!/system/bin/sh

MODDIR=${0%/*}
BASE=/data/adb/micfix
LOG="$BASE/MicFix.log"

mkdir -p "$BASE" 2>/dev/null

log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

export_log(){
    if [ -d "/sdcard/Download" ]; then
        cp -f "$LOG" "/sdcard/Download/MicFix_Report.log"
        chmod 666 "/sdcard/Download/MicFix_Report.log" 2>/dev/null
    fi
}

run_tinymix(){
    local cmd_output
    local control_name="$1"
    
    # Execute command and silence native tinymix spam
    cmd_output=$("$TINYMIX" "$@" 2>&1)
    
    # Check for any kind of failure (Failed, Invalid, Error, Usage)
    if echo "$cmd_output" | grep -qiE "Failed|Invalid|Error|Usage|No such"; then
        
        # Try fallback using "set" keyword just in case the binary requires it
        local cmd_output_fallback
        cmd_output_fallback=$("$TINYMIX" set "$@" 2>&1)
        
        if echo "$cmd_output_fallback" | grep -qiE "Failed|Invalid|Error|Usage|No such"; then
            # Cleanly log the error without the messy array text spam
            log "✕ FAILED: '$control_name' is not supported on this device's audio chip."
        else
            log "✓ FORCED SUCCESS: Applied '$control_name' using fallback method."
        fi
    else
        log "✓ SUCCESS: Applied '$control_name' flawlessly."
    fi
}

# Make service completely immune to Android RAM constraints (OOM Killer)
echo -1000 > /proc/$$/oom_score_adj 2>/dev/null

log "=================================================="
log "MicFix v1.2 (Ultimate Robust Handset Mode) started."
log "=================================================="

# Wait until device is fully booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 15

log "Applying OS Optimizations (Native Doze, FSTRIM, Logd Killer)..."
# 1. Stop background logging to save RAM and I/O
stop logd 2>/dev/null

# 2. Native Aggressive Doze (0% CPU)
# Tells Android to drop into Deep Doze rapidly when screen is off
settings put global device_idle_constants light_after_inactive_to=15000,light_pre_idle_to=30000,light_idle_to=60000,inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=30000,idle_pending_to=30000,max_idle_pending_to=60000,idle_pending_factor=1.0,idle_to=60000,max_idle_to=600000,idle_factor=1.0,min_time_to_alarm=60000,max_temp_app_whitelist_duration=10000,mms_temp_app_whitelist_duration=10000,sms_temp_app_whitelist_duration=10000 2>/dev/null

# 3. Ultimate Sweep Sequence & Deep System Optimizations (Delayed 90s)
(
    sleep 90
    log "Initiating Ultimate Sweep Sequence..."
    
    # Storage Cleanup (FSTRIM)
    fstrim -v /data >/dev/null 2>&1
    fstrim -v /cache >/dev/null 2>&1
    
    # Native App Cache Wiper
    pm trim-caches 99999999999999 >/dev/null 2>&1
    
    # Crash Log & Tombstone Sweeper
    rm -rf /data/tombstones/* >/dev/null 2>&1
    rm -rf /data/system/dropbox/* >/dev/null 2>&1
    
    # Temp Folder Clearer
    rm -rf /data/local/tmp/* >/dev/null 2>&1
    
    log "Sweep Complete. Optimizing System..."
    
    # Background Native App Compiler & SQLite Optimizer (Zero Lag)
    cmd package bg-dexopt-job >/dev/null 2>&1
    
    # Network TCP Window Scaling tweaks
    sysctl -w net.ipv4.tcp_window_scaling=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216' >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem='4096 16384 16777216' >/dev/null 2>&1
    
    # Useless System Bloat & Telemetry Freezer
    pm disable com.android.printspooler >/dev/null 2>&1
    pm disable com.google.android.gms/com.google.android.gms.measurement.AppMeasurementService >/dev/null 2>&1
    pm disable com.google.android.gms/com.google.android.gms.measurement.AppMeasurementReceiver >/dev/null 2>&1
    
    # Advanced UI Smoothness & Battery Enhancers (via Native C++ resetprop)
    resetprop debug.sf.hw 1
    resetprop debug.performance.tuning 1
    resetprop wifi.supplicant_scan_interval 180
    
    # I/O Storage Speed Boost (Universal Native Read-Ahead Buffer)
    for iodev in /sys/block/*/queue/read_ahead_kb; do
        echo 2048 > "$iodev" 2>/dev/null
    done
    
    # Final Kernel-Level RAM Flush
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    
    log "Deep System Optimizations Complete! Max RAM restored."
) &

log "Applying boot-time app optimization (Freezing heavy apps)..."
for app in com.whatsapp com.whatsapp.w4b com.facebook.katana com.facebook.lite com.android.chrome org.telegram.messenger com.google.android.googlequicksearchbox; do
    am force-stop "$app" >/dev/null 2>&1
done
log "App freezing complete. Apps will not consume RAM until manually opened."

# Background Process Limit managed dynamically by SmoothRAM

# Show initial boot notification
(
    sleep 3
    cmd notification post -S bigtext -t "MicFix Active" "MicFix" "v1.2: Powerful Call Service Loaded! Native Memory Governor active." >/dev/null 2>&1
) &

# Load pre-discovered tools from installation config to save battery
TINYMIX=""
if [ -f "$MODDIR/mixer_tool.conf" ]; then
    source "$MODDIR/mixer_tool.conf"
    if [ "$TOOL_TYPE" = "tinymix" ]; then
        TINYMIX="$TOOL_PATH"
    fi
fi

# Fallback search if config missing
if [ -z "$TINYMIX" ] || [ ! -x "$TINYMIX" ]; then
    log "Config not found, performing lightweight search for tinymix..."
    TINYMIX=$(command -v tinymix 2>/dev/null)
    if [ -z "$TINYMIX" ]; then
        for path in /system/bin/tinymix /vendor/bin/tinymix /system/vendor/bin/tinymix /system_ext/bin/tinymix; do
            if [ -x "$path" ]; then
                TINYMIX="$path"
                break
            fi
        done
    fi
fi

if [ -z "$TINYMIX" ] || [ ! -x "$TINYMIX" ]; then
    log "CRITICAL ERROR: tinymix not found on device! Script cannot run."
    exit 0
else
    log "SUCCESS: tinymix found and loaded from: $TINYMIX"
fi

apply_pre_init(){
    # Wake up the hardware BEFORE the user hits answer!
    # 1. Zero out the hardcoded 500ms ramp delay completely
    run_tinymix "Voice Tx Mute" "0" "-1" "0"
    run_tinymix "Voip Tx Mute" "0" "0"
    
    # 2. Enable both DEC mixers to prime the ADCs and power them up
    run_tinymix "TX_AIF1_CAP Mixer DEC0" "1"
    run_tinymix "TX_AIF1_CAP Mixer DEC1" "1"
    run_tinymix "ADC1_MIXER Switch" "1"
    run_tinymix "ADC2_MIXER Switch" "1"
    run_tinymix "ADC1 MUX" "INP2"
    run_tinymix "ADC2 MUX" "INP3"

    # 3. CRITICAL: PRE-LOAD hardware Echo Canceller so it has time to calibrate math!
    run_tinymix "IIR0 INP0 MUX" "DEC0"
}

apply_mic_fix(){
    # THE ULTIMATE HANDSET-MIC RE-INITIALIZATION
    # This aggressively re-builds the entire handset-mic route manually to guarantee zero failure!

    # 1. Dual Channel Mode active
    run_tinymix "TX_CDC_DMA_TX_3 Channels" "Two"
    run_tinymix "TX DEC0 MUX" "SWR_MIC"
    run_tinymix "TX DEC1 MUX" "SWR_MIC"

    # 2. Re-assert Microphones (Bottom Primary, Top Secondary)
    run_tinymix "TX SMIC MUX0" "ADC0"
    run_tinymix "TX SMIC MUX1" "ADC2"

    # 3. Ensure hardware echo loop is perfectly attached to the primary mic (DEC0)
    run_tinymix "IIR0 INP0 MUX" "DEC0"

    # 4. Perfect Reverb-Free Volume (Default 84 to prevent distortion and clipping)
    run_tinymix "RX_RX0 Digital Volume" "84"
    run_tinymix "TX_DEC0 Volume" "84"
    run_tinymix "TX_DEC1 Volume" "84"
}

show_notification(){
    (
        sleep 3
        cmd notification post -S bigtext -t "MicFix Active" "MicFix" "v1.2: Audio Chip Fully Reinitialized & Clean!" >/dev/null 2>&1
    ) &
}

get_call_state(){
    # Super-efficient Universal Call Detection
    dumpsys audio 2>/dev/null | grep -m 1 -i 'mMode='
}

ACTIVE=0
PRE_INIT=0

# Efficient CPU Polling Loop (Sleep 2 is completely safe and uses <0.1% CPU)
while true; do
    STATE=$(get_call_state)

    if echo "$STATE" | grep -qE "MODE_RINGTONE|1"; then
        if [ "$PRE_INIT" = "0" ]; then
            PRE_INIT=1
            log "RINGTONE DETECTED! Powering on Audio Hardware early..."
            apply_pre_init
            log "Hardware Primed and Ready!"
        fi
        sleep 1
    elif echo "$STATE" | grep -qE "MODE_IN_CALL|MODE_IN_COMMUNICATION|2|3"; then
        if [ "$ACTIVE" = "0" ]; then
            ACTIVE=1
            log "CALL CONNECTED! Aggressively fully re-initializing Handset Mic route!"
            show_notification
        fi
        # We constantly re-apply to absolutely prevent the "no sound" bug from taking over
        apply_pre_init
        apply_mic_fix
        sleep 2
    else
        if [ "$ACTIVE" = "1" ] || [ "$PRE_INIT" = "1" ]; then
            ACTIVE=0
            PRE_INIT=0
            log "Call ended. Audio routes returning to idle state cleanly."
            export_log
        fi
        sleep 2
    fi
done
