#!/bin/bash

export DEVELOPERS_GROUP=fbd14e44-da3c-4305-8731-0060f56c296f
export CMC_GROUP=94bfcae1-11e0-4723-bef8-e6f3925eb55e
export PROBATE_GROUP=cb3b15bc-bd18-4d17-bc52-1f4dc77afdad
export DIVORCE_GROUP=439c3560-c51b-4c3f-8523-c1cee0e3fe0d

mkdir -p templates/substituted

envsubst < templates/developers-log-reader-binding.template.yaml > templates/substituted/developers-log-reader-binding.yaml
kubectl apply -f templates/substituted/developers-log-reader-binding.yaml