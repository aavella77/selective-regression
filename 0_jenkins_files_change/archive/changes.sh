#!/usr/bin/tclsh

#puts "The following files have change in this commit"
set output [exec grep name /users/aavella/jenkins/changelog-mod.xml]
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
puts "\nThe following files have changed"
foreach line $data {
    # This is what we are trying to parse
    # <name><![CDATA[aavella/HelloWorld.java]]></name>
    regexp {<!\[CDATA\[(.*?)\]\]>} $line -> file
    puts "    $file"
}
