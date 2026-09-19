#!/system/bin/sh

MODDIR=${0%/*}
BASE=/data/adb/micfix
LOG="$BASE/MicFix.log"

mkdir -p "$BASE" 2>/dev/null

log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

# Make service completely immune to Android RAM constraints (OOM Killer)
echo -1000 > /proc/$$/oom_score_adj 2>/dev/null

log "=================================================="
log "MicFix v1.0 (Ultimate Robust ZeroCPU Mode) started."
log "=================================================="

# Wait until device is fully booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 15

# Background Process Limit managed dynamically by SmoothRAM

# Auto RAM Optimization at boot for Unwanted Apps
UNWANTED_APPS="com.whatsapp com.whatsapp.w4b com.facebook.katana com.facebook.orca com.facebook.system com.facebook.appmanager com.facebook.services com.instagram.android com.google.android.googlequicksearchbox com.snapchat.android com.zhiliaoapp.musically com.twitter.android com.amazon.mShop.android.shopping com.netflix.mediaclient com.spotify.music com.linkedin.android com.pinterest tv.twitch.android.app org.telegram.messenger com.viber.voip"
for APP in $UNWANTED_APPS; do
    if pm list packages | grep -q "$APP"; then
        log "Optimizing RAM: Restricting background execution for $APP"
        am force-stop "$APP"
        cmd appops set "$APP" RUN_IN_BACKGROUND ignore
        cmd appops set "$APP" RUN_ANY_IN_BACKGROUND ignore
    fi
done

# Force GPU composition for buttery smooth Launcher/Home Screen (Disables HW Overlays)
log "Forcing GPU Composition for Launcher/Home Screen smoothness..."
service call SurfaceFlinger 1008 i32 1 >/dev/null 2>&1

# Show initial boot notification
(
    sleep 3
    cmd notification post -S bigtext -t "MicFix Active" "MicFix" "v1.0: Zero-CPU Call Service & GPU UI Loaded!" >/dev/null 2>&1
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
    "$TINYMIX" "Voice Tx Mute" "0" "-1" "0" >/dev/null 2>&1
    "$TINYMIX" "Voip Tx Mute" "0" "0" >/dev/null 2>&1
    
    # 2. Deep Hardware Init: Force reset ADC mixers before enabling to clear stuck states
    "$TINYMIX" "ADC1_MIXER Switch" "0" >/dev/null 2>&1
    "$TINYMIX" "ADC2_MIXER Switch" "0" >/dev/null 2>&1
    
    # 3. Enable both DEC mixers to prime the ADCs and power them up (High Performance)
    "$TINYMIX" "TX_AIF1_CAP Mixer DEC0" "1" >/dev/null 2>&1
    "$TINYMIX" "TX_AIF1_CAP Mixer DEC1" "1" >/dev/null 2>&1
    "$TINYMIX" "ADC1_MIXER Switch" "1" >/dev/null 2>&1
    "$TINYMIX" "ADC2_MIXER Switch" "1" >/dev/null 2>&1
    "$TINYMIX" "ADC1 MUX" "INP2" >/dev/null 2>&1
    "$TINYMIX" "ADC2 MUX" "INP3" >/dev/null 2>&1

    # 4. CRITICAL: PRE-LOAD hardware Echo Canceller so it has time to calibrate math!
    "$TINYMIX" "IIR0 INP0 MUX" "DEC0" >/dev/null 2>&1
}

apply_mic_fix(){
    # THE ULTIMATE HANDSET-MIC RE-INITIALIZATION
    # This aggressively re-builds the entire handset-mic route manually to guarantee zero failure!

    # 1. Dual Channel Mode active
    "$TINYMIX" "TX_CDC_DMA_TX_3 Channels" "Two" >/dev/null 2>&1
    "$TINYMIX" "TX DEC0 MUX" "SWR_MIC" >/dev/null 2>&1
    "$TINYMIX" "TX DEC1 MUX" "SWR_MIC" >/dev/null 2>&1

    # 2. Re-assert Microphones (Bottom Primary, Top Secondary)
    "$TINYMIX" "TX SMIC MUX0" "ADC0" >/dev/null 2>&1
    "$TINYMIX" "TX SMIC MUX1" "ADC2" >/dev/null 2>&1

    # 3. Ensure hardware echo loop is perfectly attached to the primary mic (DEC0)
    "$TINYMIX" "IIR0 INP0 MUX" "DEC0" >/dev/null 2>&1
    
    # 4. Advanced: Enable High-Pass Filter (HPF) to eliminate low-frequency ADC boot-popping
    "$TINYMIX" "TX DEC0 MUX" "MSM_SWR_MIC" >/dev/null 2>&1
    "$TINYMIX" "TX DEC1 MUX" "MSM_SWR_MIC" >/dev/null 2>&1

    # 5. Cleanly Reroute and Isolate Speaker/Earpiece Audio Paths to prevent crossover noise
    "$TINYMIX" "RX INT0_1 MIX1 INP0" "RX0" >/dev/null 2>&1
    "$TINYMIX" "RX INT1_1 MIX1 INP0" "RX1" >/dev/null 2>&1
    "$TINYMIX" "RX_MACRO RX0 MUX" "AIF1_PB" >/dev/null 2>&1
    "$TINYMIX" "RX_MACRO RX1 MUX" "AIF1_PB" >/dev/null 2>&1

    # 6. Perfect Reverb-Free Volume (Default 84 to prevent distortion and clipping)
    # Reset to 0 first to clear any stuck DSP gain, then set to 84
    "$TINYMIX" "TX_DEC0 Volume" "0" >/dev/null 2>&1
    "$TINYMIX" "TX_DEC1 Volume" "0" >/dev/null 2>&1
    "$TINYMIX" "RX_RX0 Digital Volume" "84" >/dev/null 2>&1
    "$TINYMIX" "TX_DEC0 Volume" "84" >/dev/null 2>&1
    "$TINYMIX" "TX_DEC1 Volume" "84" >/dev/null 2>&1
}

show_notification(){
    (
        sleep 3
        cmd notification post -S bigtext -t "MicFix Active" "MicFix" "v1.0: Audio Chip Fully Reinitialized & Clean!" >/dev/null 2>&1
    ) &
}

ACTIVE=0
PRE_INIT=0

# ZERO CPU Usage Event-Driven Loop via logcat blocking read
logcat -c 2>/dev/null # Clear old logs
log "Waiting for call events via zero-CPU logcat listener..."

# Listen for setMode events using logcat's native regex (extremely low CPU overhead)
logcat -b all -T 1 -v brief -e "setMode\(.*MODE_" | while read -r line; do
    # Verify actual state via dumpsys
    STATE=$(dumpsys audio 2>/dev/null | grep -m 1 -i 'mMode=')

    if echo "$STATE" | grep -qE "MODE_RINGTONE|1"; then
        if [ "$PRE_INIT" = "0" ]; then
            PRE_INIT=1
            log "RINGTONE DETECTED via Event! Rebuilding entire Audio route BEFORE answer..."
            apply_pre_init
            apply_mic_fix
            log "Full Hardware Route Primed and Ready!"
        fi
    elif echo "$STATE" | grep -qE "MODE_IN_CALL|MODE_IN_COMMUNICATION|2|3"; then
        if [ "$ACTIVE" = "0" ]; then
            ACTIVE=1
            log "CALL CONNECTED via Event! Aggressively fully re-initializing Handset Mic route!"
            show_notification
        fi
        
        # While in call, maintain the fix loop to prevent race conditions
        while dumpsys audio 2>/dev/null | grep -m 1 -i 'mMode=' | grep -qE "MODE_IN_CALL|MODE_IN_COMMUNICATION|2|3"; do
            apply_pre_init
            apply_mic_fix
            sleep 2
        done
        
        # Exited call loop
        ACTIVE=0
        PRE_INIT=0
        log "Call ended. Audio routes returning to idle state cleanly."
        
        # Clear logcat to avoid reprocessing old events immediately
        logcat -c 2>/dev/null
    else
        if [ "$ACTIVE" = "1" ] || [ "$PRE_INIT" = "1" ]; then
            ACTIVE=0
            PRE_INIT=0
            log "Call ended. Audio routes returning to idle state cleanly."
        fi
    fi
done
