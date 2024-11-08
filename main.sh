#!/bin/bash
set -euo pipefail

THIS_SCRIPT_DIR=$(
    cd "$(dirname "$0")"
    pwd
)
readonly THIS_SCRIPT_DIR

function info() {
    echo "$(date +'%Y-%m-%dT%H:%M:%S%z') [INFO] $*"
}

function error() {
    echo "$(date +'%Y-%m-%dT%H:%M:%S%z') [ERROR] $*" >&2
}

function unset_credentials() {
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

function set_credentials() {
    local role_arn="$1"

    unset_credentials

    local cred
    cred=$(
        aws sts assume-role \
            --role-arn "${role_arn}" \
            --role-session-name terraform-session \
            --output json
    )

    AWS_ACCESS_KEY_ID=$(echo "${cred}" | jq -r .Credentials.AccessKeyId)
    AWS_SECRET_ACCESS_KEY=$(echo "${cred}" | jq -r .Credentials.SecretAccessKey)
    AWS_SESSION_TOKEN=$(echo "${cred}" | jq -r .Credentials.SessionToken)
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

function plan() {
    info "start terraform plan"

    terraform init
    terraform plan

    info "success terraform plan"
}

function apply() {
    info "start terraform apply"

    terraform init
    terraform apply -auto-approve

    poling

    info "success terraform apply"
}

function destroy() {
    info "start terraform destroy"

    terraform init
    terraform destroy -auto-approve

    info "success terraform destroy"
}

function poling() {
    local url
    url=$(terraform output -json | jq -r ".load_balancer_dns_name.value")

    info "url=${url}"

    local count="240"
    for i in $(seq 1 ${count}); do
        local http_status_code
        set +e
        http_status_code=$(curl "${url}" -o /dev/null -w '%{http_code}\n' -s)
        set -e

        if [[ "${http_status_code}" == "200" ]]; then
            info "Success request ${url}"
            break
        else
            info "Poling ${http_status_code} ${i}/${count}"
        fi
        sleep 5
    done
}

function main() {
    set_credentials "${IAM_ROLE_ARN}"

    cd "${THIS_SCRIPT_DIR}/terraform/services/example/stage/develop"

    local cmd="$1"

    case "${cmd}" in
    "plan") plan ;;
    "apply") apply ;;
    "destroy") destroy ;;
    *)
        error "invalid subcommand: command=${cmd}"
        exit 1
        ;;
    esac
}

main "$@"
