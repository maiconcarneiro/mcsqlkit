PROMP
PROMP =======================================================================
PROMP
PROMP -> 0) Listar Baselines e Profiles existentes para um SQL ID
PROMP ...............................................................
PROMP @plan_list <SQL ID>
PROMP
PROMP -> 1) Habilitar e desabilitar um Baseline
PROMP ...............................................................
PROMP @plan_enable <Baseline Plan Name>
PROMP @plan_disable <Baseline Plan Name>
PROMP
PROMP -> 2) Habilitar e desabilitar um Profile 
PROMP ...............................................................
PROMP @profile_enable <profile name>
PROMP @profile_disable <profile name>
PROMP
PROMP -> 3) Criar um baseline (fixar plano - modo recomendado)
PROMP ...............................................................
PROMP @plan_fix <SQL ID> <PLAN HASH VALUE>
PROMP
PROMP -> 4) Criar um SQL Profile (fixar plano - casos especiais)
PROMP ...............................................................
PROMP @coe <SQL ID> <PLAN HASH VALUE>
PROMP 
PROMP =======================================================================
PROMP 