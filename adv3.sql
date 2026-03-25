SELECT shared_pool_size_for_estimate AS "Pool Size (MB)",
       shared_pool_size_factor AS "Size Factor",
       estd_lc_time_saved AS "Est. Time Saved (sec)"
FROM v$shared_pool_advice;