define _AWR_TOPSEG_DESCRIPTION="Direct Physical Writes"
define _AWR_TOPSEG_COLUMN="physical_writes_direct_delta"
define _AWR_TOPSEG_STAT_NAME="physical writes direct"
@topseg_helper_sysstat-&_REPO_TYPE &1 &2
