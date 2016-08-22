#!/usr/bin/tclsh

set path "/users/aavella/.jenkins/jobs/cvsjob/builds"
set test_script "/auto/Arroyo/automation/mpd/template/2.0/scripts/schedule_test.sh"

#
# Find the last build folder in Jenkins
#
if {![catch {glob -type d -path $path/ *} folders]} {
    foreach fn $folders {
        #puts $fn
    }
}

#
# Analyze changes in changelog.xml
#
set output [exec grep name $fn/changelog.xml]
#puts $output

#
# Writing changes to a temporary file
#
set filename "files_changed.txt"
set file_id [open $filename "w"]
puts -nonewline $file_id $output
close $file_id

#
# Open file with changes
#
set file_id_2 [open "$filename" r]
set file_data [read $file_id_2]
close $file_id_2

#
# Each file changed is a line
#
set data [split $file_data "\n"]
set i 0
foreach line $data {
    #
    # This is what we are trying to parse
    # <name><![CDATA[aavella/HelloWorld.java]]></name>
    #
    regexp {<name><!\[CDATA\[(.*?)\]\]>} $line -> file
    #puts "    $file"
    regsub -all "aavella/" $file "" file
    set arr_files_changed($i) $file 
    incr i
}


puts "\nThe following files have changed"
for {set j 0} {$j < $i} {incr j } {
    puts "$arr_files_changed($j)"
    set file_id_3 [open "/users/aavella/jenkins/mapping/$arr_files_changed($j)" r]
    set file_data [read $file_id_3]
    close $file_id_3
    set data [split $file_data "\n"]
    set first 1
    foreach line $data {
        if {$first} {
            set testcases " -testcases=$line"
        } else {
            append testcases "\\ $line"
        }
        set first 0
    }
    puts "   $testcases"
}

#
# Create command dynamically
#
set command "#!/bin/sh
/auto/videoscape/cisco/vsats/cgi-bin/MOS2.0/L2/ads.pl -user=aavella -tims=0 -testbed=0 -confirmed=1 -testtype=0 -f0=1 -f12=1 -totaltesttime=380"
append command $testcases
exec echo $command > $test_script
