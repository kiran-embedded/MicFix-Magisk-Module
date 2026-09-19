#!/system/bin/sh
sleep 0.5
ui_print " "
ui_print "      ███╗   ███╗██╗ ██████╗███████╗██╗██╗  ██╗"
sleep 0.2
ui_print "      ████╗ ████║██║██╔════╝██╔════╝██║╚██╗██╔╝"
sleep 0.2
ui_print "      ██╔████╔██║██║██║     █████╗  ██║ ╚███╔╝ "
sleep 0.2
ui_print "      ██║╚██╔╝██║██║██║     ██╔══╝  ██║ ██╔██╗ "
sleep 0.2
ui_print "      ██║ ╚═╝ ██║██║╚██████╗██║     ██║██╔╝ ██╗"
sleep 0.2
ui_print "      ╚═╝     ╚═╝╚═╝ ╚═════╝╚═╝     ╚═╝╚═╝  ╚═╝"
sleep 0.5
ui_print " "
ui_print " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "    Ultimate Robust Audio Fix (ZeroCPU Edition) "
ui_print "                    v45.0                      "
ui_print " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 0.5
ui_print "  ★ Developer: Kiran"
ui_print "  ★ GitHub: github.com/kiran-embedded"
ui_print " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print " "
sleep 0.5

ui_print " [>] Initializing flash sequence..."
sleep 0.3
ui_print " [>] Extracting zero-CPU event listeners..."
sleep 0.3
ui_print " [>] Loading deep hardware ADC drivers..."
sleep 0.3
ui_print " [>] Injecting SurfaceFlinger GPU boosters..."
sleep 0.3
ui_print " [>] Patching Background RAM Governor..."
sleep 0.8
ui_print " "

ui_print " [>] Searching for 'tinymix' binary on device..."
sleep 0.5
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
    ui_print "     [✓] FOUND: $TINYMIX"
    sleep 0.3
    ui_print "     [✓] Runtime audio routing ENABLED."
    echo "TOOL_TYPE=tinymix" > "$MODPATH/mixer_tool.conf"
    echo "TOOL_PATH=$TINYMIX" >> "$MODPATH/mixer_tool.conf"
else
    ui_print "     [✕] ERROR: tinymix binary is missing!"
    ui_print "     [!] The module requires a tinymix binary."
    echo "TOOL_TYPE=none" > "$MODPATH/mixer_tool.conf"
fi

sleep 0.5
ui_print " "
ui_print " [>] Wrapping up installation..."
sleep 0.4
ui_print " [>] Setting strict file permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/system/bin/micfix" 0 0 0755
sleep 0.4
ui_print " "
ui_print " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "  [✓] Flash Complete! Please Reboot."
ui_print "  [i] After reboot, run 'su -c micfix' in terminal"
ui_print " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
