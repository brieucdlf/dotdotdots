#!/bin/zsh
# Bloomflow work aliases — loaded only if ~/Repos/bloomflow exists

alias front="cd $HOME/Repos/bloomflow/sflow-flamingo"
alias api="cd $HOME/Repos/bloomflow/api-platform"
alias bo="cd $HOME/Repos/bloomflow/back-office"
alias infra="cd $HOME/Repos/bloomflow/sflow-infra"
alias deploy="cd $HOME/Repos/bloomflow/sflow-deploy"
alias e2e="cd $HOME/Repos/bloomflow/automated-e2e"
alias cubejs="cd $HOME/Repos/bloomflow/cubejs"

# Kubernetes namespaces
alias loki="kubectl -n loki get pods"
alias monito="kubectl -n monitoring get pods"
