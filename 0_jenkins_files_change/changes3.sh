#!/auto/videoscape/cisco/ats5.2.0/bin/tclsh
package require Tclx

set path "/users/aavella/.jenkins/jobs/cvsjob2/builds"
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
puts "checking in $fn/changelog.xml"

if { [catch {exec grep name $fn/changelog.xml}] } {
    puts "There were no changes"
    exit 0
} else {
    set output [exec grep name $fn/changelog.xml]
}

#puts "Output -$output-"

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


#
# Find the test cases that we need to run for each file that has changed
#
puts "\nThe following files have changed"
for {set j 0} {$j < $i} {incr j } {
    puts "$arr_files_changed($j)"
    set file_id_3 [open "/users/aavella/jenkins/mapping/$arr_files_changed($j)" r]
    set file_data [read -nonewline $file_id_3]
    close $file_id_3
    set data [split $file_data "\n"]
    foreach line $data {
        lappend testcases $line
    }
    puts "Cumulative List of Test Cases: $testcases"
}

#
# Find unique list of test cases
#
set unique_tc [lrmdups $testcases]
puts "\nUnique Test Cases: $unique_tc"

set tc_string " -testcases="
foreach tc $unique_tc {
    append tc_string "$tc\\ "
}

#
# Create command dynamically
#
set command "#!/bin/sh
/auto/videoscape/cisco/vsats/cgi-bin/MOS2.0/L2/ads.pl -user=aavella -tims=0 -testbed=0 -confirmed=1 -testtype=0 -f0=1 -f12=1 -totaltesttime=380"
append command $tc_string
exec echo $command > $test_script
puts "\nCOMMAND: $command"
