menu="$1"

if [ "$menu" = "music" ]; then
    rofi -modi 'Music:~/Scripts/rofi/rofi-music.sh' -show Music -theme music
elif [ "$menu" = "drun" ]; then
    rofi -show drun -theme clean
elif [ "$menu" = "powermenu" ]; then
    rofi -modi 'Powermenu:~/dotdotdots/scripts/power.sh' -show Powermenu -theme powermenu
fi
