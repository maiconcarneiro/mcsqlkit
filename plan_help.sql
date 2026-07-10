PROMP
PROMP =======================================================================
PROMP
PROMP -> 0) List existing Baselines and Profiles for a SQL ID
PROMP ...............................................................
PROMP @plan_list <SQL ID>
PROMP
PROMP -> 1) Enable and disable a Baseline
PROMP ...............................................................
PROMP @plan_enable <Baseline Plan Name>
PROMP @plan_disable <Baseline Plan Name>
PROMP
PROMP -> 2) Enable and disable a Profile
PROMP ...............................................................
PROMP @profile_enable <profile name>
PROMP @profile_disable <profile name>
PROMP
PROMP -> 3) Create a baseline (fix plan - recommended mode)
PROMP ...............................................................
PROMP @plan_fix <SQL ID> <PLAN HASH VALUE>
PROMP
PROMP -> 4) Create a SQL Profile (fix plan - special cases)
PROMP ...............................................................
PROMP @coe <SQL ID> <PLAN HASH VALUE>
PROMP 
PROMP =======================================================================
PROMP 