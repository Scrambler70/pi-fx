#!/bin/bash

# wait for booting to complete
# sleep 1

# necessary to start jack
export DISPLAY=:0

#start midi 
killall python3
sleep 1 
python3 ./floorboard.py &

# end previous processes
killall -9 jackd || echo "jackd was not running."
killall -9 sooperlooper || echo "sooperlooper was not running."
sleep 1 # seconds

# trick to boot without dbus maybe?
#export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

# start jack server
# this line should also be in ~/.jackdrc, because if the below line fails, sooperlooper will start its own jackd using the config in ~/.jackdrc
#/usr/bin/jackd --no-realtime --verbose -dalsa -r44100 -p512 -n3 -dhw:1 -s > /home/pi/loop-baby/jackd_errors.log 2>&1 &
/usr/bin/jackd --no-realtime -dalsa -r48000 -p256 -n3 -dhw:CODEC -s > /home/pi/loop-baby/jacd_errors.log 2>&1 &

# wait for jack to start
echo "waiting for jack to start"
sleep 5


# start sooperlooper
sooperlooper -p 9951 -l 1 -c 1 -t 20  --load-midi-binding ./custom.slb &

# wait for sooperlooper to start
sleep 3

# confirm port names
#jack_lsp -c
jack_connect system:capture_1 sooperlooper:common_in_1 || echo "error connecting audio (1)"
jack_connect sooperlooper:common_out_1 system:playback_1 || echo "error connecting audio (2)"
jack_connect sooperlooper:common_out_2 system:playback_2 || echo "error connecting audio (3)"
jack_connect system:capture_1 system:playback_1 || echo "error connecting audio (4)"
jack_connect system:capture_1 system:playback_2 || echo "error connecting audio (5)"


# connect USB Midi to Sooperlooper, if it is found
midi_in=`aconnect -i | grep -m1 'RtMidiOut Client' | awk '{print $2}'`
midi_out=`aconnect -o | grep -m1 'sooperlooper' | awk '{print $2}'`
echo $midi_in
echo $midi_out
if [ -z "$midi_in" ]
then
      echo "No Midi found"
else
      echo "Connecting USB Midi to Sooperlooper"
      aconnect $midi_in:0 $midi_out:0
fi
