#!/bin/bash

for i in {0..255} ; do printf "\t\x1b[38;5;${i}mcolour${i}\x1b[0m\n"; done

printf '\e[0m\n'
printf '\n'

for i in {0..255} ; do printf "\t\x1b[48;5;${i}mcolour${i}\x1b[0m\n"; done

printf '\e[0m\n'
printf '\n'
printf '\n\t'

for i in {0..255}; do printf '\e[48;5;%dm%3d ' $i $i; (((i+3) % 18)) || printf '\e[0m\n\t'; done

printf '\e[0m\n'
printf '\n\t'

for i in {0..255}; do printf '\e[38;5;%dm%3d ' $i $i; (((i+3) % 18)) || printf '\e[0m\n\t'; done

printf '\n'
