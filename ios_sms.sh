#!/bin/bash
# REVISION 2 OCT 2013.  
# CREATES TRANSCRIPT OF TEXTS BACKED UP FROM AN IPHONE SYNC TO ITUNES WITH 
# ROBUST AUTOMATION OF NAME AND THREAD LABELING.
#
# Final corrections arrived at through test_array02.sh 
#
#
#
# Print auxilliary documents
sqlite3 sms.db .dump > sms.db.txt
sqlite3 -header sms.db "select * from handle" > phoneIDs.txt
#
#
# Store date and time in filename to avoid accidental overwrites when dealing
# with multiple transcripts for journal storage.
#####
time=`date +%Y%m%d_%H%M%S`
#
#
# Create transcript with coded identity of sender and thread id 
#  using as-is sms.db data.
# A discussion of the meaning of these codes is not included here but can be
# found in the comments of the rough drafts and planning documents.
#####
sqlite3 -header sms.db "select datetime(date+978307200, 'unixepoch','localtime') as date, handle_id as sender, is_from_me as 'NAME3?', type as 'Group?', service as service, text as message from message" > smsdata
#
#
# Set up a table to match handle_id data from sms.db to phone numbers.
#####
n=$(sqlite3 sms.db "select count(*) from handle")
declare -a a
declare -a b
for (( i=0; i<n; i++ ))
do
 a[$i]=$(sqlite3 sms.db "select ROWID from handle limit 1 offset $i")
 b[$i]=$(sqlite3 sms.db "select id from handle limit 1 offset $i")
done
#
#
# Replace phone numbers with matching names in the table.
#####
for (( i=0; i<n; i++ ))
do
 if [ ${b[$i]} == +15555555555 ] ; then b[$i]=NAME1 ; fi
 if [ ${b[$i]} == +15555555555 ] ; then b[$i]=NAME2 ; fi
 if [ ${b[$i]} == +15555555555 ] ; then b[$i]=NAME3 ; fi
done 
#
#
#
# Now run a series of sed find and replace scripts to change coded labels to 
# true name and thread labels.  Much better to let sed operate on the text than
# it is to try to model all the logic necessary to label within sqlite3 
# command parameters.
#
#
# Remove column headings I won't need in the name-labeled final product.
#####
sed -e 's/NAME3?|Group?|//' -e 's/0|1|0|/NAME3|Group/' smsdata > txtmsg
#
#
# Find all occurrences of handle numbers, replace them with matching name.
#####
for (( j=0; j<n; j++ ))
do
  sed -i _bak "s/${a[$j]}/${b[$j]}/" txtmsg
done
#
#
# Remove last bits of raw data and finish with proper name labels 
#####
sed -e 's/NAME3|.|.|/NAME3|Self-/' -e 's/NAME1|1|0|/NAME3|NAME1-NAME3 /' -e 's/NAME1|0|0|/NAME1|NAME1-NAME3 /' -e 's/NAME1|0|1|/NAME1|Group/' -e 's/NAME2|1|./NAME3/' -e 's/NAME2|0|0/NAME2/' -e 's/NAME2|0|1|/NAME2|Group/' -e 's/NAME2|SMS/NAME2|GroupSMS/' txtmsg > SMS_iMsg_$time
#
#
# No more rm command.  We're keeping the intermediate processing and backup for reference.
#
#
