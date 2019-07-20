#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <secrets>"
	exit 1
fi

# Create-team also logs in.
fly -t continuous status
if [[ $? -ne 0 ]]; then
	./create-team.sh continuous $1
fi

fly -t nightly status
if [[ $? -ne 0 ]]; then
	./create-team.sh nightly $1
fi

fly -t r1beta1 status
if [[ $? -ne 0 ]]; then
	./create-team.sh r1beta1 $1
fi

# Deploy pipelines
./apply-pipeline.sh continuous master $1
./apply-pipeline.sh nightly master $1
./apply-pipeline.sh r1beta1 r1beta1 $1
