#!/bin/bash

# If any command fails, exit.
set -e

function usage {
    echo "Usage:"
    echo "  <env> required: <env> can be 'dev' or 'prod'"
    echo ""
    echo "  $0 <env> ping-hosts    Ping all hosts in inventory"
    echo ""
    echo "  $0 help                Show this help output"
}

# Return a space separated list of all cases in the $TASK case statement of
# this file. Used for shell autocompletion.
#   1) Grab just the $TASK case statement block from the runner.sh
#   2) Pull just the "case" lines
#   3) sed removes the trailing parentheses
function list_all_tasks() {
    sed -n -e '/^case $TASK in/{' -e ':a' -e 'n' -e '/^esac$/b' -e 'p' -e 'ba' -e '}' runner.sh \
      | grep '^    [-a-zA-z0-9_]*)$' \
      | sed 's/)//g'
}

# Return a space separated list of all environments. An environment is an
# ansible inventory and is represented as a directory in the
# ansible/inventories directory (EX: ansible/inventories/dev).
# Used for shell autocompletion.
function list_all_environments() {
    ls ansible/inventories
}

ENV=${1}
TASK=${2}
ARGS=${@:3}

if [ "$ENV" = 'dev' ] || [ "$ENV" = 'prod' ]; then
    INVENTORY="-i inventories/$ENV"
elif [ "$ENV" = 'tasks' ]; then
    echo $(list_all_tasks) && exit 0
elif [ "$ENV" = 'environments' ]; then
    echo $(list_all_environments) && exit 0
else
    echo "Missing proper <env>: (prod or dev)"
    usage && exit 1
fi

case $TASK in
    ping-hosts)
        echo "Pinging test-hosts in $ENV inventory"
        ansible-playbook deploy-vault.yml $INVENTORY $ARGS
        ;;
    *)
        echo "Missing proper task"
        usage
        exit 1
        ;;
    help)
        usage
        exit 0
        ;;
esac
