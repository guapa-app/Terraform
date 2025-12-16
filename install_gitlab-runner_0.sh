#!/usr/bin/env bash

NAMESPACE=default

if ! command -v helm &> /dev/null
then
  echo "helm not installed"
  exit
fi

mkdir -p "gr-0"
cd "gr-0"
cat > "gr-0.cfg" <<'HERELIMIT'
[[runners]]
  [runners.kubernetes]
    namespace = "{{.Release.Namespace}}"
    image = "ubuntu:20.04"
    poll_timeout = 600
    cpu_request = "0.2"
    memory_request = "512M"
    cpu_request_overwrite_max_allowed = "1"
    memory_request_overwrite_max_allowed = "4096M"

HERELIMIT

if [ $? -eq 1 ]
then
  echo "could not change directory: gr-0"
  exit
fi

if [ ! -d gitlab-runner ]
then
  helm repo add gitlab https://charts.gitlab.io
  helm pull --untar gitlab/gitlab-runner
else
  echo "gitlab-runner directory already exist"
fi


if helm list -q 2> /dev/null | grep gr-0
then
  helm upgrade --namespace default gr-0 gitlab/gitlab-runner --set gitlabUrl=https://gitlab.com --set unregisterRunners=true --set rbac.create=true --set runnerRegistrationToken=gitlab-runner-token --set runners.name=runner0 --set runners.tags="demo\,runner0" --set-file runners.config=gr-0.cfg
else
  helm install --namespace default gr-0 gitlab/gitlab-runner --set gitlabUrl=https://gitlab.com --set unregisterRunners=true --set rbac.create=true --set runnerRegistrationToken=gitlab-runner-token --set runners.name=runner0 --set runners.tags="demo\,runner0" --set-file runners.config=gr-0.cfg
fi

if [ $? -eq 0 ]
then
  echo "gitlab runner deployment finished"
else
  echo "could not deploy gitlab runner"
fi