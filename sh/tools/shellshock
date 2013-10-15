#!/usr/bin/env bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2012 - Øyvind 'bolt' Hvidsten   <bolt@dhampir.no>

# Description:
#
# ShellShock is a top-down space shooter written for Bash 3 / Bash 4
# Tested on Linux (Debian, RedHat and CentOS)
#
# Please note: A game in Bash is very demanding on resources.
#              This script requires a modern computer to run at a decent speed.
#              This script uses a tab width of 4, which is automatically applied
#              if you're using vim with modelines enabled (see bottom line).
#
# For updates, please see <http://www.dhampir.no/stuff/bash/shellshock.bash>.
#
# Comments welcome, improvements/patches twice as welcome.
#

# Releases / Changelog:
#
# v1.00, 2012.03.18 - Initial v1.0 release
#                   * All intended functionality implemented
#
# v1.01, 2012.03.19 - Bash 3
#                   * Tweaks to run on Bash 3
#
# v1.05, 2012.03.25 - Several changes based on feedback
#                   * Added score display
#                   * Added increasing difficulty
#
# v1.06, 2012.03.26 - More feedback
#                   * Ship aft collision improved
#                   * Added pause option
#                   * Added simple high score storage
#                   * Runs on Bash 3 again
#
# v1.07, 2012.03.26 - Steve
#                   * Added rudimentary support for Mac OS X
#
# v1.08, 2012.03.26 - Cleanup
#                   * Improved some comments and made clearer error messages
#
# v1.09, 2012.03.27 - Ubuntu
#                   * Various fixes for Ubuntu
#
# v1.10, 2012.03.29 - Pause
#                   * Improved the pause function to avoid problems with timers
#

# get uname
uname=$(uname -s)

# queue temp files for deletion on script exit
function rm_queue { _rm_queue[${#_rm_queue[*]}]="$1"; }
function rm_process { local file; for file in "${_rm_queue[@]}"; do rm "$file"; done; }

# check if tput actually outputs something useful for this terminal
if [[ -z "$(tput sgr0)" ]] || [[ -z "$(tput bold)" ]]; then
	echo 'Error: tput is not working as expected with your current terminal settings!' >&2
	echo 'Try setting your $TERM to something more standard?' >&2
	exit 1
fi

# read a single character
function readc { IFS= read -r -n1 -s "$@" c; }

# variable variables :)
gamepid=""
saved_term=false

# list of files to be removed on cleanup
_rm_queue=()

# cleanup
function cleanup
{
	[[ -z "$gamepid" ]] || { kill -TERM "$gamepid"; wait "$gamepid"; } 2>/dev/null
	rm_process					# remove temp files
	tput sgr0					# reset color
	clear						# clear the screen
	tput cnorm					# show the cursor
	stty echo					# show input
	! $saved_term || tput rmcup	# restore the terminal view
	case "$uname" in
		Darwin)
			reset
		;;
	esac
}
trap cleanup EXIT

# make comm file
# TODO: better solution for inter-thread communication. must work on bash3
case "$uname" in
	Darwin)
		comm=$(mktemp /tmp/shellshock.XXXXXX)
	;;
	*)
		comm=$(mktemp)
	;;
esac
if [[ -n "$comm" ]]; then
	rm_queue "$comm"
else
	echo "Error: Communications file creation failed!" >&2
	exit 1
fi

# init
tput smcup && saved_term=true	# save the current terminal view
tput civis						# hide the cursor

# game subshell
(
	reset 2>/dev/null
	input=false
	trap 'input=true' USR1
	trap 'exit 0' TERM INT HUP

	# test parent shell
	function testparent
	{
		kill -0 $$ 2>/dev/null || exit 1
	}

	# how to print stuff
	function xyecho
	{
		local x=$1 y=$2
		shift 2

		# running this in a loop with 2>/dev/null to avoid "interrupted system call" messages
		while { ! builtin echo -n "${posarray[$((y*cols+x))]}$@"; } 2>/dev/null; do testparent; done
	}
	function safeecho
	{
		# running this in a loop with 2>/dev/null to avoid "interrupted system call" messages
		while { ! builtin echo -n "${posarray[$((y*cols+x))]}$@"; } 2>/dev/null; do testparent; done
	}
	function xyprintf
	{
		local x=$1 y=$2
		shift 2

		# running this in a loop with 2>/dev/null to avoid "interrupted system call" messages
		while { ! builtin printf "${posarray[$((y*cols+x))]}$@"; } 2>/dev/null; do testparent; done
	}
	function safeprintf
	{
		# running this in a loop with 2>/dev/null to avoid "interrupted system call" messages
		while { ! builtin printf "${posarray[$((y*cols+x))]}$@"; } 2>/dev/null; do testparent; done
	}

	# called when the player fires his/her weapons
	function fire # no parameters
	{
		(( ff_ammo_current > 0 )) || return

		if ${ff_alive[ff_next]}; then
			xyprintf $((origo_x+ff_x[ff_next])) $((origo_y+ff_y[ff_next])) " "
		fi

		if ((++ff_total%2 == 0)); then
			ff_x[ff_next]=$((dynel_cx[0]-3))
			ff_y[ff_next]=$((dynel_cy[0]-8))
		else
			ff_x[ff_next]=$((dynel_cx[0]+3))
			ff_y[ff_next]=$((dynel_cy[0]-8))
		fi

		if ! outofbounds "$((origo_x+ff_x[ff_next]))" "$((origo_y+ff_y[ff_next]))"; then
			ff_ydiv[ff_next]=1
			ff_symbol[ff_next]="|"
			ff_damage[ff_next]=1
			ff_alive[ff_next]=true
			(( ++ff_count ))
			ff_new[ff_next]=true
			(( --ff_ammo_current ))
			ff_next=$(( ++ff_next < ff_count_max ? ff_next : 0 ))
		fi

		if ((ff_total%3 == 0)); then
			if ${ff_alive[ff_next]}; then
				xyprintf $((origo_x+ff_x[ff_next])) $((origo_y+ff_y[ff_next])) " "
			fi

			if ((ff_total%2 == 0)); then
				ff_x[ff_next]=$((dynel_cx[0]+5))
				ff_y[ff_next]=$((dynel_cy[0]-7))
			else
				ff_x[ff_next]=$((dynel_cx[0]-5))
				ff_y[ff_next]=$((dynel_cy[0]-7))
			fi

			if ! outofbounds "$((origo_x+ff_x[ff_next]))" "$((origo_y+ff_y[ff_next]))"; then
				ff_ydiv[ff_next]=2
				ff_symbol[ff_next]="¤"
				ff_damage[ff_next]=4
				ff_alive[ff_next]=true
				(( ++ff_count ))
				ff_new[ff_next]=true
				ff_next=$(( ++ff_next < ff_count_max ? ff_next : 0 ))
			fi
		fi
	}

#######################################################
## BEGIN ASCII ART SECTION - NO TABS, NO INDENTATION ##
#######################################################
# title
ascii_title_w=78
ascii_title_h=6
ascii_title=$(
cat - <<"EOF"
  _________.__           .__  .__    _________.__                   __   ._.
 /   _____/|  |__   ____ |  | |  |  /   _____/|  |__   ____   ____ |  | _| |
 \_____  \ |  |  \_/ __ \|  | |  |  \_____  \ |  |  \ /  _ \_/ ___\|  |/ / |
 /        \|   Y  \  ___/|  |_|  |__/        \|   Y  (  <_> )  \___|    < \|
/_______  /|___|  /\___  >____/____/_______  /|___|  /\____/ \___  >__|_ \__
        \/      \/     \/                  \/      \/            \/     \/\/
EOF
)
# keybindings
ascii_keybindings_w=74 #21 - fake width to print off-center
ascii_keybindings_h=5
ascii_keybindings=$(
cat - <<"EOF"
Keybindings:
    arrow keys - move
    SPACE      - fire
    z          - toggle autofire
    p          - pause
    q          - quit
EOF
)
# dead meat - written in quotes because all the parenthesis confuse vim's syntax highlighting
#           - this also means the first line has to be offset, so the ascii looks ugly in code
ascii_dead_w=36
ascii_dead_h=8
ascii_dead=\
' ______   _______  _______  ______
(  __  \ (  ____ \(  ___  )(  __  \
| (  \  )| (    \/| (   ) || (  \  )
| |   ) || (__    | (___) || |   ) |
| |   | ||  __)   |  ___  || |   | |
| |   ) || (      | (   ) || |   ) |
| (__/  )| (____/\| )   ( || (__/  )
(______/ (_______/|/     \|(______/'
# press q
ascii_press_q_w=42
ascii_press_q_h=1
ascii_press_q=$(
cat - <<"EOF"
-= Press q to quit to the title screen! =-
EOF
)
# press fire
ascii_press_fire_w=27
ascii_press_fire_h=1
ascii_press_fire=$(
cat - <<"EOF"
-= Press SPACE to start! =-
EOF
)
# pause
ascii_pause_w=11
ascii_pause_h=1
ascii_pause=$(
cat - <<"EOF"
-= PAUSE =-
EOF
)
# pause frame
ascii_pauseframe_w=25
ascii_pauseframe_h=5
ascii_pauseframe=$(
cat - <<"EOF"
*************************
*                       *
*                       *
*                       *
*************************
EOF
)

# player's spaceship
ascii_playerdynel_w=21
ascii_playerdynel_h=9
ascii_playership=$(
cat - <<"EOF"
08]             
06]         /^\   
03]       |/.!.\|    
01]    _|/_/]=[\_\|_   
00]  _/     | |     \_  
00] |_____. | | ._____| 
00]     \_________/     
04]      |@|   |@|  
05]                
EOF
)
# rock 1
ascii_rock0_w=9
ascii_rock0_h=7
ascii_rock0=$(
cat - <<"EOF"
02]       
01]   __   
01]  /  \_  
00] |     \ 
01]  \   _| 
01]   \_/   
02]       
EOF
)
ascii_rock1_w=14
ascii_rock1_h=8
ascii_rock1=$(
cat - <<"EOF"
06]          
01]       __   
00]  ____/  \_  
00] /         \  
00] \          | 
00]  \     ___/  
01]   \___/     
02]         
EOF
)
ascii_rock2_w=8
ascii_rock2_h=8
ascii_rock2=$(
cat - <<"EOF"
02]      
01]   __  
00]  /  \ 
00] |   |  
00] |    \ 
00] |   _/ 
00] \__/   
00]      
EOF
)
ascii_rock3_w=9
ascii_rock3_h=7
ascii_rock3=$(
cat - <<"EOF"
01]        
00]  _____  
00] /     \ 
00] |     | 
00] \   _/ 
00]  \_/   
01]      
EOF
)
ascii_rock4_w=13
ascii_rock4_h=8
ascii_rock4=$(
cat - <<"EOF"
01]      
00]  ___       
00] /   \_____  
00] |        _| 
00] \       /   
00]  \_    /  
01]    \__/  
03]         
EOF
)
#######################################################
## END ASCII ART SECTION                             ##
#######################################################

	# pretty colours
	color_background=$(tput setab 0)
	color_reset="$(tput sgr0)${color_background}"
	color_black="${color_reset}$(tput setaf 0)"
	color_red="${color_reset}$(tput setaf 1)"
	color_green="${color_reset}$(tput setaf 2)"
	color_orange="${color_reset}$(tput setaf 3)"
	color_blue="${color_reset}$(tput setaf 4)"
	color_magenta="${color_reset}$(tput setaf 5)"
	color_cyan="${color_reset}$(tput setaf 6)"
	color_light_gray="${color_reset}$(tput setaf 7)"
	color_dark_gray="${color_reset}$(tput bold)$(tput setaf 0)"
	color_light_red="${color_reset}$(tput bold)$(tput setaf 1)"
	color_light_green="${color_reset}$(tput bold)$(tput setaf 2)"
	color_yellow="${color_reset}$(tput bold)$(tput setaf 3)"
	color_light_blue="${color_reset}$(tput bold)$(tput setaf 4)"
	color_light_magenta="${color_reset}$(tput bold)$(tput setaf 5)"
	color_light_cyan="${color_reset}$(tput bold)$(tput setaf 6)"
	color_white="${color_reset}$(tput bold)$(tput setaf 7)"

	# specific colors for stuff
	color_debug=$color_orange					# debug prints (FPS, seconds, rocks count, etc)
	color_ship=$color_white						# player's ship
	color_fire=$color_light_magenta				# player's missiles
	color_engine_1=$color_light_red				# player's engines (blinking)
	color_engine_2=$color_red					# player's engines (blinking)
	color_border=$color_red						# border
	color_score_result=$color_yellow			# score result (death screen)
	color_origo=$color_green					# origo         (bottom center)
	color_rock_healthy=$color_light_cyan		# healthy rocks
	color_rock_damaged=$color_cyan				# damaged rocks
	color_death_1=$color_light_red				# death animation stage 1
	color_death_2=$color_red					# death animation stage 2
	color_death_3=$color_dark_gray				# death animation stage 3
	color_death_4=$color_black					# death animation stage 4 (erase)
	color_title=$color_yellow					# ShellShock!
	color_pause_1=$color_light_red				# pause text (blinking)
	color_pause_2=$color_red					# pause text (blinking)
	color_pauseframe=$color_red					# frame around pause text
	color_youaredead=$color_light_red			# YOU ARE DEAD
	color_keybindings=$color_green				# keybindings...
	color_pressfire_1=$color_blue				# press space to start (blinking)
	color_pressfire_2=$color_light_blue			# press space to start (blinking)
	color_pressq_1=$color_dark_gray				# press q for title screen (blinking)
	color_pressq_2=$color_light_gray			# press q for title screen (blinking)

	# score display (top right) (drawn on white background)
	color_score="${color_black}$(tput setab 7)"
	# ammo display (drawn with spaces on background color in the top left)
	color_ammo_1="${color_black}$(tput setab 5)"
	color_ammo_2="${color_black}$(tput setab 7)"

	# home
	home=$(tput home)

	# has the size changed?
	function sizechanged
	{
		if (( cols != $(tput cols) )) || (( rows != $(tput lines) )); then
			cols=$(tput cols)
			rows=$(tput lines)
			origo_x=$((cols/2))
			origo_y=$((rows-1))

			return 0
		fi
		return 1
	}

	# clear
	redraw=false
	function wipe
	{
		# "tput clear" doesn't fill with background color in bash3, screen, etc.
		# must write a shitload of spaces instead
		safeprintf "${color_reset}${home}%$((cols*rows))s" ""

		# everything needs redrawing after this
		redraw=true
	}

	# get the current time in microseconds
	case "$uname" in
		Darwin)
			# this is slow. very slow.
			function microtime {
				local time=$(python <<<"import time; print \"%.6f\" % time.time();")
				echo -n ${time/./}
			}
		;;
		*)
			function microtime {
				local time=$(date +%s%N)
				echo -n ${time:0:((${#time}-3))}
			}
		;;
	esac

	# build tput position array
	# moving using this 10x faster than running tput
	_pos_cols=0
	_pos_rows=0
	function buildposarray
	{
		if ((cols == _pos_cols)) && ((rows == _pos_rows)); then
			return 1
		fi

		wipe
		_pos_cols=$cols
		_pos_rows=$rows
		posarray=()

		local q=false
		local e=$(echo -e "\e")
		if [[ "$(tput cup 0 0)" = "${e}[1;1H" ]]; then
			# standard terminal movement commands - quick generation
			q=true
		fi

		local string="Building position array for ${cols}x${rows}... "
		local pos=$(tput cup 0 ${#string})

		local x y
		safeecho "${color_debug}${home}${string}"
		for ((x=0; x < cols; x++)); do
			if sizechanged; then
				buildposarray
				return $?
			fi
			echo -n "${pos}$((x*100/cols))%"
			for ((y=0; y < rows; y++)); do
				if $q; then
					posarray[$((y*cols+x))]="${e}[$((y+1));$((x+1))H"
				else
					posarray[$((y*cols+x))]=$(tput cup "$y" "$x")
				fi
			done
		done

		return 0
	}
	
	# print something at a spot
	function catc { cat "$@"; }	# draw centered (x coordinate specifies width, not x pos)
	function catd { cat "$@"; } # draw a dynel (supports black outline)
	function cat
	{
		local x=$1 y=$2 i=0 cy dynel=false first=true offset=0

		case "${FUNCNAME[1]}" in
			catd) dynel=true ;;
			catc)
				x=$(( (cols - x) / 2)) # center
				(( x > 0 )) || x=1
			;;
		esac

		while IFS= read -r line; do
			cy=$(( y + i++ ))
			if $dynel; then
				offset="$(( 10#${line:0:2} ))"
				line=${line:3+offset}
				cx=$(( x + offset ))
			else
				cx=$x
			fi
			(( cx < cols-1 )) || continue					# don't write on or outside the right border
			(( cy > 0 )) || continue						# don't write on or above the top border
			(( cy < rows-1 )) || break						# don't write on or below the bottom border
			(( cx >= 1 )) || { line=${line:1-cx}; cx=1; }	# cut to fit inside left border
			line=${line:0:cols-1-cx}						# cut to fit inside right border

			xyecho $cx $cy "$line"
		done
	}

	# border drawing
	function border
	{
		safeecho $color_border

		# no printf -v on bash3 :(
		local line
		while { ! line=$(builtin printf "%${cols}s" ""); } 2>/dev/null; do :; done
		line=${line// /#}

		xyecho 0 0 "$line"

		local y
		for (( y=1; y<rows-1; y++ )); do
			xyecho 0 $y "#"
			xyecho $((cols-1)) $y "#"
		done

		xyecho 0 $((rows-1)) "$line"
	}

	# is something outside the screen?
	function outofbounds # $1 - x coordinate, $2 - y coordinate
	{
		local x=$1 y=$2
		if
			(( x < 1 )) || (( x >= cols-1 )) ||
			(( y < 1 )) || (( y >= rows-1 ))
		then
			return 0
		fi
		return 1
	}

	# pushes a dynel until it's within the right and left borders
	function restrict_xaxis # $1 - dynel_* index
	{
		local i=$1
		dynel_x[i]=${dynel_cx[i]}
		while ! canmoveright $i;	do (( dynel_cx[i]-- )); done;
		while ! canmoveleft $i;		do (( dynel_cx[i]++ )); done;
		(( dynel_cx[i] < dynel_x[i] )) && (( dynel_cx[i]++ ))
		(( dynel_cx[i] > dynel_x[i] )) && (( dynel_cx[i]-- ))
		dynel_x[i]=${dynel_cx[i]}
	}

	# pushes a dynel until it's within the top and bottom borders
	function restrict_yaxis # $1 - dynel_* index
	{
		local i=$1
		dynel_y[i]=${dynel_cy[i]}
		while ! canmoveup $i;		do (( dynel_cy[i]++ )); done;
		while ! canmovedown $i;		do (( dynel_cy[i]-- )); done;
		(( dynel_cy[i] < dynel_y[i] )) && (( dynel_cy[i]++ ))
		(( dynel_cy[i] > dynel_y[i] )) && (( dynel_cy[i]-- ))
		dynel_y[i]=${dynel_cy[i]}
	}

	# collides dynels based on simple squares (width, height)
	function squarecollide # $1 - dynel_* index
	{
		local i=$1
		for j in "${!dynel_alive[@]}"; do
			${dynel_alive[j]} || continue	# don't check dead dynels
			(( j != i )) || continue		# don't check yourself
			(( j >= rock_pos )) || continue	# don't check the playership
			local distance_x=$((dynel_cx[i] > dynel_cx[j] ? dynel_cx[i]-dynel_cx[j] : dynel_cx[j]-dynel_cx[i]))
			local distance_y=$((dynel_cy[j] - dynel_cy[i]))
			if
				(( distance_x < (dynel_w[i]+dynel_w[j])/2 )) &&
				{
					if (( distance_y < 0 )); then
						# j (compare dynel) is above i
						(( -distance_y < dynel_h[j] ))
					else
						# j (compare dynel) is below i
						(( distance_y < dynel_h[j] ))
					fi
				}
			then
				# collision!
				return 0
			fi
		done

		# no collision
		return 1
	}

	# collides the player's ship
	# basically the same as square collision, but with some tweaks to make it feel better
	function shipcollide # no parameters
	{
		local i=0
		for j in "${!dynel_alive[@]}"; do
			${dynel_alive[j]} || continue	# don't check dead dynels
			(( j != i )) || continue		# don't check yourself
			local distance_x=$((dynel_cx[i] > dynel_cx[j] ? dynel_cx[i]-dynel_cx[j] : dynel_cx[j]-dynel_cx[i]))
			local distance_y=$((dynel_cy[j] - dynel_cy[i]))
			if
				(( distance_x + 2 < (dynel_w[i]+dynel_w[j])/2 )) && # make the ship a little narrower
				{
					if (( distance_y < 0 )); then
						# j (compare dynel) is above i
						(( -distance_y < dynel_h[j] )) &&
						(( (distance_y + dynel_h[i]) > distance_x - 4 )) # make a somewhat cone-shaped ship
					else
						# j (compare dynel) is below i
						(( distance_y + 2 < dynel_h[j] )) && # make the ship a little shorter
						{
							((dynel_h[j] - distance_y - 2 > 2)) ||				# 2 lines into ship from bottom
							((4 + (dynel_h[j] - distance_y - 2) > distance_x))	# engine hit
						}
					fi
				}
			then
				# collision!
				return 0
			fi
		done

		# no collision
		return 1
	}

	# runs hit tests on friendly fire and damages any rocks encountered
	function ffhit # $1 - ff_* index
	{
		local x=${ff_x[$1]} y=${ff_y[$1]} i j
		for i in "${!dynel_alive[@]}"; do
			(( i >= rock_pos )) || continue	# only check rocks
			${dynel_alive[i]} || continue	# don't check dead dynels
			if
				((y > dynel_y[i]-2)) ||												# haven't reached rock yet - miss
				((y < dynel_y[i]-dynel_h[i])) ||									# behind the rock - miss
				(( (x > dynel_x[i] ? x-dynel_x[i] : dynel_x[i]-x) > dynel_w[i]/2 ))	# simple square collision
			then
				continue
			else
				((dynel_hp[i] -= ff_damage[$1]))
				if ((dynel_hp[i] > 0)) && ((dynel_hp[i] < rock_hp/2)); then
					dynel_color[i]=$color_rock_damaged
					dynel_redraw[i]=true
				fi
				(( score_current += score_rockshot * ff_damage[$1] ))
				# it's a hit!
				return 0
			fi
		done

		# missed
		return 1
	}

	# changes the color of a dynel several times until it's finally drawn with black to disappear
	function deathanimation # $1 - dynel_* index
	{
		local i=$1
		# it helps to read this backwards :)
		case "${dynel_color[i]}" in
			"$color_death_4") return 1 ;;
			"$color_death_3") dynel_color[i]=$color_death_4 ;;
			"$color_death_2") dynel_color[i]=$color_death_3 ;;
			"$color_death_1") dynel_color[i]=$color_death_2 ;;
			*) dynel_color[i]=$color_death_1 ;;
		esac
		return 0
	}
	
	# limit the amount of rocks
	function limitrocks
	{
		rock_count_max=$(((rows*cols) / 720))
	}

	# update the amount of score you get for stuff
	function updatescore
	{
		score_rockshot=10							# score per damage point that hits a rock
		score_deadrock=$((500000 / (rows*cols)))	# score per dead rock (off screen or shot to pieces)
		case "$state_current" in
			ingame) ;;
			title)
				score_current=0						# current score
				score_last=-1						# last drawn sore
				score_second=0						# score per second passed
			;;
		esac
	}

	# movable? # $1 - dynel_* index
	function canmoveup    { (( origo_y+dynel_cy[$1]-dynel_h[$1] > 0 )); }
	function canmovedown  { (( origo_y+dynel_cy[$1] < rows )); }
	function canmoveright { (( origo_x+dynel_cx[$1]+(dynel_w[$1]/2)+1 < cols )); }
	function canmoveleft  { (( origo_x+dynel_cx[$1]-(dynel_w[$1]/2) > 0 )); }

	# tput position array
	posarray=()								# position array for faster cursor movement
	sizechanged								# run console size check (will always have changed)

	# pause and unpause
	function registerpausetimer
	{
		pausetimers[${#pausetimers[*]}]="$1"
	}
	function pause
	{
		if ! $pause; then
			local timer value
			for timer in "${pausetimers[@]}"; do
				value=${!timer}
				if (( value != 0 )); then
					(( value -= time_now ))
				else
					value="zero"
				fi
				IFS= read -r $timer <<< "$value"
			done
			pause=true
		fi
	}
	function unpause
	{
		if $pause; then
			local timer value
			for timer in "${pausetimers[@]}"; do
				value=${!timer}
				if [[ value != "zero" ]]; then
					(( value += time_now ))
				else
					value=0
				fi
				IFS= read -r $timer <<< "$value"
			done
			pause=false
		fi
	}

	# ammo line - no printf -v on bash3 :(
	ff_ammo_max=30							# maximum ammunition
	while { ! ff_line=$(builtin printf "%${ff_ammo_max}s" ""); } 2>/dev/null; do :; done

	# init
	time_start=$(microtime)					# time the game was started
	time_last=$time_start					# time of last game loop
	time_now=$time_start					# current time
	timer_resize=0							# resize check timer
	timerd_resize=1000000					# resize check timer delta
	state_current="title"					# current game state
	state_last=""							# game state last loop
	movespeed_x=7							# how fast the player ship moves horizontally
	movespeed_y=3							# how fast the player ship moves vertically
	blink_pressfire=""						# blink status for the "press fire" text on title screen
	blink_pressq=""							# blink status for the "press q" text on death screen
	blink_engines=""						# blink status for the ship's engines
	blink_pause=""							# blink status for the pause message
	messageheight=4							# how far away from the top we print the title and such
	cpusavesleep=0.2						# time to sleep if saving cpu (dead, paused, menu)
	redraw=true								# should we redraw everything? (size probably changed)

	# reset the game
	function resetgame
	{
		# dynels
		dynel_img=( "ascii_playership" )	# drawing
		dynel_x=( 0 )						# current screen position (last drawn)
		dynel_y=( 1 )						# current screen position (last drawn)
		dynel_cx=( ${dynel_x[0]} )			# actual position
		dynel_cy=( ${dynel_y[0]} )			# actual position
		dynel_ydiv=( 0 )					# automatic movement (for non-player dynels)
		dynel_w=( $ascii_playerdynel_w )	# width
		dynel_h=( $ascii_playerdynel_h )	# height
		dynel_hp=( 1 )						# health
		dynel_color=( $color_ship )			# color
		dynel_redraw=( true )				# needs redrawing or not
		dynel_alive=( true )				# dynel exists

		# rocks
		rock_pos=${#dynel_alive[*]}			# rock position in dynel array
		rock_count=0						# current number of live rocks
		rock_hp=12							# rock health
		rock_total=0						# total number of rocks spawned
		rock_add=0							# additional rocks for difficulty
		limitrocks							# set the max rock count

		# friendly fire
		ff_x=()								# screen position
		ff_y=()								# screen position
		ff_ydiv=()							# speed divisor
		ff_new=()							# when new, don't move, only draw
		ff_symbol=()						# symbol to draw
		ff_damage=()						# how much damage this shot does
		ff_count=0							# current number of live shots
		ff_count_max=64						# max shot count at any given time
		ff_total=0							# total number of shots fired
		ff_next=0							# next shot
		ff_alive=()							# shot exists
		ff_ammo_current=$((ff_ammo_max/2))	# current ammo
		ff_ammo_last=0						# last drawn ammo
		counter_fire=0						# number of shots fired
		for (( i=0; i<ff_count_max; i++ )); do ff_alive[i]=false; done
	
		# timers and stuff
		pausetimers=()
		timer_ammo=$time_now				# timer for ammo generation
		timerd_ammo=450000					# timer delta for above
		registerpausetimer "timer_ammo"
		timer_autofire=$time_now			# timer for the autofire function
		timerd_autofire=200000				# timer delta for above
		registerpausetimer "timer_autofire"
		timer_manualfire=$time_now			# timer for manual fire
		timerd_manualfire=100000			# timer delta for above
		registerpausetimer "timer_manualfire"
		timer_fire=$time_now				# timer for update/drawing of fire
		timerd_fire=50000					# timer delta for above
		registerpausetimer "timer_fire"
		timer_rocks=$time_now				# timer for update/drawing of rocks
		timerd_rocks=""						# timer delta for above
		registerpausetimer "timer_rocks"
		timer_playerdeath=0					# used for drawing the player ship death animation
		timerd_playerdeath=500000			# timer delta for above
		registerpausetimer "timer_playerdeath"
		seconds_last=0						# runtime in seconds (last printed)

		# blinking - allows blinking text and stuff to blink in sync
		blink_fast=false
		timer_blink_fast=$time_start
		blink_medium=false
		timer_blink_medium=$time_start
		blink_slow=false
		timer_blink_slow=$time_start

		# misc
		autofire=false						# is autofire enabled?
		runshipcollision=false				# run ship collision this frame?
		pause=false							# is the game paused?
		pause_last=false					# was the game paused last frame?
	}
	resetgame

	# game loop
	while true; do
		time_now=$(microtime)
		seconds=$(((time_now-time_start)/1000000))
		framecounter=${framecounter:-0}
		fps=${fps:-$framecounter}
		(( framecounter++ ))

		# blinking
		if (( timer_blink_fast + 200000 < time_now )); then
			timer_blink_fast=$time_now
			$blink_fast && blink_fast=false || blink_fast=true
		fi
		if (( timer_blink_medium + 600000 < time_now )); then
			timer_blink_medium=$time_now
			$blink_medium && blink_medium=false || blink_medium=true
		fi
		if (( timer_blink_slow + 999999 < time_now )); then
			timer_blink_slow=$time_now
			$blink_slow && blink_slow=false || blink_slow=true
		fi

		# resize if needed
		if
			[[ "$state_current" != "$state_last" ]] ||
			[[ "$pause" != "$pause_last" ]] ||
			{
				(( timer_resize + timerd_resize < time_now )) &&
				{
					timer_resize=$time_now
					# this check is frakkin' expensive - do it only once per second
					sizechanged
				}
			}
		then
			state_last=$state_current
			pause_last=$pause

			# clean up and resize
			wipe			# wipe the screen
			buildposarray	# build new position array to move about
			limitrocks		# update the number of rocks we should have
			updatescore		# update how much score you get

			# push dynels inwards
			for i in "${!dynel_alive[@]}"; do
				${dynel_alive[i]} || continue
				restrict_xaxis $i
				if ((i == 0)); then
					restrict_yaxis $i
				fi
			done
		fi
		if $redraw; then
			border
			safeecho $color_origo
			xyecho $origo_x $origo_y "#"
		fi

		# fps & counter
		safeecho $color_debug
		if (( seconds > seconds_last )); then
			fps=$framecounter
			framecounter=0
			case "$state_current" in
				ingame|dead)
					xyprintf $((cols-2-9)) 2 "Dynl: %3d" "${#dynel_alive[*]}"
					xyprintf $((cols-2-9)) 3 "Rock: %3d" "$rock_count"
					xyprintf $((cols-2-9)) 4 "Shot: %3d" "$ff_count"
					xyprintf $((cols-2-6)) 5 "%6d" "$timerd_rocks"
#					xyecho $((cols-2-${#seconds})) 6 "$seconds"
				;;
			esac
		fi
		xyprintf $((cols-10)) 1 "FPS: %3d" "$fps"

		# read input
		if $input; then
			readc <"$comm"

			case "$state_current" in
				ingame)
					case "$c" in
						A|B|C|D)
							if ! $pause && ((dynel_hp[0] > 0)); then
								case "$c" in
										A) # up
											for (( i=0; i<movespeed_y; i++ )); do
												canmoveup		0 && dynel_redraw[0]=true && runshipcollision=true || break && (( dynel_cy[0]-- ))
											done
										;;
										B) # down
											for (( i=0; i<movespeed_y; i++ )); do
												canmovedown		0 && dynel_redraw[0]=true && runshipcollision=true || break && (( dynel_cy[0]++ ))
											done
										;;
										C) # right
											for (( i=0; i<movespeed_x; i++ )); do
												canmoveright	0 && dynel_redraw[0]=true && runshipcollision=true || break && (( dynel_cx[0]++ ))
											done
										;;
										D) # left
											for (( i=0; i<movespeed_x; i++ )); do
												canmoveleft		0 && dynel_redraw[0]=true && runshipcollision=true || break && (( dynel_cx[0]-- ))
											done
										;;
								esac
							fi
						;;
						' ')
							if ! $pause && ((dynel_hp[0] > 0)) && ! $autofire && (( timer_manualfire + timerd_manualfire < time_now )); then
								timer_manualfire=$time_now
								fire
							fi
						;;
						'p')
							if ! $pause; then
								pause
							else
								unpause
							fi
						;;
						'z')
							if ! $pause; then
								if ((dynel_hp[0] > 0)); then
									$autofire && autofire=false || autofire=true
								fi
							fi
						;;
						'q')
							if ! $pause; then
								state_current="title"
							else
								unpause
							fi
						;;
					esac
				;;
				title)
					case "$c" in
						' ')
							resetgame
							updatescore
							timerd_rocks=100000
							autofire=false
							state_current="ingame"
						;;
						'q') kill -TERM $$; exit 0; ;;
					esac
				;;
				dead)
					case "$c" in
						'q') resetgame; state_current="title" ;;
					esac
				;;
			esac

			input=false
		fi

		# move and draw
		case "$state_current" in
			title)
				if $redraw; then
					safeecho $color_title
					catc $ascii_title_w $messageheight <<<"${ascii_title}"
				fi
				if $redraw; then
					safeecho $color_keybindings
					catc $ascii_keybindings_w $((messageheight + ascii_title_h + 3)) <<<"${ascii_keybindings}"
				fi
				if $redraw || [[ "$blink_pressfire" != "$blink_medium" ]]; then
					blink_pressfire=$blink_medium
					$blink_medium && safeecho $color_pressfire_1 || safeecho $color_pressfire_2
					catc $ascii_press_fire_w $((messageheight + ascii_title_h + 1)) <<<"$ascii_press_fire"
				fi

				# sleep to save cpu
				sleep $cpusavesleep
			;;
			dead)
				if $redraw; then
					safeecho $color_youaredead
					catc 7 $messageheight <<<"YOU ARE"
					catc $ascii_dead_w $((messageheight + 1)) <<<"${ascii_dead}"
				fi
				if $redraw; then
					safeecho $color_score_result
					catc $((19+${#score_current})) $((messageheight + ascii_dead_h + 2)) <<<"You scored $score_current points!"
				fi
				if $redraw; then
					# reading and writing this high score is sensitive to signal interruption and is somewhat error prone
					highscore=$(command cat "${HOME}/.shellshock" 2>/dev/null)
					if ((score_current > highscore)); then
						echo -n "$score_current" >"${HOME}/.shellshock"
					fi
					safeecho $color_score_result
					if ((score_current >= highscore)); then
						catc 15 $((messageheight + ascii_dead_h + 3)) <<<"NEW HIGH SCORE!"
					else
						catc $((12+${#highscore})) $((messageheight + ascii_dead_h + 3)) <<<"High Score: $highscore"
					fi
				fi
				if $redraw || [[ "$blink_pressq" != "$blink_slow" ]]; then
					blink_pressq=$blink_slow
					$blink_slow && safeecho $color_pressq_1 || safeecho $color_pressq_2
					catc $ascii_press_q_w $((messageheight + ascii_dead_h + 5)) <<<"$ascii_press_q"
				fi

				# sleep to save cpu
				sleep $cpusavesleep
			;;
			ingame)
				if ! $pause; then
					# need to run ship collision?
					runshipcollision=false

					# speed up and add score every second
					if (( seconds > seconds_last )); then
						timerd_rocks=$(( timerd_rocks > 250 ? timerd_rocks - 250 : 0))
						(( score_current += ++score_second ))
						rock_add=$((rock_count_max * score_current / 200000))
					fi
				fi

				# move and impact friendly fire
				if
					$redraw ||
					{
						! $pause &&
						(( timer_fire + timerd_fire < time_now ))
					}
				then
					if ! $pause; then
						timer_fire=$time_now
						(( counter_fire++ ))
					fi
					safeecho $color_fire
					for (( i=0; i<ff_count_max; i++ )); do
						if ${ff_alive[i]}; then
							if
								$redraw &&
								outofbounds "$((origo_x+ff_x[i]))" "$((origo_y+ff_y[i]))"
							then
								ff_alive[i]=false
								(( --ff_count ))
							elif ${ff_new[i]}; then
								ff_new[i]=false
								if ffhit $i; then
									ff_alive[i]=false
									(( --ff_count ))
								else
									xyecho $((origo_x+ff_x[i])) $((origo_y+ff_y[i])) "${ff_symbol[i]}"
								fi
							else
								if $redraw; then
									xyecho $((origo_x+ff_x[i])) $((origo_y+ff_y[i])) "${ff_symbol[i]}"
								fi
								if ! $pause && (( counter_fire % ff_ydiv[i] == 0 )); then
									xyecho $((origo_x+ff_x[i])) $((origo_y+ff_y[i])) " "
									if (( origo_y + --ff_y[i] == 0 )); then
										ff_alive[i]=false
										(( --ff_count ))
									else
										if ffhit $i; then
											ff_alive[i]=false
											(( --ff_count ))
										else
											xyecho $((origo_x+ff_x[i])) $((origo_y+ff_y[i])) "${ff_symbol[i]}"
										fi
									fi
								fi
							fi
						fi
					done
				fi

				if ! $pause; then
					# autofire
					if $autofire && (( timer_autofire + timerd_autofire < time_now )); then
						timer_autofire=$time_now
						timer_manualfire=$time_now
						fire
					fi

					# move rocks?
					if ((dynel_hp[0] > 0)) && ((timer_rocks + timerd_rocks < time_now)); then
						timer_rocks=$time_now
						(( ++rock_total ))
					fi

					# deal with rocks
					if ((dynel_hp[0] > 0)); then
						first_dead=""
						for i in "${!dynel_alive[@]}"; do
							(( i >= rock_pos )) || continue
							${dynel_alive[i]} || { first_dead=${first_dead:-$i}; continue; }
							if
								# outside bottom of screen by entire height
								(( dynel_y[i] - dynel_h[i] > 0 ))
							then
								dynel_alive[i]=false
								(( --rock_count ))
								first_dead=${first_dead:-$i}
								(( score_current += score_deadrock ))
							elif
								# should be moved now
								(( timer_rocks == time_now )) &&
								(( rock_total % dynel_ydiv[i] == 0 ))
							then
								if ((dynel_hp[i] <= 0)); then
									if ! deathanimation $i; then
										dynel_alive[i]=false
										(( --rock_count ))
										first_dead=${first_dead:-$i}
										(( score_current += score_deadrock ))
									fi
								fi
								(( dynel_cy[i]++ ))
								dynel_redraw[i]=true
								runshipcollision=true
							fi
						done
						
						if ((rock_count < rock_count_max + rock_add)); then
							i=${first_dead:-${#dynel_alive[*]}}
							dynel_w[i]="ascii_rock$((i%5))_w"
							dynel_w[i]=${!dynel_w[i]}
							dynel_h[i]="ascii_rock$((i%5))_h"
							dynel_h[i]=${!dynel_h[i]}
							dynel_x[i]=$(( (RANDOM % (cols-2-dynel_w[i])) - ( (cols-2)/2 ) ))
							dynel_y[i]=$((-origo_y))
							dynel_cx[i]=${dynel_x[i]}
							dynel_cy[i]=${dynel_y[i]}
							restrict_xaxis $i
							if ! squarecollide $i; then
								dynel_ydiv[i]=$((RANDOM%3+1))
								for j in "${!dynel_alive[@]}"; do
									(( j >= rock_pos )) || continue
									if
										${dynel_alive[j]} &&
										((dynel_ydiv[i] < dynel_ydiv[j] )) &&
										(( (dynel_x[i] > dynel_x[j] ? dynel_x[i]-dynel_x[j] : dynel_x[j]-dynel_x[i]) < ((dynel_w[i]+dynel_w[j])/2) ))
									then
										dynel_ydiv[i]=${dynel_ydiv[j]}
									fi
								done
								dynel_hp[i]=$rock_hp
								dynel_color[i]=$color_rock_healthy
								dynel_redraw[i]=false
								dynel_img[i]="ascii_rock$((i%5))"
								dynel_alive[i]=true
								(( ++rock_count ))
							fi
						fi
					fi

					# do ship collision
					if $runshipcollision && shipcollide; then
						(( dynel_hp[0]-- ))
					fi
					if ((dynel_hp[0] <= 0)) && ((timer_playerdeath + timerd_playerdeath < time_now)); then
						timer_playerdeath=$time_now
						dynel_redraw[0]=true
						if ! deathanimation 0; then
							state_current="dead"
						fi
					fi

					# regenerate ammo
					if (( timer_ammo + timerd_ammo + (timerd_rocks*3) < time_now )) && ((ff_ammo_current < ff_ammo_max)); then
						timer_ammo=$time_now
						(( ++ff_ammo_current ))
					fi
				fi # if ! $pause

				# draw ammo
				if $redraw; then
					xyecho 0 0 "${color_ammo_1}${ff_line:0:$ff_ammo_current}"
					xyecho ${ff_ammo_current} 0 "${color_ammo_2}${ff_line:$ff_ammo_current:$ff_ammo_max}"
				else
					if ((ff_ammo_current < ff_ammo_last)); then
						xyecho $ff_ammo_current 0 "${color_ammo_2}${ff_line:0:$((ff_ammo_last-ff_ammo_current))}"
					elif ((ff_ammo_current > ff_ammo_last)); then
						xyecho $ff_ammo_last 0 "${color_ammo_1}${ff_line:0:$((ff_ammo_current-ff_ammo_last))}"
					fi
				fi

				# score
				if $redraw || (( score_current != score_last )); then
					score_last=$score_current
					xyecho $((cols-${#score_current})) 0 "${color_score}${score_current}"
				fi

				# blink engines of player ship
				if ! $pause && ((dynel_hp[0] > 0)) && ! ${dynel_redraw[0]} && [[ "$blink_engines" != "$blink_fast" ]]; then
					blink_engines=$blink_fast
					$blink_fast && safeecho $color_engine_1 || safeecho $color_engine_2
					xyecho $((origo_x+dynel_cx[0]+3)) $((origo_y+dynel_cy[0]-2)) "@"
					xyecho $((origo_x+dynel_cx[0]-3)) $((origo_y+dynel_cy[0]-2)) "@"
				fi

				# draw/move dynels one step at a time to their current position
				lastalive=0
				for i in "${!dynel_alive[@]}"; do
					${dynel_alive[i]} && lastalive=$i || continue
					$redraw || ${dynel_redraw[i]} || continue

					dynel_redraw[i]=false

					safeecho ${dynel_color[i]}
					while
						if   (( dynel_x[i] < dynel_cx[i] )); then (( dynel_x[i]++ ))
						elif (( dynel_x[i] > dynel_cx[i] )); then (( dynel_x[i]-- )); fi
						if   (( dynel_y[i] < dynel_cy[i] )); then (( dynel_y[i]++ ))
						elif (( dynel_y[i] > dynel_cy[i] )); then (( dynel_y[i]-- )); fi

						catd \
						$(( origo_x-(dynel_w[i]/2)+dynel_x[i] )) \
						$(( origo_y-dynel_h[i]+dynel_y[i] )) \
						<<<"${!dynel_img[i]}"

						# fake do-while condition
						(( dynel_x[i] != dynel_cx[i] )) ||
						(( dynel_y[i] != dynel_cy[i] ))
					do :; done
				done

				# draw pause anim
				if $pause_last; then # this uses pause_last to avoid drawing the pause blinker before the frame
					if $redraw; then
						safeecho ${color_pauseframe}
						catc $ascii_pauseframe_w $((messageheight + 4)) <<<"$ascii_pauseframe"
					fi
					if $redraw || [[ "$blink_pause" != "$blink_slow" ]]; then
						blink_pause=$blink_slow
						$blink_slow && safeecho $color_pause_1 || safeecho $color_pause_2
						catc $ascii_pause_w $((messageheight + 6)) <<<"$ascii_pause"
					fi

					# sleep to save cpu
					sleep $cpusavesleep
				fi
				
				# purge dead dynels
				size=${#dynel_alive[*]}
				(( ++lastalive ))
				for ((i=lastalive; i<size; i++)); do
					unset dynel_alive[i]
				done
			;;
		esac
		redraw=false
		ff_ammo_last=$ff_ammo_current
		seconds_last=$seconds
	done
) &
gamepid=$!

# exit normally on several signals
trap 'exit 0' TERM INT HUP

# input loop
stty -echo
while true; do
	readc
	case "$c" in
		$'\e')
			readc
			[[ "$c" = '[' ]] || continue
			readc
			case "$c" in
				A|B|C|D)
					builtin echo "$c" >"$comm"
					kill -USR1 "$gamepid"
				;;
			esac
		;;
		' '|p|q|z)
			builtin echo "$c" >"$comm"
			kill -USR1 "$gamepid"
		;;
	esac
done

# vim: tabstop=4:softtabstop=4:shiftwidth=4:noexpandtab
