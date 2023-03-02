select
  null ic, null name, null recommendation, null flags, null remark,
  null note, null should_be_value, null is_value, null is_set,
  null "ID", null inst_id, null note_hyperlink from dual where 1 = 0
union all (
select
  null ic, null name, null recommendation, null flags, null remark,
  null note, null should_be_value, null is_value, null is_set,
  null "ID", null inst_id, null note_hyperlink from dual where 1 = 0
) union all ( select * from (
with BASIS_INFO as
( select /*+MATERIALIZE*/
    decode(substr(upper(is_olap),1,1),
      'N','N','Y','Y','?') is_olap,
    decode(substr(sim_release_bundle,1,1),
      '<','',
      substr(trim(sim_release_bundle),1,2)) sim_release,
    decode(substr(sim_release_bundle,1,1),
      '<','',
      replace(substr(trim(sim_release_bundle),4,2),'.','')) sim_bundle,
    platform_name sim_os,
    decode(instr('YN',upper(substr(sim_abap,1,1))),0,'',
      upper(substr(sim_abap,1,1))) sim_abap,
    decode(instr('YN',upper(substr(sim_rac,1,1))),0,'',
      upper(substr(sim_rac,1,1))) sim_rac,
    decode(instr('YN',upper(substr(sim_oes,1,1))),0,'',
      upper(substr(sim_oes,1,1))) sim_oes,
    decode(instr('YN',upper(substr(sim_asm,1,1))),0,'',
      upper(substr(sim_asm,1,1))) sim_asm,
    decode(substr(upper(is_ldt),1,1),
      'N','N','Y','Y','?') is_ldt,
    decode(substr(upper(is_lac),1,1),
      'N','N','Y','Y','?') is_lac,
    decode(substr(upper(is_las),1,1),
      'N','N','Y','Y','?') is_las,
    decode(substr(upper(is_lim),1,1),
      'N','N','Y','Y','?') is_lim,
    decode(substr(upper(is_lmt),1,1),
      'N','N','Y','Y','?') is_lmt,
    decode(substr(upper(is_ldv),1,1),
      'N','N','Y','Y','?') is_ldv
  from
  ( select
        '<OLAP System? [?]>' is_olap,
        '<Licensed Diagnostic/Tuning Pack [?]>' is_ldt,
        '<Licensed Advanced Compression? [?]>' is_lac,
        '<Licensed Advanced Security Option [?]>' is_las,
        '<Licensed Database In-Memory [?]>' is_lim,
        '<Licensed Multitenant Option [?]>' is_lmt,
        '<Licensed DB Vault [?]>' is_ldv,
        '<Simulate Release.Bundle []>' sim_release_bundle,
        '<Simulate OS []>' sim_os,
        '<Simulate ABAP []>' sim_abap,
        '<Simulate RAC []>' sim_rac,
        '<Simulate ASM []>' sim_asm,
        '<Simulate OES []>' sim_oes
    from
      dual
  ),
    v$transportable_platform
  where
    sim_os=platform_name(+)
),
MaintInfo as
( select
     '18/2470718/40 '||
     '19/2470718/40 ' NoteVersion,
     '2020-07-07' LastChanged
   from
     dual
),
MaintShouldRaw as
( select /*+MATERIALIZE*/ val from
  ( select '###PS[0]###' val from dual union all ( select '#'
||'*** 1#####'
||'*** 2#####'
||'*** 3#####'
||'*** 4#####'
||'*** 5#####'
||'*** 6#####'
||'*** 7#####'
||'*** 8#####'
||'*** 9#####'
||'*** 10#####'
||'*** 11#####'
||'*** 12#####'
||'*** 13#####'
||'*** 14#####'
||'*** 15#####'
||'*** 16#####'
||'_ADVANCED_INDEX_COMPRESSION_OPTIONS#16#LAC[T]#2f#'
  ||'use low advanced index compress for rebuild/create note 2500176#'
||'_ADVANCED_INDEX_COMPRESSION_OPTIONS#'
  ||'-man-set to 16 if advanced compression is licensed, otherwise do not set#'
  ||'LAC[?]#1f#'
  ||'use low advanced index compress for rebuild/create note 2500176#'
||'_DISABLE_DIRECTORY_LINK_CHECK#TRUE#REL[1819]#2f#'
  ||'required for patching (catsbp) note 2660027#'
||'_ENABLE_NUMA_SUPPORT#'
  ||'-man-set optionally to TRUE after successful NUMA test##2p#'
  ||'Oracle Support Document 864633.1#'
||'_ENABLE_PTIME_UP'||'DATE_FOR_SYS#TRUE#OSF[U]REL[18]FIX[7-]:'
  ||'OSF[W]REL[18]FIX[9-]:OSF[U]REL[19]FIX[4-]:OSF[W]REL[19]FIX[6-]#'
  ||'2f#Influences expiry date of SYS user note 2860512#'
||'_FIX_CONTROL,5099019#5099019:ON##2p#'
  ||'dbms_stats counts leaf blocks correctly#'
||'_FIX_CONTROL,6055658#6055658:OFF##2p#'
  ||'calculate correct join card. with histograms#'
||'_FIX_CONTROL,6120483#6120483:OFF##2p#'
  ||'avoid using wrong plan for simple queries#'
||'_FIX_CONTROL,6399597#6399597:ON##2p#'
  ||'sort group by instead of hash group by note 176754#'
||'_FIX_CONTROL,6430500#6430500:ON##2p#avoid not using unique index#'
||'_FIX_CONTROL,6972291#6972291:ON##2p#'
  ||'use column group selectivity with hgrm note 1165319#'
||'_FIX_CONTROL,7324224#7324224:OFF##2f#'
  ||'remove predicates that are redundant because of subtrees#'
||'_FIX_CONTROL,7658097#7658097:ON##2p#'
  ||'temp. workaround for Oracle Bug 19875411; reduce parse#'
val from dual ) union all ( select '#'
||'_FIX_CONTROL,8932139#8932139:ON#REL[1819]#2f#'
  ||'use PGA for bloom filter with broadcast#'
||'_FIX_CONTROL,8937971#8937971:ON##2f#'
  ||'correct clause definition dbms_metadata.get_ddl#'
||'_FIX_CONTROL,9196440#9196440:ON##2p#'
  ||'fixes low distinct keys in index stats#'
||'_FIX_CONTROL,9495669#9495669:ON##2p#'
  ||'disable histogram use for join cardinality#'
||'_FIX_CONTROL,13627489#13627489:ON##2p#'
  ||'use good access for merge in dbms_redefinition#'
||'_FIX_CONTROL,14255600#14255600:ON##2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14595273#14595273:ON##2p#'
  ||'avoid non-optimal star transformation#'
||'_FIX_CONTROL,18405517#18405517:2##2p##'
||'_FIX_CONTROL,20355502#20355502:10##2p#'
  ||'reduces parse time with OR-expansion note 2698967#'
||'_FIX_CONTROL,20636003#20636003:OFF##2p#'
  ||'disable dyn. Samp. to est. row count#'
||'_FIX_CONTROL,22540411#22540411:ON##2p#'
  ||'use hash group by with sort for aggregation#'
||'_FIX_CONTROL,23738304#23738304:OFF#LIM[F]REL[1819]#2p#'
  ||'Improvement of group by placement#'
||'_FIX_CONTROL,23738304#'
  ||'-man-set to 23738304:OFF if In-Memory is not used; otherwise do not set#'
  ||'LIM[?]REL[1819]#2p#Improvement of group by placement#'
||'_FIX_CONTROL,25643889#25643889:ON##2f#'
  ||'query returns ora-00979 but should work#'
||'_FIX_CONTROL,26423085#26423085:ON#REL[18]FIX[6-]#2p##'
||'_FIX_CONTROL,26536320#26536320:ON#REL[1819]#2p#'
  ||'disallow HASH GROUP BY for WiF+uncor. select list subquery#'
||'_FIX_CONTROL,27321179#27321179:ON#REL[1819]#2p#'
  ||'LORE: consider only valid OR-chains for DNF note 2698967#'
||'_FIX_CONTROL,27343844#27343844:ON#OSF[U]REL[18]FIX[8-9]#2p#'
  ||'Allow JPPD on query blocks with Key Vector Use operators#'
val from dual ) union all ( select '#'
||'_FIX_CONTROL,27466597#27466597:ON#REL[1819]#2p#'
  ||'avoid index skip scan usage note 2395585#'
||'_FIX_CONTROL,28072567#28072567:ON#REL[18]FIX[6-]#2p##'
||'_FIX_CONTROL,28558645#28558645:ON#OSF[U]REL[18]:'
  ||'OSF[W]REL[18]FIX[9-]:REL[19]#2p#'
  ||'fix bad vector group by cardinality estimate with a joined fact#'
||'_FIX_CONTROL,28602253#28602253:ON#OSF[U]REL[18]FIX[8-]:'
  ||'OSF[U]REL[19]#2p#Simplification of multiple OR conditions#'
||'_FIX_CONTROL,28835937#28835937:ON#OSF[U]REL[18]:'
  ||'OSF[W]REL[18]FIX[10-]:REL[19]#2p#'
  ||'before calculating multi-parents ensure cardinality>NDV#'
||'_FIX_CONTROL,29450812#29450812:ON#OSF[U]REL[18]FIX[7-]:'
  ||'OSF[W]REL[18]FIX[9-]:REL[19]#2p#'
  ||'allow legacy ORE for exotic query constructs note 2806210#'
||'_FIX_CONTROL,29687220#29687220:ON#OSF[U]REL[18]FIX[9-]:'
  ||'OSF[W]REL[18]FIX[10-]:OSF[U]REL[19]FIX[6-]:OSF[W]REL[19]FIX[7-]#'
  ||'2p#Improve costing for indexes with empty statistics#'
||'_FIX_CONTROL,29930457#29930457:ON#OSF[U]REL[19]FIX[7-]#2p#'
  ||'Restrict _b_tree_bitmap_plans to single table access paths#'
||'_IPDDB_ENABLE#-del-####'
||'_IN_MEMORY_UNDO#FALSE#REL[18]FIX[-5]RAC[F]#1f#'
  ||'avoids potential not recoverable DB note 2812178#'
||'_KOLFUSESLF#TRUE#REL[1819]#2f#'
  ||'required for patching (catsbp) note 2660027#'
||'_LOG_SEGMENT_DUMP_PARAMETER#FALSE##2f#'
  ||'avoid dump of alertlog information as after a DB restart#'
||'_LOG_SEGMENT_DUMP_PATCH#FALSE##2f#'
  ||'avoid dump of alertlog information as after a DB restart#'
||'_MIN_LWT_LT#4#BW[T]REL[19]LIM[T]#2p#'
  ||'improve perf with flat cubes note 2335159#'
||'_MIN_LWT_LT#'
  ||'-man-set to 4 if In-Memory is licensed; otherwise do not set#'
  ||'BW[T]REL[19]LIM[?]#2p#improve perf with flat cubes note 2335159#'
val from dual ) union all ( select '#'
||'_MIN_LWT_LT#-man-set to 4 on OLAP systems, otherwise do not set#'
  ||'BW[?]REL[19]LIM[T]#2p#improve perf with flat cubes note 2335159#'
||'_MIN_LWT_LT#'
  ||'-man-set to 4 on OLAP systems, if In-Memory is licensed; otherwise do not set#'
  ||'BW[?]REL[19]LIM[?]#2p#improve perf with flat cubes note 2335159#'
||'_MUTEX_WAIT_SCHEME#1##2p#controls mutex spins/waits note 1588876#'
||'_MUTEX_WAIT_TIME#10##2p#controls mutex spins/waits note 1588876#'
||'_OLTP_COMPRESS_DBG#1#OSF[U]REL[18]FIX[9-9]#1f#'
  ||'avoid corruptions on compressed tables note 2719005#'
||'_OPTIM_PEEK_USER_BINDS#FALSE##1p#avoid bind value peeking#'
||'_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#FALSE##2p##'
||'_OPTIMIZER_CBQT_OR_EXPANSION#OFF#OSF[U]REL[18]FIX[-6]:'
  ||'OSF[W]REL[18]#2p#allow old Or concat note 2806210#'
||'_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#NONE##2p##'
||'_OPTIMIZER_GATHER_STATS_ON_CONVENTIONAL_DML#'
  ||'-man-set to FALSE on Exadata, otherwise do not set#OSF[U]OES[T]:'
  ||'OSF[U]OES[?]#2p#Disable real time statistics#'
||'_OPTIMIZER_REDUCE_GROUPBY_KEY#FALSE##1f#'
  ||'avoid wrong values with group by note 2258559#'
||'_OPTIMIZER_USE_FEEDBACK#FALSE##2p##'
||'_OPTIMIZER_USE_STATS_ON_CONVENTIONAL_DML#'
  ||'-man-set to FALSE on Exadata, otherwise do not set#OSF[U]OES[T]:'
  ||'OSF[U]OES[?]#2p#Disable real time statistics#'
||'_PARTIAL_COMP_ENABLED#FALSE#OSF[U]REL[18]FIX[-8]:OSF[W]REL[18]:'
  ||'REL[19]#1f#avoid corruptions note 2780131#'
||'_PX_NUMA_SUPPORT_ENABLED#'
  ||'-man-set optionally to TRUE after successful NUMA test##2p##'
||'_ROWSETS_ENABLED#FALSE#REL[18]:REL[19]BW[F]:REL[19]BW[T]LIM[F]:'
  ||'REL[19]BW[?]LIM[F]#2p#improve perf with flat cubes note 2335159#'
val from dual ) union all ( select '#'
||'_ROWSETS_ENABLED#TRUE#REL[19]BW[T]LIM[T]#2p#'
  ||'improve perf with flat cubes note 2335159#'
||'_ROWSETS_ENABLED#'
  ||'-man-set to TRUE on OLAP systems; otherwise set to FALSE#'
  ||'REL[19]BW[?]LIM[T]#2p#improve perf with flat cubes note 2335159#'
||'_ROWSETS_ENABLED#'
  ||'-man-set to TRUE if In-Memory is licensed; otherwise set to FALSE#'
  ||'REL[19]BW[T]LIM[?]#2p#improve perf with flat cubes note 2335159#'
||'_ROWSETS_ENABLED#'
  ||'-man-set to TRUE on OLAP systems if In-Memory is licensed; otherwise set to FALSE#'
  ||'REL[19]BW[?]LIM[?]#2p#improve perf with flat cubes note 2335159#'
||'_SECUREFILES_CONCURRENCY_ESTIMATE#50##2p#'
  ||'Avoids bbw (free list) and enq waits during LOB inserts note 1887235#'
||'_SPACEBG_SYNC_SEGBLOCKS#TRUE###'
  ||'replaces _BUG12963364_SPACEBG_SYNC_SEGBLOCKS#'
||'_SUPPRESS_IDENTIFIERS_ON_DUPKEY#TRUE####'
||'_USE_SINGLE_LOG_WRITER#TRUE###Oracle Support Document E91957710.1#'
||'AUDIT_FILE_DEST#/oracle/[SID]/saptrace/audit#OSF[U]###'
||'AUDIT_FILE_DEST#[DRIVE]:\oracle\[SID]\saptrace\audit#OSF[W]###'
||'AUDIT_SYS_OPERATIONS#TRUE#LDV[T]###'
||'AUDIT_SYS_OPERATIONS#'
  ||'-man-set to TRUE if DB vault is licensed, otherwise do not set#'
  ||'LDV[?]###'
||'BACKGROUND_DUMP_DEST#-del-####'
||'CLUSTER_DATABASE#TRUE#RAC[T]###'
||'CLUSTER_DATABASE_INSTANCES#-man-set to number of RAC instances#'
  ||'RAC[T]###'
||'COMMIT_LOGGING#-del-##1f##'
||'COMMIT_WAIT#-del-##1f##'
||'COMMIT_WRITE#-del-##1f##'
||'COMPATIBLE#18.0.0#REL[18]#1f#note 1739274#'
||'COMPATIBLE#19.0.0#REL[19]#1f#note 1739274#'
||'CONTROL_FILE_RECORD_KEEP_TIME#>=30####'
||'CONTROL_FILES#-man-at least three copies on different disk areas#'
  ||'OES[F]###'
val from dual ) union all ( select '#'
||'CONTROL_FILES#-man-two copies on different disk areas#OES[T]###'
||'CONTROL_MANAGEMENT_PACK_ACCESS#DIAGNOSTIC+TUNING#LDT[T]###'
||'CONTROL_MANAGEMENT_PACK_ACCESS#'
  ||'-man-set to DIAGNOSTIC+TUNING if both packs are licensed#LDT[?]##'
  ||'#'
||'CORE_DUMP_DEST#-del-####'
||'DB_BLOCK_SIZE#8192####'
||'DB_CACHE_SIZE#-man-appropriately set###note 789011, note 617416#'
||'DB_CREATE_FILE_DEST#+DATA#ASM[T]###'
||'DB_CREATE_ONLINE_LOG_DEST_1#+DATA#ASM[T]###'
||'DB_CREATE_ONLINE_LOG_DEST_2#+RECO#ASM[T]OES[F]###'
||'DB_CREATE_ONLINE_LOG_DEST_2#'
  ||'-man-set to +RECO, except for OES with high redundancy +DATA: do not configure/set#'
  ||'ASM[T]OES[T]###'
||'DB_FILE_MULTIBLOCK_READ_COUNT#-del-##1p##'
||'DB_FILES#'
  ||'-man-set larger than number of short term expected datafiles####'
||'DB_NAME#[SID]####'
||'DB_RECOVERY_FILE_DEST#+RECO#ASM[T]###'
||'DIAGNOSTIC_DEST#/oracle/[SID]/saptrace#OSF[U]###'
||'DIAGNOSTIC_DEST#[DRIVE]:\oracle\[SID]\saptrace#OSF[W]###'
||'DISK_ASYNCH_IO#'
  ||'-man-set to FALSE with standard filesystem (not on OnlineJFS; note 798194)#'
  ||'OS[HP-UX IA (64-bit),HP-UX (64-bit)], ASM[F]##'
  ||'note 2799946, note 798194#'
||'ENABLE_PLUGGABLE_DATABASE#'
  ||'-man-set to TRUE if at least one PDB is used, otherwise do not set#'
  ||'LMT[T]###'
||'ENABLE_PLUGGABLE_DATABASE#'
  ||'-man-set to TRUE if 1 PDB (with MULTITENANT license: >=1) is used, otherwise do not set#'
  ||'LMT[?]###'
||'ENABLE_PLUGGABLE_DATABASE#'
  ||'-man-set to TRUE if exactly one plugable DB is used, otherwise do not set#'
  ||'LMT[F]###'
||'EVENT,10027#10027##2f#'
  ||'avoid process state dump at deadlock note 596420#'
||'EVENT,10028#10028##2f#'
  ||'do not wait for writing deadlock trace note 596420#'
val from dual ) union all ( select '#'
||'EVENT,10142#10142##2p#'
  ||'avoid btree bitmap conversion plans note 1284478#'
||'EVENT,10183#10183##1p#'
  ||'avoid rounding during cost calculation note 128648#'
||'EVENT,10191#10191##2f#'
  ||'avoid high CBO memory consumption note 128221#'
||'EVENT,10995#10995 level 2##2f#'
  ||'avoid flush shared pool at online reorg note 1565421#'
||'EVENT,38068#38068 level 100##2p#'
  ||'no rule based access if first ind col with range note 176754#'
||'EVENT,38085#38085##2p#'
  ||'consider cost adjust for index fast full scan note 176754#'
||'EVENT,38087#38087##2p#'
  ||'calc long raw statistic correctly note 948197#'
||'EVENT,44951#44951 level 1024##2p#'
  ||'avoid HW enqueues during LOB inserts note 1166242#'
||'EVENT,60025#60025##2f#'
  ||'allows drop of temp TS with temp LOBs note 2393275#'
||'FILESYSTEMIO_OPTIONS#SETALL##1p#note 793113#'
||'HEAT_MAP#-man-set to "on" if ADO/ILM is used, otherwise do not set#'
  ||'LAC[T]#2f#note 2254866#'
||'HEAT_MAP#'
  ||'-man-set to "on" if advanced compression is licensed and ADO/ILM is used, otherwise do not set#'
  ||'LAC[?]#2f#note 2254866#'
||'HPUX_SCHED_NOAGE#178#RAC[F]#2p#performance#'
||'INMEMORY_CLAUSE_DEFAULT#PRIORITY HIGH DUPLICATE ALL#LIM[T]OES[T]##'
  ||'note 2178980#'
||'INMEMORY_CLAUSE_DEFAULT#PRIORITY HIGH#LIM[T]OES[F]##note 2178980#'
||'INMEMORY_CLAUSE_DEFAULT#'
  ||'-man-set to PRIORITY HIGH  DUPLICATE ALL if In-Memory option is licensed, otherwise do not set#'
  ||'LIM[?]OES[T]##note 2178980#'
||'INMEMORY_CLAUSE_DEFAULT#'
  ||'-man-set to PRIORITY HIGH if In-Memory option is licensed, otherwise do not set#'
  ||'LIM[?]OES[F]##note 2178980#'
||'INMEMORY_MAX_POPULATE_SERVERS#4#LIM[T]##note 2178980#'
val from dual ) union all ( select '#'
||'INMEMORY_MAX_POPULATE_SERVERS#'
  ||'-man-set to 4 if In-Memory option is licensed, otherwise do not set#'
  ||'LIM[?]##note 2178980#'
||'INMEMORY_SIZE#-man-appropriately set; details in note 2178980#'
  ||'LIM[T]##note 2178980#'
||'INMEMORY_SIZE#'
  ||'-man-set appropriately if In-Memory option is licensed; details in note 2178980#'
  ||'LIM[?]##note 2178980#'
||'INSTANCE_NAME#-man-set to [SID][Instance Number]#RAC[T]###'
||'INSTANCE_NUMBER#-man-set to 3 digit numeric value#RAC[T]###'
||'LOCAL_LISTENER#'
  ||'-man-set to (ADDRESS = (PROTOCOL=TCP) (HOST=[hostname]>) (PORT=[port]))#'
  ||'RAC[F]###'
||'LOCAL_LISTENER#'
  ||'-man-set to (ADDRESS = (PROTOCOL=TCP) (HOST=[hostname_vip]>) (PORT=1521))#'
  ||'RAC[T]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=+[DGNAME]/[SID]/oraarch#ASM[T]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=/oracle/[SID]/oraarch/[SID]arch#'
  ||'OSF[U]ASM[F]##note 966073#'
||'LOG_ARCHIVE_DEST_1#'
  ||'LOCATION=[drive]:\oracle\[SID]\oraarch\[SID]arch#OSF[W]ASM[F]##'
  ||'note 966073#'
||'LOG_ARCHIVE_FORMAT#%t_%s_%r.dbf####'
||'LOG_BUFFER#-man-depends on number of CPUs; details in note 1627481#'
  ||'OES[F]##CPU_COUNT=[CPU_COUNT] note 1627481#'
||'LOG_BUFFER#-man-set to at least 128MB; details in note 1627481#'
  ||'OES[T]##CPU_COUNT=[CPU_COUNT] note 1627481#'
||'LOG_CHECKPOINTS_TO_ALERT#TRUE####'
||'MAX_DUMP_FILE_SIZE#20000####'
||'MAX_PDBS#-man-set to 3 on container DB#REL[19]LMT[F]EPD[T]###'
||'MAX_PDBS#'
  ||'-man-set to 3 on container DB without multitenant license (with license even higher)#'
  ||'REL[19]LMT[?]EPD[T]###'
||'MAX_PDBS#-man-set to >=3 on container DB#REL[19]LMT[T]EPD[T]###'
||'NLS_LENGTH_SEMANTICS#-del-##2f##'
||'OPEN_CURSORS#between 800 and 2000####'
val from dual ) union all ( select '#'
||'OPTIMIZER_ADAPTIVE_FEATURES#-del-##2p#desupported in 12.2.0.1#'
||'OPTIMIZER_ADAPTIVE_PLANS#FALSE##2p#disable adaptive plans#'
||'OPTIMIZER_ADAPTIVE_STATISTICS#FALSE##2p#disable adaptive stats#'
||'OPTIMIZER_DYNAMIC_SAMPLING#-del-#BW[F]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#6#BW[T]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#'
  ||'-man-set to 6 on OLAP systems, on OLTP systems do not set#BW[?]#'
  ||'1p##'
||'OPTIMIZER_FEATURES_ENABLE#-del-##1p##'
||'OPTIMIZER_INDEX_CACHING#-del-##2p#'
  ||'est. % of index cached (inlist, nested loop)#'
||'OPTIMIZER_INDEX_COST_ADJ#20#BW[F]#1p##'
||'OPTIMIZER_INDEX_COST_ADJ#-del-#BW[T]#1p##'
||'OPTIMIZER_INDEX_COST_ADJ#'
  ||'-man--set to 20 on OLTP systems, on OLAP systems do not set#'
  ||'BW[?]###'
||'OPTIMIZER_MODE#-del-##1p##'
||'OS_AUTHENT_PREFIX#'
  ||'-man-set to CHashCharHashCharOPS$ on container DB only, otherwise do not set#'
  ||'###'
||'OS_ROLES#FALSE#LDV[T]###'
||'OS_ROLES#'
  ||'-man-set to FALSE if DB vault is licensed, otherwise do not set#'
  ||'LDV[?]###'
||'PARALLEL_EXECUTION_MESSAGE_SIZE#16384##2p##'
||'PARALLEL_MAX_SERVERS#'
  ||'-man-set to ten times the number of DB CPU cores (CPU_COUNT*10)##'
  ||'#CPU_COUNT=[CPU_COUNT]#'
||'PARALLEL_MIN_SERVERS#0####'
||'PARALLEL_THREADS_PER_CPU#1##2p##'
||'PGA_AGGREGATE_TARGET#'
  ||'-man-set to 20% of DB memory on OLTP; 40% on OLAP####'
||'PRE_PAGE_SGA#FALSE##2p#faster startup#'
||'PROCESSES#-man-formula how to set in parameter note###'
  ||'dependent: SESSIONS#'
||'QUERY_REWRITE_ENABLED#FALSE##2p##'
||'RECYCLEBIN#OFF##1f##'
||'REMOTE_LISTENER#-man-set to //[scan_name]:1521#RAC[T]###'
||'REMOTE_LOGIN_PASSWORDFILE#EXCLUSIVE#LDV[T]###'
||'REMOTE_LOGIN_PASSWORDFILE#'
  ||'-man-set to EXCLUSIVE if DB vault is licensed, otherwise do not set#'
  ||'LDV[?]###'
val from dual ) union all ( select '#'
||'REMOTE_OS_AUTHENT#-del-####'
||'REPLICATION_DEPENDENCY_TRACKING#-any-####'
||'SESSIONS#-man-2*PROCESSES###PROCESSES=[PROCESSES]#'
||'SERVICE_NAMES#-man-set to ([SID], [Instance Name])#RAC[T]###'
||'SHARED_POOL_SIZE#appropriately set; note 690241####'
||'STAR_TRANSFORMATION_ENABLED#-del-#BW[F]#1p##'
||'STAR_TRANSFORMATION_ENABLED#'
  ||'-man-set to TRUE on OLAP systems, otherwise do not set#BW[?]#1p##'
||'STAR_TRANSFORMATION_ENABLED#TRUE#BW[T]#1p##'
||'TDE_CONFIGURATION#''KEYSTORE_CONFIGURATION=FILE''#'
  ||'REL[1819]LAS[T]TDE[T]##note 2591575#'
||'TDE_CONFIGURATION#'
  ||'-man-set to ''KEYSTORE_CONFIGURATION=FILE'' with Adv. Sec. License, otherwise do not set#'
  ||'REL[1819]LAS[?]TDE[T]###'
||'THREAD#-man-set to instance_number value without leading zeros#'
  ||'RAC[T]###'
||'UNDO_RETENTION#-man-appropriately set####'
||'UNDO_TABLESPACE#PSAPUNDO#RAC[F]###'
||'UNDO_TABLESPACE#-man-set to PSAPUNDO[Instance Number]#RAC[T]###'
||'UNIFORM_LOG_TIMESTAMP_FORMAT#FALSE####'
||'USE_LARGE_PAGES#-man-can be set according to note 1672954#'
  ||'OS[Linux IA (64-bit),Linux x86 64-bit]###'
||'USER_DUMP_DEST#-del-####'
||'WALLET_ROOT#-man-set to TDE SW keystore location#'
  ||'REL[1819]LAS[T]TDE[T]##note 2591575#'
||'WALLET_ROOT#'
  ||'-man-set to TDE SW keystore location with Adv. Sec. License, otherwise do not set#'
  ||'REL[1819]LAS[?]TDE[T]##note 2591575#'
  val from dual ))
),
NumGen as
( select /*+MATERIALIZE*/
    rownum nr
  from
    v$parameter2
  where
    rownum <= 100
),
ShouldByLine as
( select /*+MATERIALIZE*/
    substr(val,instr(val,'#',1,r-4)+1,instr(val,'#',1,r-3)-instr(val,'#',1,r-4)-1) n,
    substr(val,instr(val,'#',1,r-3)+1,instr(val,'#',1,r-2)-instr(val,'#',1,r-3)-1) w,
    ':'||substr(val,instr(val,'#',1,r-2)+1,instr(val,'#',1,r-1)-instr(val,'#',1,r-2)-1)||':' r,
    substr(val,instr(val,'#',1,r-1)+1,instr(val,'#',1,r-0)-instr(val,'#',1,r-1)-1) p,
    substr(val,instr(val,'#',1,r-0)+1,instr(val,'#',1,r+1)-instr(val,'#',1,r-0)-1) c
  from
    MaintShouldRaw,
    ( select nr*5 r from NumGen )
  where
    val != '#' and
    substr(val,instr(val,'#',1,r-4)+1,
    instr(val,'#',1,r-3)-instr(val,'#',1,r-4)-1) is not null
),
ShouldOrByLine as
( select /*+MATERIALIZE*/
    decode(substr(n,1,4),'*** ','*** INFORMATION '||lpad(substr(n,5),2)||' ***',n) n,
    w,
    substr(r,instr(r,':',1,nr)+1,instr(r,':',1,nr+1)-instr(r,':',1,nr)-1) r,
    p,c
  from
    ShouldByLine,
    NumGen
  where
    substr(r,instr(r,':',1,nr)+1,instr(r,':',1,nr+1)-instr(r,':',1,nr)-1) is not null or
    nr=1
),
ShouldPerInstCondColsOrByLine as
( select
    inst_id,
    n,w,c,p,
    decode(instr(' '||r,'LDV[T]'),
      0,decode(instr(' '||r,'LDV[F]'),
        0,decode(instr(' '||r,'LDV[?]'),
          0,'','?'),'N'),'Y') r_ldv,
    decode(instr(' '||r,'LMT[T]'),
      0,decode(instr(' '||r,'LMT[F]'),
        0,decode(instr(' '||r,'LMT[?]'),
          0,'','?'),'N'),'Y') r_lmt,
    decode(instr(' '||r,'LIM[T]'),
      0,decode(instr(' '||r,'LIM[F]'),
        0,decode(instr(' '||r,'LIM[?]'),
          0,'','?'),'N'),'Y') r_lim,
    decode(instr(' '||r,'LDT[T]'),
      0,decode(instr(' '||r,'LDT[F]'),
        0,decode(instr(' '||r,'LDT[?]'),
          0,'','?'),'N'),'Y') r_ldt,
    decode(instr(' '||r,'LAC[T]'),
      0,decode(instr(' '||r,'LAC[F]'),
        0,decode(instr(' '||r,'LAC[?]'),
          0,'','?'),'N'),'Y') r_lac,
    decode(instr(' '||r,'LAS[T]'),
      0,decode(instr(' '||r,'LAS[F]'),
        0,decode(instr(' '||r,'LAS[?]'),
          0,'','?'),'N'),'Y') r_las,
    decode(instr(' '||r,'REL['),0,'',
      substr(r,instr(r,'REL[')+4,instr(r,']',
      instr(r,'REL['))-instr(r,'REL[')-4)) r_rel,
    decode(instr(' '||r,'FIX['),0,'',
      substr(r,instr(r,'FIX[')+4,instr(r,']',
      instr(r,'FIX['))-instr(r,'FIX[')-4)) r_fix,
    decode(instr(' '||r,'BW[T]'),
      0,decode(instr(' '||r,'BW[F]'),
        0,decode(instr(' '||r,'BW[?]'),
          0,'','?'),'N'),'Y') r_bw,
    decode(instr(' '||r,'RAC[T]'),
      0,decode(instr(' '||r,'RAC[F]'),
        0,'','N'),'Y') r_rac,
    decode(instr(' '||r,'ABAP[T]'),
      0,decode(instr(' '||r,'ABAP[F]'),
        0,'','N'),'Y') r_abap,
    decode(instr(' '||r,'OS['),0,'',
      substr(r,instr(r,'OS[')+3,instr(r,']',
      instr(r,'OS['))-instr(r,'OS[')-3)) r_os,
    decode(instr(' '||r,'OSF[U]'),
      0,decode(instr(' '||r,'OSF[W]'),
        0,'','WINDOWS'),'UNIX') r_osf,
    decode(instr(' '||r,'ASM[T]'),
      0,decode(instr(' '||r,'ASM[F]'),
        0,'','N'),'Y') r_asm,
    decode(instr(' '||r,'OES[T]'),
      0,decode(instr(' '||r,'OES[F]'),
        0,'','N'),'Y') r_oes,
    decode(instr(' '||r,'EPD[T]'),
      0,decode(instr(' '||r,'EPD[F]'),
        0,'','N'),'Y') r_epd,
    decode(instr(' '||r,'TDE[T]'),
      0,decode(instr(' '||r,'TDE[F]'),
        0,'','N'),'Y') r_tde,
    sim_bundle oj_helper_sim_bundle
  from
    ShouldOrByLine,
    gv$instance,
    BASIS_INFO
),
IsResLim as
( select
    inst_id,
    upper(resource_name) resource_name,
    limit_value res_limit_value,
    max_utilization
  from
    gv$resource_limit
  where
    resource_name in ('processes',
      'sessions','parallel_max_servers')
),
IsPgaStat as
( select
    pga.inst_id,
    pga.value max_since_start,
    param.value pga_limit_value
  from
    gv$pgastat pga,
    gv$parameter2 param
  where
    pga.inst_id=param.inst_id and
    pga.name='maximum PGA allocated' and
    param.name='pga_aggregate_target'
),
IsSomeParVals as
( select /*old libraries allow max. 8 of the below aggregate functions */
    a.inst_id,
    cpu_count,
    shared_pool_size_mb,
    sga_target,
    cluster_database is_rac,
    log_buffer,
    db_cache_size,
    calculated_shared_pool_size_mb,
    processes,
    para_max,
    enable_pluggable_database is_epd
  from
  ( select
      inst_id,
      max(decode(name,'shared_pool_size',value,null))/1024/1024 shared_pool_size_mb,
      max(decode(name,'sga_target',value,null)) sga_target,
      max(decode(name,'cluster_database',nvl(sim_rac,
        decode(value,'TRUE','Y','N')),null)) cluster_database,
      max(decode(name,'log_buffer',value,null)) log_buffer,
      max(decode(name,'cpu_count',value,null)) cpu_count,
      ( max(decode(name,'cpu_count',value,null))/4*500+
        max(decode(name,'sga_max_size',value,null))/1024/1024/1024*5+300)*
        decode(max(decode(name,'cluster_database',nvl(sim_rac,
        decode(value,'TRUE','Y','N')),null)), 'Y', 1.2, 1) calculated_shared_pool_size_mb
    from
      gv$parameter2,
      BASIS_INFO
    where
      name in ('cluster_database',
        'cpu_count','log_buffer','sga_max_size',
        'sga_target','shared_pool_size')
    group by
      inst_id
  ) a,
  ( select
      inst_id,
      max(decode(name,'db_cache_size',value,null)) db_cache_size,
      max(decode(name,'processes',value,null)) processes,
      max(decode(name,'parallel_max_servers',value,null)) para_max,
      max(decode(name,'enable_pluggable_database',decode(value,'TRUE','Y','N'),null)) enable_pluggable_database
    from
      gv$parameter2
    where
      name in ('db_cache_size','inmemory_size','processes','parallel_max_servers','enable_pluggable_database')
    group by
      inst_id
  ) b
  where
    a.inst_id=b.inst_id
),
IsTDEUsage as
( select
    decode(count(*),0,'N','Y') is_tde
  from
    v$encrypted_tablespaces
),
IsUndoStat as
( select
    inst_id,
    max(UNXPBLKRELCNT+UNXPBLKREUCNT) max_stolen
  from
    gv$undostat
  group by
    inst_id
),
IsPSAndMFdba_hist as
(
  select
    to_number(bundle) bundle,
    '20'||substr(bd,1,2)||'-'||substr(bd,3,2)||'-'||substr(bd,5,2) bundle_date
  from
  ( select
      replace(substr(h.comments,8,2),'.','') bundle,
      substr(h.comments,instr(h.comments,'.',1,4)+1,6) bd
    from
      dba_registry_history h,
      v$instance i
    where
      substr(h.comments,1,6)='SBP '||substr(i.version,1,2) and
      h.action='APPLY'
    union
    ( select
        replace(substr(h.target_version,4,2),'.','') bundle,
        substr(h.description,instr(h.description,'.',1,4)+1,6) bd
      from
        dba_registry_sqlpatch h,
        v$instance i
      where
        substr(i.version,1,2) = substr(h.target_version,1,2) and
        substr(h.source_version,1,2) = substr(h.target_version,1,2) and
        substr(h.source_version,4,2) <> substr(h.target_version,4,2) and
        h.action='APPLY' and
        h.status='SUCCESS'
    )
    union (select '0' bundle, '000000' bd from dual)
  )
  order by
    to_number(bundle) desc
  fetch
    first row only
),
IsPSAndMF as
( select
    i.startup_time,
    nvl(bi.sim_release, substr(i.version_full,1,2)) release,
    to_number(nvl(bi.sim_bundle, replace(substr(i.version_full,4,2),'.',''))) bundle
  from
    v$instance i,
    basis_info bi
),
IsFixControlReliable as
( select
    decode(sign(nvl(sum(decode(sfc.bugno,null,1,0)),0)),1,0,1) reliable
  from
  ( select
      substr(trim(translate(value,chr(10)||chr(13)||chr(9),'   ')),1,instr(trim(value),':')-1) subname
    from
    ( select
        inst_id,
        substr(','||value,
         instr(','||value,',',1,nr)+1,
         decode(instr(','||value,',',1,nr+1),
           0,length(','||value),
           instr(','||value,',',1,nr+1)-1)-
         decode(instr(','||value,',',1,nr),
           0,length(','||value),
           instr(','||value,',',1,nr))) value
      from
        gv$parameter,
        NumGen
      where
        name='_fix_control'
    )
    where
      value is not null
  ) b,
    v$system_fix_control sfc
  where
    b.subname=to_char(sfc.bugno(+))
),
IsFeatureUsed as
( select
    nvl(max(sim_asm),nvl(max(decode(event,
      'ASM background timer','Y',null)),'N')) is_asm,
    nvl(max(sim_oes),nvl(max(decode(event,
      'cell single block physical read','Y',null)),'N')) is_oes
  from
    v$system_event,
    BASIS_INFO
  where
    event in ('cell single block physical read',
      'ASM background timer','db file sequential read')
),
IsABAPStack as
( select
    nvl(max(sim_abap),nvl(max(decode(table_name,
      'T000','Y',null)),'N')) is_abap
  from
    dba_tables,
    BASIS_INFO
  where
    owner like 'SAP%' and table_name='T000' or
    owner='SYS' and table_name='TAB$'
),
IsDatabase as
( select
    name,
    nvl(sim_os,platform_name) platform_name,
    decode(instr(upper(nvl(sim_os,platform_name)),'WIN'),
      0,'UNIX',
      'WINDOWS') os_family
  from
    v$database,
    BASIS_INFO
),
IsDatafileCount as
( select
    count(*) value
  from
    v$datafile ),
IsEvent as
( select
    count(*) contains_colon
  from
    gv$parameter2
  where
    name = 'event' and
    instr(value,':')>0
),
IsObjectIdLimit as
(
  select
    (POWER(2, 32)-100000000-MAX(OBJECT_ID))/
    GREATEST((MAX(OBJECT_ID)-MAX(DECODE(SIGN(SYSDATE-CREATED-31),1,OBJECT_ID,0))),1000000)/12 YearsRemaining
  from
    dba_objects
),
ShouldRestrictionAndHeuristics as
( select
    s.inst_id,
    lower(decode(instr(n,','),0,n,substr(n,1,instr(n,',')-1))) name,
    lower(decode(instr(n,','),0,' ',substr(n,instr(n,',')+1))) subname,
    replace(decode(n,
      'DB_FILES','>='||to_char(round(IsDatafileCount.value*1.1)),
      'PARALLEL_MAX_SERVERS',decode(cpu_count*10-para_max,
        0,'-aut-'||substr(w,6),w),
      'PGA_AGGREGATE_TARGET',decode(sign(round(MAX_since_start/(pga_limit_value+1)*100)-90),
        -1,decode(sign(round(MAX_since_start/(pga_limit_value+1)*100)-75),
          1,'-aut-'||substr(w,6),
           w),
        w),
      'PROCESSES',decode(sign(round(MAX_UTILIZATION/(res_limit_value+1)*100)-75),
        -1,'-aut-'||substr(w,6),w),
      'SESSIONS',decode(sign(round(MAX_UTILIZATION/(res_limit_value+1)*100)-75),
        -1,'-aut-'||substr(w,6),w),
      'SHARED_POOL_SIZE',decode(sga_target,
        0,decode(sign(shared_pool_size_mb-0.5*calculated_shared_pool_size_mb),
          -1,'-man-'||w,
          decode(sign(shared_pool_size_mb-2*calculated_shared_pool_size_mb),
            1,'-man-'||w,
            '-aut-'||w)),
        '-man-'||w),
      'UNDO_RETENTION',decode(max_stolen,
        0,'-aut-'||substr(w,6),w),
      w),'[SID]',IsDatabase.name) value,
    p flags,
    decode(n,
      'LOG_BUFFER',replace(c,'[CPU_COUNT]',to_char(cpu_count)),
      'PARALLEL_MAX_SERVERS','Max used (gv$resource_limit): '||MAX_UTILIZATION
        ||' ('||round(MAX_UTILIZATION/(para_max+1)*100)
        ||'%); '
        ||replace(c,'[CPU_COUNT]',to_char(cpu_count)),
      'PGA_AGGREGATE_TARGET','Max used MB (gv$pgastat): '||round(MAX_since_start/1024/1024)
        ||' ('||round(MAX_since_start/(pga_limit_value+1)*100)
        ||'%) ',
      'PROCESSES','Max used (gv$resource_limit): '||MAX_UTILIZATION
        ||' ('||round(MAX_UTILIZATION/(res_limit_value+1)*100)
        ||'%)',
      'SESSIONS','Max used (gv$resource_limit): '||MAX_UTILIZATION
        ||' ('||round(MAX_UTILIZATION/(res_limit_value+1)*100)
        ||'%); '
        ||replace(c,'[PROCESSES]',to_char(processes)),
      'SHARED_POOL_SIZE',decode(sga_target,
        0,'current: '||round(shared_pool_size_mb)||
          ' MB; calculated: '||round(calculated_shared_pool_size_mb)||' MB',
        'ASMM is used (sga_target>0)'),
      'UNDO_RETENTION','Max unexpired stolen blocks (gv$undostat): '||max_stolen,
      c) remark,
    decode(instr(lower(n),'_fix_control'),
      0,'N',
      decode(bugno,
        null, decode(sim_bundle,
          null,'Y',
          'N'),
        'N')) hide,
    release,
    startup_time,
    bundle,
    is_rac,
    is_asm,
    is_oes,
    is_abap,
    contains_colon IsEvent_contains_colon,
    reliable IsFixControlReliable,
    name db_name,
    platform_name
  from
    ShouldPerInstCondColsOrByLine s,
    IsResLim,
    IsPgaStat,
    IsTDEUsage,
    IsSomeParVals,
    IsUndoStat,
    IsPSAndMF,
    IsFixControlReliable,
    v$system_fix_control IsFixControl,
    IsFeatureUsed,
    IsABAPStack,
    IsDatabase,
    IsDatafileCount,
    IsEvent,
    BASIS_INFO
  where
    s.inst_id = IsResLim.inst_id(+) and
            n = resource_name(+) and
    s.inst_id = IsPgaStat.inst_id(+) and
    s.inst_id = IsSomeParVals.inst_id and
    s.inst_id = IsUndoStat.inst_id(+) and
    ( r_fix is null or
        bundle >= to_number(nvl(substr(r_fix,1,instr(r_fix,'-')-1),0)) and
        bundle <= to_number(nvl(substr(r_fix,instr(r_fix,'-')+1),999))
    ) and
    lower(decode(instr(n,','),
      0,' ',
      substr(n,instr(n,',')+1)))=to_char(bugno(+)) and
    decode(bugno(+),
      null, decode(instr(lower(n),'_fix_control'),
        0,'OK',
        decode(oj_helper_sim_bundle,
          null,'HIDE',
          'OK')),
      'OK')='OK' and
    (r_osf is null or instr(r_osf,os_family)>0) and
    (r_rac is null or r_rac = is_rac) and
    (r_ldt is null or r_ldt = is_ldt) and
    (r_lim is null or r_lim = is_lim) and
    (r_ldv is null or r_ldv = is_ldv) and
    (r_lmt is null or r_lmt = is_lmt) and
    (r_asm is null or r_asm = is_asm) and
    (r_oes is null or r_oes = is_oes) and
    (r_abap is null or r_abap = is_abap) and
    (r_bw is null or r_bw = is_olap ) and
    (r_lac is null or r_lac = is_lac ) and
    (r_las is null or r_las = is_las ) and
    (r_os is null or instr(r_os,platform_name)>0) and
    (r_rel is null or instr(r_rel, release)>0) and
    (r_epd is null or r_epd = is_epd) and
    (r_tde is null or r_tde = is_tde)
),
ShouldParamsFinal as
( select
    s.startup_time,
    s.db_name,
    s.release,
    s.bundle||decode(sim_bundle,null,'','(man)') bundle,
    decode(bi.is_olap,'Y','OLAP','?','OLTP or OLAP','OLTP')||'(man)'||
    decode(s.is_abap,'Y',', ABAP',', not ABAP')||
      decode(bi.sim_abap,null,'','(man)')||
    decode(s.is_rac,'Y',', RAC',', not RAC')||
      decode(bi.sim_rac,null,'','(man)')||
    decode(s.is_asm,'Y',', ASM',', not ASM')||
      decode(bi.sim_asm,null,'','(man)')||
    decode(s.is_oes,'Y',', OES',', not OES')||
      decode(bi.sim_oes,null,'','(man)') db_environment,
    'Diag./Tun. Pack: '||bi.is_ldt||
    ', Adv. Comp./Sec.: '||bi.is_lac||'/'||bi.is_las||
    ', In-Memory: '||bi.is_lim||
    ', Multitenant: '||bi.is_lmt||
    ', DB Vault: '||bi.is_ldv license_environment,
    s.platform_name||decode(bi.sim_os,null,'','(man)') platform_name,
    decode(sign(s.bundle-i.bundle),0,'Ok','FAILED!') check_registry_scripts,
    decode(s.IsEvent_contains_colon,0,'Ok','FAILED!') check_events,
    decode(s.IsFixControlReliable,1,'Ok','FAILED!') check_fix_controls,
    case
      when s.release='18' and s.bundle < 5 or
           s.release='19' and s.bundle < 5 then
        'FAILED! '||s.release||'.'||s.bundle||' was never supported!'
      when s.release='18' then
        'Ok, '||round((to_date('2021-06-08','yyyy-mm-dd')-sysdate)/7)||
        ' weeks left until 2021-06-08'
      when s.release='19' then
        'Ok, '||round((to_date('2026-03-31','yyyy-mm-dd')-sysdate)/7)||
        ' weeks left until 2026-03-31'
      else
        'FAILED! '||release||' not supported!'
    end check_support,
    case
      when s.release='18' and s.bundle < 5 or
           s.release='19' and s.bundle < 5 then
        'FAILED! '||s.release||'.'||s.bundle||' was never supported!'
      when s.release='18' then
        'Ok, '||round((to_date('2021-06-08','yyyy-mm-dd')-sysdate)/7)||
        ' weeks left until 2021-06-08'
      when s.release='19' then
        'Ok, '||round((to_date('2023-03-31','yyyy-mm-dd')-sysdate)/7)||
        ' weeks left until 2023-03-31'
      else
        'FAILED! '||release||' not supported!'
    end check_free_support,
    case
      when oil.YearsRemaining<2 then
        'FAILED! 2137109 (Object ID close to limit)'
      else
        'Ok'
    end check_hot_news_automatically,
    '2860628 (PMEM), 2229228 (VMware)'||case
      when instr(upper(platform_name),'AIX')>0 then
        ', 2449067 (AIX releases)'
      else
        ''
    end check_hot_news_manually,
    s.name,
    s.subname,
    s.value,
    s.flags,
    s.remark,
    s.inst_id,
    s.is_rac,
    s.hide,
    i.bundle dba_bundle,
    i.bundle_date dba_bundle_date
  from
    ShouldRestrictionAndHeuristics s,
    IsPSAndMFdba_hist i,
    BASIS_INFO bi,
    IsObjectIdLimit oil
  where
    hide='N'
),
MaintSAPSpecialParamsRaw as
( select '#'||
'_ADVANCED_INDEX_COMPRESSION_OPTIONS#_DISABLE_DIRECTORY_LINK_CHECK#'||
'_ENABLE_NUMA_SUPPORT#_ENABLE_PTIME_UP'||'DATE_FOR_SYS#'||
'_FIX_CONTROL 5099019#_FIX_CONTROL 6055658#_FIX_CONTROL 6120483#'||
  '_FIX_CONTROL 6399597#_FIX_CONTROL 6430500#_FIX_CONTROL 6972291#'||
  '_FIX_CONTROL 7324224#_FIX_CONTROL 7658097#_FIX_CONTROL 8932139#'||
  '_FIX_CONTROL 8937971#_FIX_CONTROL 9196440#_FIX_CONTROL 9495669#'||
  '_FIX_CONTROL 13627489#_FIX_CONTROL 14255600#_FIX_CONTROL 14595273#'||
  '_FIX_CONTROL 18405517#_FIX_CONTROL 20355502#_FIX_CONTROL 20636003#'||
  '_FIX_CONTROL 22540411#_FIX_CONTROL 23738304#_FIX_CONTROL 25643889#'||
  '_FIX_CONTROL 26423085#_FIX_CONTROL 26536320#_FIX_CONTROL 27321179#'||
  '_FIX_CONTROL 27343844#_FIX_CONTROL 27466597#'||
  '_FIX_CONTROL 28072567#_FIX_CONTROL 28558645#_FIX_CONTROL 28602253#'||
  '_FIX_CONTROL 28835937#_FIX_CONTROL 29450812#_FIX_CONTROL 29687220#'||
  '_FIX_CONTROL 29930457#'||
'_IN_MEMORY_UNDO#_IPDDB_ENABLE#'||
'_KOLFUSESLF#_LOG_SEGMENT_DUMP_PARAMETER#_LOG_SEGMENT_DUMP_PATCH#'||
'_MIN_LWT_LT#_MUTEX_WAIT_SCHEME#_MUTEX_WAIT_TIME#'||
'_OLTP_COMPRESS_DBG#'||
'_OPTIM_PEEK_USER_BINDS#_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#'||
  '_OPTIMIZER_CBQT_OR_EXPANSION#_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#'||
  '_OPTIMIZER_GATHER_STATS_ON_CONVENTIONAL_DML#_OPTIMIZER_REDUCE_GROUPBY_KEY#'||
  '_OPTIMIZER_USE_FEEDBACK#_OPTIMIZER_USE_STATS_ON_CONVENTIONAL_DML#'||
'_PARTIAL_COMP_ENABLED#_PX_NUMA_SUPPORT_ENABLED#_ROWSETS_ENABLED#'||
'_SECUREFILES_CONCURRENCY_ESTIMATE#'||
  '_SPACEBG_SYNC_SEGBLOCKS#_SUPPRESS_IDENTIFIERS_ON_DUPKEY#'||
'_USE_SINGLE_LOG_WRITER#'||
'EVENT 10027#EVENT 10028#EVENT 10142#EVENT 10183#EVENT 10191#EVENT 10995#'||
  'EVENT 38068#EVENT 38085#EVENT 38087#EVENT 44951#EVENT 60025#'
    val
  from
    dual
),
SysNormalParamsPerInstByLine as
( select
    inst_id,
    lower(name) name,
    ' ' subname,
    concat(lpad(isdefault,5),value) sort_string,
    ismodified
  from
    gv$parameter2
  where
    name not in ('event','_fix_control')
),
SysSpecialParamsPerInstByLine as
( select
    inst_id,
    name,
    substr(trim(translate(value,
      chr(10)||chr(13)||chr(9),'   ')),1,decode(name,'event',5,instr(trim(value),':')-1)) subname,
    concat('FALSE',trim(translate(value,
      chr(10)||chr(13)||chr(9),'  '))) sort_string,
    ismodified
  from
  ( select
      inst_id,
      name,
      substr(decode(name,'event',':',',')||value,
        instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr)+1,
        decode(instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr+1),
         0,length(decode(name,'event',':',',')||value),
         instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr+1)-1)-
       decode(instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr),
         0,length(decode(name,'event',':',',')||value),
         instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr))) value,
      ismodified
    from
      gv$parameter2,
      NumGen
    where
      name in ('event','_fix_control')
  )
  where
    value is not null
),
SAPSpecialParamsPerInstByLine as
( select
    inst_id,
    decode(substr(lower(n),1,5),
      'event','event',
      '_fix_','_fix_control',
      lower(n)) name,
    decode(substr(lower(n),1,5),
      'event',substr(n,7),
      '_fix_',substr(n,14),
      ' ') subname,
    ' TRUE ' sort_string,
    'FALSE' ismodified
  from
  ( select
      inst_id,
      '*** INFORMATION '||lpad(rownum,2)||
      ' ***' n
    from
      gv$mystat
    where
      rownum < 17 union (
    select
      inst_id,
      n
    from
    ( select
        substr(val,instr(val,'#',1,nr-0)+1,
          instr(val,'#',1,nr+1)-instr(val,'#',1,nr-0)-1) n
      from
        MaintSAPSpecialParamsRaw,
        NumGen
      where
        substr(val,instr(val,'#',1,nr-0)+1,
          instr(val,'#',1,nr+1)-instr(val,'#',1,nr-0)-1) is not null
    ),
    gv$instance)
  )
),
IsParamsFinal as
( select
    inst_id,
    name,
    subname,
    trim(substr(max(sort_string),1,5)) isdefault,
    substr(max(sort_string),6)||
      decode(count(*),1,'',
      decode(name,'event','',
      decode(substr(name,1,1),'_','',
      ', ...'))) value,
    max(ismodified) ismodified
  from
  (
    select * from SysNormalParamsPerInstByLine union
    (select * from SysSpecialParamsPerInstByLine) union
    (select * from SAPSpecialParamsPerInstByLine)
  )
  group by
    inst_id,
    name,
    subname
)
select
  '@'||substr('0V0S030Y110Z38383515150Y',
    instr('*ABCDEFGHIJ',substr(order_recommendation,1,1))*2+1,2)||'@' ic,
  name,
  decode(instr(order_recommendation,'FAILED!'),0,'','@8N@ ')||substr(order_recommendation,3) recommendation,
  decode(substr(flags,1,1),'1','@8N@ ','2','@8R@ ','')||flags flags,
  decode(instr(remark,'note'),0,remark,substr(remark,1,instr(remark,'note')-1)) remark,
  decode(instr(remark,'note'),0,'',replace(substr(remark, instr(remark,'note')),'note ','')) note,
  should_be_value,
  is_value,
  is_set,
  substr(order_recommendation,1,1) "ID",
  inst_id,
  decode(instr(remark,'note'),0,'',replace(substr(remark, instr(remark,'note')),
    'note ','https://launchpad.support.sap.com/#/notes/')) note_hyperlink
from
(
  select
    case substr(i.name,1,3)
      when '***' then -1
      else i.inst_id
    end inst_id,
    case
      when substr(i.name,1,3)='***' then upper(i.name)
      when i.subname=' ' then i.name
      else i.name||' ('||i.subname||')'
    end name,
    decode(substr(i.name,1,3),
      '***','* '||
        decode(substr(i.name,17,2),
          ' 1',
'Parameter Check for Oracle '||release||' based on Note/Version: '||
  substr(m.NoteVersion, instr(m.NoteVersion,release)+3,11),
          ' 2',
'Parameter Check last changed: '||m.LastChanged,
          ' 3',
'Parameter Check Execution: '||to_char(sysdate,'YYYY-MM-DD HH24:MI:SS'),
          ' 4','DB Startup: '||to_char(startup_time,'YYYY-MM-DD HH24:MI:SS'),
          ' 5','DB SID: '||db_name||' ' ||decode(is_rac,
'Y',' (information section from instance '||i.inst_id||')',
            ''),
          ' 6','DB Release: '||release||'.'||bundle||
            decode(sign(dba_bundle-to_number(replace(bundle,'(man)',''))),
              0,' from '||dba_bundle_date,
              ' (dba_registry_history/sql_patch: '||
              release||'.'||dba_bundle||' from '||dba_bundle_date||')'),
          ' 7','Licenses: '||license_environment,
          ' 8','DB Environment: '||db_environment,
          ' 9','DB Platform: '||platform_name,
          '10','Check Registry Scripts: '||check_registry_scripts,
          '11','Check Events: '||check_events,
          '12','Check _fix_controls: '||check_fix_controls,
          '13','Check Support for Release: '||check_support,
          '14','Check Free Support for Release: '||check_free_support,
          '15','Hot News automatically checked: '||check_hot_news_automatically,
          '16','@8R@ Hot News manually to be checked: '||check_hot_news_manually
        ),
      decode(i.ismodified,
        'FALSE', decode(i.isdefault,
          'TRUE',decode(s.value,
            null,
'Q ok (is not set; mentioned with other prerequisites/not mentioned in note)',
            decode(substr(s.value,1,5),
              '-man-',
'E check if default value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-aut-',
'H automatic check ok; doublecheck if default value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-any-',
'P ok (is not set; any value recommended)',
              '-del-',
'K ok (is not set; not to be set as explicitly mentioned in note)',
              decode(upper(i.value),
                upper(s.value),
'J add explicitly with default value "'||s.value||'"',
'B add with value "'||s.value||'"'))),
          decode(s.value,
            null,
'G check why set but mentioned with other prerequisites/not mentioned in note',
            decode(substr(s.value,1,5),
              '-man-',
'F check if value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-aut-',
'I automatic check ok; doublecheck if value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-any-',
'O ok (is set; any value recommended)',
              '-del-',
'C delete (is set; not to be set as explicitly mentioned in note)',
              decode(
                decode(
                  substr(replace(upper(i.value),' ',''),1,length(
                    substr(replace(upper(s.value),' ',''),1,
                    instr(replace(upper(s.value),' ',''),'[')-1))),
                  substr(replace(upper(s.value),' ',''),1,
                    instr(replace(upper(s.value),' ',''),'[')-1),'X',
                  ' ')||
                decode(
                  substr(replace(upper(i.value),' ',''),-length(
                    substr(replace(upper(s.value),' ',''),
                    instr(replace(upper(s.value),' ',''),']')+1))),
                  substr(replace(upper(s.value),' ',''),
                    instr(replace(upper(s.value),' ',''),']')+1),'X',
                  ' '),
                'XX',
'L ok (is set correctly =)',
                decode(sign(
                  decode(rpad('>=',length(s.value),'X'),
                    translate(s.value,'1234567890','XXXXXXXXXX'),
                      to_number(i.value)-to_number(substr(s.value,3))+1,
                    0)),
                  1,
'M ok (is set correctly >=)',
                  decode(sign(
                    decode(rpad('between ',length(s.value),'X'),
                      replace(translate(s.value,'1234567890','XXXXXXXXXX'),' and ','XXXXX'),
                        to_number(i.value)-to_number(substr(s.value,9,instr(s.value,' and ')-9))+1,
                      0))*sign(
                    decode(rpad('between ',length(s.value),'X'),
                      replace(translate(s.value,'1234567890','XXXXXXXXXX'),' and ','XXXXX'),
                        to_number(substr(s.value,instr(s.value,' and ')+5))-to_number(i.value)+1,
                      0)),
                    1,
'N ok (is set correctly between)',
'D change value to "'||s.value||'"')))))),
      decode(
        decode(substr(i.name,1,4),'nls_',0,1)+
        instr(',nls_length_semantics,nls_nchar_conv_excp,',','||i.name||','),
          0,
'R ok (ignored dynamically changed parameter)',
'A parameter was dynamically changed; no reliable recommendation can be given'))) order_recommendation,
    decode(substr(i.name,1,3),
      '***',' ',
      decode(i.isdefault,
        'TRUE','N',
        'Y')) is_set,
    i.value is_value,
    decode(substr(s.value,1,5),
      '-man-',substr(s.value,6),
      '-aut-',substr(s.value,6),
      '-any-','any value',
      '-del-','deleted f'||'rom parameter file',
              s.value) should_be_value,
    s.remark,
    s.flags
  from
    ShouldParamsFinal s,
    IsParamsFinal i,
    MaintInfo m
  where
    i.inst_id=s.inst_id(+) and
    i.name=s.name(+) and
    i.subname=s.subname(+)
) union all
( select /* dummy select due to SQL editor bug */
  null, null,null,null,null,null,null,null,null,null,null,null from dual where 1=0 )
order by
  id,
  flags,
  name,
  inst_id
))
;a