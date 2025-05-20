
PROMP ********************************************************************************
PROMP Segment Statistics in AWR
PROMP By Maicon Carneiro (dibiei.blog)
PROMP ********************************************************************************
PROMP 
PROMP Syntax:
PROMP @script <OWNER_NAME> <TABLE_NAME> <QT. DAYS>
PROMP
PROMP Example:
PROMP @hsegbusy SOE CUSTOMERS 30
PROMP

PROMP Segment Stats - Logical Reads .................: @hseglr
PROMP Segment Stats - Physical Reads ................: @hsegpr
PROMP Segment Stats - Physical Reads Requests........: @hsegprr
PROMP Segment Stats - UnOptimized Reads..............: TODO
PROMP Segment Stats - Optimized Reads................: TODO
PROMP Segment Stats - Direct Physical Reads .........: @hsegdpr
PROMP Segment Stats - Physical Writes ...............: @hsegpw
PROMP Segment Stats - Physical Write Requests .......: @hsegpwr
PROMP Segment Stats - Direct Physical Writes ........: @hsegdpw
PROMP Segment Stats - Table Scans ...................: @hsegscan
PROMP Segment Stats - Database Block Changes ........: @hsegbch
PROMP Segment Stats - Row Lock Waits ................: @hseglock
PROMP Segment Stats - ITL Waits .....................: @hsegitl
PROMP Segment Stats - Buffer Busy Waits .............: @hsegbusy

PROMP