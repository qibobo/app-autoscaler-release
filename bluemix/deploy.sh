#!/bin/bash

spruce merge templates/config-from-cf.yml stage0.yml > config-from-cf-merged.yml \
&& spruce merge --cherry-pick config_from_cf --cherry-pick director_uuid config-from-cf-merged.yml > config-from-cf-final.yml \
&& spruce merge example/property-overrides.yml example/bluemix-property.yml > properties-mid.yml \
&& spruce merge --cherry-pick default_db --cherry-pick api_server_properties --cherry-pick service_broker_properties --cherry-pick scheduler_properties --cherry-pick cf_properties --cherry-pick pruner_properties --cherry-pick metricscollector_properties --cherry-pick scalingengine_properties --cherry-pick eventgenerator_properties  properties-mid.yml > properties.yml \
&& spruce merge templates/bosh-lite-manifest-template-v2bluemix.yaml config-from-cf-final.yml properties.yml example/bluemix-property.yml > autoscaler-mid.yml \
&& spruce merge --prune config_from_cf --prune default_db --prune api_server_properties --prune service_broker_properties --prune scheduler_properties --prune cf_properties --prune pruner_properties --prune metricscollector_properties --prune scalingengine_properties --prune eventgenerator_properties  properties-mid.yml autoscaler-mid.yml > autoscaler-final.yml

bosh create release --force --name app-autoscaler --with-tarball ./autoscaler.tgz
bosh2 upload-release /tmp/app-autoscaler-release/dev_releases/app-autoscaler/app-autoscaler-0+dev.88.tgz 
bosh2 -d app-autoscaler-release deploy autoscaler-final.yml


spruce merge ./bluemix/templates/app-autoscaler-deployment-bluemix.yml ./bluemix/bluemix-property-template.yml > autoscaler-deployment.yml
bosh2 create-release --force
bosh2 upload-release --rebase
bosh2 -d app-autoscaler deploy autoscaler-deployment.yml 

spruce merge ./bluemix/templates/app-autoscaler-deployment-bluemix.yml ./bluemix/bluemix-property-template.yml > autoscaler-deployment.yml