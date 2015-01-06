#!/bin/sh
#       script untuk update uptime dan temperature kepada satu baris tulisan
#       untuk dibaca oleh aprx 2.7
#       9M2PJU (2013)

#mula-mula delete existing files
rm -rf beacon* && rm -rf temp* && rm -rf uptime*

#lepas tu buat file temperature dengan uptime
uptime > uptime.txt 
#&& acpi -t > temp.txt

#"allign" semua output temperature kepada single line
#sed 'N;s/\n/ /' temp.txt > temp2.txt

#masukkan nilai latlong, uptime dan temperature kepada satu temporary beacon file
cat /root/latlong.txt >> /root/beacon.txt && cat uptime.txt >> /root/beacon.txt 
#&& cat temp2.txt >> /root/beacon.txt

#tulis nilai uptime kepada satu line
awk 'NR%2{printf $0" ";next;}1' /root/beacon.txt > /root/beacon2.txt

#allignment nilai temperature kepada satu line
#sed 'N;s/\n/ /' beacon2.txt > beacon3.txt

#/usr/bin/perl -lape 's/\s+//sg' output2 > output3
#sed 's/up/ up/g' /root/output2 > /root/output3
#sed 's/,/ /g' /root/output3 > /root/output4
