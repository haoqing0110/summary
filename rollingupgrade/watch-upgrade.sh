#!/bin/bash
#kubectl get manifestwork -n local-cluster addon-application-manager-deploy -o=jsonpath='{.metadata.generation}'
#kubectl get manifestwork -n local-cluster -o=jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.metadata.generation}{"\t"}{.status.conditions[*].observedGeneration}{"\n"}{end}'
#watch "kubectl get manifestwork -n local-cluster -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\t\"}{.metadata.name}{\"\t\"}{.metadata.generation}{\"\t\"}{.status.conditions[*].observedGeneration}{\"\n\"}{end}'"

NAMESPACES=(
"cluster1"
)

WORKS=(
"cluster1-klusterlet"
"addon-application-manager-deploy"
"addon-cert-policy-controller-deploy"
"addon-config-policy-controller-deploy"
"addon-governance-policy-framework-deploy"
"addon-iam-policy-controller-deploy"
"addon-search-collector-deploy"
"addon-work-manager-deploy"
)

declare -A WORK_GEN_OLD
declare -A WORK_GEN_NEW
declare -A WORK_GEN_UPDATE_TIME
declare -A WORK_OBSGEN_UPDATE_TIME

function init_work_gen() {
    for ns in ${NAMESPACES[*]}
    do
        for name in ${WORKS[*]}
        do
            gen=`kubectl get manifestwork -n ${ns} ${name} -o=jsonpath='{.metadata.generation}'`
            WORK_GEN_OLD[${ns}-${name}]=${gen}
        done
    done
}

function check_gen_update_time() {
    for ns in ${NAMESPACES[*]}
    do
        for name in ${WORKS[*]}
        do
            gen=`kubectl get manifestwork -n ${ns} ${name} -o=jsonpath='{.metadata.generation}'`
            if [ ${gen}z != ${WORK_GEN_OLD[${ns}-${name}]}z -a ${gen}z != ${WORK_GEN_NEW[${ns}-${name}]}z ]; then
               WORK_GEN_NEW[${ns}-${name}]=${gen}
               WORK_GEN_UPDATE_TIME[${ns}-${name}]=`date`
            fi
        done
    done
}

function check_obsgen_update_time() {
    for ns in ${NAMESPACES[*]}
    do
        for name in ${WORKS[*]}
        do
            obsgen=`kubectl get manifestwork -n ${ns} ${name} -o=jsonpath='{.status.conditions[1].observedGeneration}'`
            if [ ${obsgen}z == ${WORK_GEN_NEW[${ns}-${name}]}z -a ${WORK_OBSGEN_UPDATE_TIME[${ns}-${name}]}z == ""z ]; then
               WORK_OBSGEN_UPDATE_TIME[${ns}-${name}]=`date`
            fi
        done
    done
}

function print_gen() {
    echo -e "namespace\twork\tgeneration\tobservedGeneration"
    for ns in ${NAMESPACES[*]}
    do
        for name in ${WORKS[*]}
        do
            echo -e ${ns}"\t"${name}"\t"${WORK_GEN_UPDATE_TIME[${ns}-${name}]}"\t"${WORK_OBSGEN_UPDATE_TIME[${ns}-${name}]}
        done
    done
}

init_work_gen

while [ ${#WORK_GEN_OLD[@]} -ne ${#WORK_GEN_UPDATE_TIME[@]} -o ${#WORK_GEN_OLD[@]} -ne ${#WORK_OBSGEN_UPDATE_TIME[@]} ] 
do
   check_gen_update_time 
   check_obsgen_update_time
   sleep 1
done

print_gen