#!/bin/bash
# Bloomflow work aliases — chargé uniquement si ~/Work/bloomflow existe

alias front="cd $HOME/Work/bloomflow/sflow-flamingo"
alias api="cd $HOME/Work/bloomflow/api-platform"
alias bo="cd $HOME/Work/bloomflow/back-office"
alias infra="cd $HOME/Work/bloomflow/sflow-infra"
alias deploy="cd $HOME/Work/bloomflow/sflow-deploy"
alias e2e="cd $HOME/Work/bloomflow/automated-e2e"
alias cubejs="cd $HOME/Work/bloomflow/cubejs"

# Kubernetes namespaces
alias loki="kubectl -n loki get pods"
alias monito="kubectl -n monitoring get pods"
