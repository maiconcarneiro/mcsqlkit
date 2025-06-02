define _AWR_TOPSEG_DESCRIPTION="Physical Write Requests"
define _AWR_TOPSEG_COLUMN="physical_write_requests_delta"
define _AWR_TOPSEG_STAT_NAME="physical write IO requests"
@topseg_helper_sysstat-&_REPO_TYPE &1 &2
