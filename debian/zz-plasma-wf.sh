# needed for correct plasma theming and 
# exporting vars globally to smoothly make things work on ssh too

# set by droidian-gnome-quirks
# override with plasma vars
export XDG_CURRENT_DESKTOP=KDE
unset XDG_SESSION_DESKTOP
export XDG_MENU_PREFIX=plasma-
unset QT_STYLE_OVERRIDE

# for ssh
export WAYLAND_DISPLAY=wayland-1
export QT_QPA_PLATFORMTHEME=KDE
export QT_QUICK_CONTROLS_STYLE=org.kde.breeze
export QT_QUICK_CONTROLS_MOBILE=true
export PLASMA_INTEGRATION_USE_PORTAL=1
export PLASMA_PLATFORM=phone:handset
