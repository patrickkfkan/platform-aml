#!/bin/bash

# This script is targeted towards the MusicPlayerDaemon (MPD) running on 
# Amlogic Meson6 g02 customer platforms (with kernel 3.10.108).

# When you play a list of tracks in MPD, you will eventually hear crackling
# noises when MPD switches to another track. You will see "audio data unaligned"
# errors in the kernel messages for as long as the remaining tracks are being
# played. These errors are produced by the aml_pcm driver.

# This script provides an ugly workaround for this problem. It detects when 
# MPD changes tracks, and quickly pauses and resumes playback. This has the
# following effect:
# - When playback is paused, aml_platform_close() is called, clearing any 
#   state left over by the previous playback.
# - When playback is resumed, aml_platform_open() is called and allows the
#   next track to be played normally with no leftover state getting in the way.

# Note that if you have enabled Sample Rate Resampling in MPD (i.e. setting it
# to something other than Native), you will still get "audio data unaligned" 
# errors + crackling noises. Unfortunately, this script cannot work around
# that issue.

while true
do
    EVENT=$(mpc idle playlist player)
    STATUS=$(mpc)
    if [[ "$EVENT" =~ "playlist" && "$EVENT" =~ "player" && 
            "$STATUS" =~ "[playing]" && "$STATUS" =~ "(0%)" ]]; then
        # Track change detected
        if [[ $(volumio status | grep service | grep webradio) ]]; then
            echo "Track change detected but service is webradio, so ignoring it"
        else
            echo "Track change detected - giving it a pause to clear current state"
            mpc -q pause
            mpc -q play
        fi
    fi
done
