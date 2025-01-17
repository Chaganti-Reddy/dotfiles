#!/bin/bash

hour=$(date +%H)
if [ $hour -ge 5 ] && [ $hour -lt 12 ]; then
    greeting="Good Morning"
elif [ $hour -ge 12 ] && [ $hour -lt 18 ]; then
    greeting="Good Afternoon"
else
    greeting="Good Evening"
fi

# Dynamic tooltip output
text="Dynamic Greeting"
tooltip="${greeting}, $USER\n\nMorning: DSA\nAfternoon: Kubernetes\nEvening: Deep Learning"

# Output JSON-like string
echo "{\"text\":\"${text}\", \"tooltip\":\"${tooltip}\"}"
