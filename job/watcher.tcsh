#!/bin/tcsh -f

set eojfile = /home/pcuser/job/frontjob.end
set lock    = /home/pcuser/job/mainjob.lock
set script  = /home/pcuser/job/mainjob.tcsh

while (1)
    if ( -f $eojfile ) then
        lockf -s -t 0 $lock $script start
    endif
    sleep 5
end
