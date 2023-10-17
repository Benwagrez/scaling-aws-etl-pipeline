#!/bin/bash

# Installing Python dependencies into packages and zipping the deployment for ETL Data Query
pip install --target ./packages/ETLDataQuery -r ./python/ETLDataRequirements.txt --no-user
7z a -tzip ./ETL_data_query_payload.zip ./packages/ETLDataQuery/*
7z a ./ETL_data_query_payload.zip ./python/ETLDataQuery/*

# Installing Python dependencies into packages and zipping the deployment for ETL Process Action
pip install --target ./packages/ETLDataQuery -r ./python/ETLProcRequirements.txt --no-user
7z a -tzip ./ETL_proc_action_payload.zip ./packages/ETLProcAction/*
7z a ./ETL_proc_action_payload.zip ./python/ETLProcAction/*

# Set up core infrastructure
terraform apply -var-file="terraform.tfvars"

# Running Terraform apply for deploy container
terraform apply -var-file="terraform.tfvars" -var="deployvm=true"

rm ETL_data_query_payload.zip
rm ETL_proc_action_payload.zip