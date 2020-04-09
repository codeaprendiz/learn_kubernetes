#!/usr/bin/env bash


if [ $# -lt 3 ]
then
  echo "Usage: ./reset.sh <user-group> <kubeconfig-cluster-folder> <access-type>"
  exit 0
fi


FOLDER_USER_GROUP=$1
KUBCONFIG_CLUSTER_FOLDER=$2
ACCESS_TYPE=$3


export NAME_OF_CSR="$KUBCONFIG_CLUSTER_FOLDER-$FOLDER_USER_GROUP-$ACCESS_TYPE-csr"

kubectl delete csr "$NAME_OF_CSR"



if test -f "./$KUBCONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/clusterRole-readonly.yaml"; then
    kubectl delete -f "./$KUBCONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/clusterRole-readonly.yaml"
fi

if test -f "./$KUBCONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/clusterRole-readwrite.yaml"; then
    kubectl delete -f "./$KUBCONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/clusterRole-readwrite.yaml"
fi



kubectl delete -f "./$KUBCONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/clusterRole-binding.yaml"


rm -rf ./$KUBCONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/*




