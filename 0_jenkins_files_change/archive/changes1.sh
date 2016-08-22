#!/usr/bin/tclsh

set path "/users/aavella/.jenkins/jobs/cvsjob/builds"
set test_script "/auto/Arroyo/automation/mpd/template/2.0/scripts/schedule_test.sh"

if {![catch {glob -type d -path $path/ *} folders]} {
    foreach fn $folders {
        #find all the folders and get the last one in fn
        # puts $fn
    }
}

#puts "The following files have change in this commit"
set output [exec grep name $fn/changelog.xml]
#puts $output

# Writing changes to a temporary file
set filename "files_changed.txt"
set file_id [open $filename "w"]
puts -nonewline $file_id $output
close $file_id

set file_id_2 [open "$filename" r]
set file_data [read $file_id_2]
close $file_id_2

set data [split $file_data "\n"]
set i 0
foreach line $data {
    # This is what we are trying to parse
    # <name><![CDATA[aavella/HelloWorld.java]]></name>
    regexp {<name><!\[CDATA\[(.*?)\]\]>} $line -> file
    #puts "    $file"
    set arr_files_changed($i) $file 
    incr i
}


puts "\nThe following files have changed"
for {set j 0} {$j < $i} {incr j } {
    puts "$arr_files_changed($j)"
}

