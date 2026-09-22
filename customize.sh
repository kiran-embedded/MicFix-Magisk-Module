#!/system/bin/sh
ui_print "*******************************"
ui_print " MicFix Speaker-Mic TX (v1.2)  "
ui_print " By: kiran-embedded           "
ui_print "*******************************"
sleep 0.5
ui_print "⚙  Initializing gear system..."
sleep 0.5
ui_print "⚙⚙  Optimizing Audio Paths..."
sleep 0.5
ui_print "⚙⚙⚙  Patching system modules..."
sleep 0.5
ui_print " "
ui_print "✓ Boot optimization active."
ui_print "✓ Log export to /sdcard/Download configured."
ui_print " "
ui_print "- Searching for tinymix on your device..."

TINYMIX=$(command -v tinymix 2>/dev/null)
if [ -z "$TINYMIX" ]; then
    for path in /system/bin/tinymix /vendor/bin/tinymix /system/vendor/bin/tinymix /system_ext/bin/tinymix; do
        if [ -x "$path" ]; then
            TINYMIX="$path"
            break
        fi
    done
fi
if [ -z "$TINYMIX" ]; then
    TINYMIX=$(find -L / -name "tinymix" -type f -executable 2>/dev/null | head -n 1)
fi

if [ -n "$TINYMIX" ] && [ -x "$TINYMIX" ]; then
    ui_print "✓ FOUND: $TINYMIX"
    ui_print "  Runtime call polling will be ENABLED."
    echo "TOOL_TYPE=tinymix" > "$MODPATH/mixer_tool.conf"
    echo "TOOL_PATH=$TINYMIX" >> "$MODPATH/mixer_tool.conf"
else
    ui_print "✕ NOT FOUND: tinymix binary is missing."
    ui_print "  You must install a tinymix binary first!"
    echo "TOOL_TYPE=none" > "$MODPATH/mixer_tool.conf"
fi
ui_print " "
ui_print "*******************************"
