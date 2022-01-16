#!/bin/bash

# terminal colors
GREEN='\033[0;32m' 
CYAN='\033[36m' 
YELLOW='\033[1;33m'
RED='\033[0;31m'   
NC='\033[0m'

# log level
SUCCESS=${GREEN}[SUCCESS]${NC}
INFO=${CYAN}[INFO]${NC}
WARNING=${YELLOW}[WARNING]${NC}
ERROR=${RED}[ERROR]${NC}

####################################################################
######################### STATIC VARIABLES #########################
####################################################################

VERSION=1.0.0

####################################################################
###################### FUNCTIONS DECLARATIONS ######################
####################################################################

display_help_page() {
    echo -e "This tool manages docker stacks."
    echo -e
    echo -e "Usage: $0 [options]"
    echo -e
    echo -e "Some of the options include:"
    echo -e '\t' "      -h|--help" '\t' "to display this (help) page"
    echo -e '\t' "      -v|--version" '\t' "to get this command version"
    echo -e '\t' "     -ls|--list" '\t' "to list all stacks in this folder"
    echo -e '\t' "      -u|--up" '\t\t' "to deploy a specific stack"
    echo -e '\t' "     -ua|--up-all" '\t' "to deploy all stacks in this folder"
    echo -e '\t' "      -d|--down" '\t' "to delete a specific stack"
    echo -e '\t' "     -da|--down-all" '\t' "to delete all stacks"
}

display_version() {
    echo -e "$VERSION"
}

list_stacks() {
    for dir in */ ; do
        stack=$(echo $dir | grep -oE '[^/]*') # removes '/'; e.g. dir = "mongodb/", stack = "mongodb"
        echo -e $stack
    done
}

deploy_stack() {
    stack=$(echo $1 | grep -oE '[^/]*')
    dir=$stack/
    echo -e $INFO deploying${YELLOW} $stack ${NC}stack
    docker-compose -f ${dir}docker-compose.yml up -d --build
    if [ $? -ne 0 ]; then
        echo -e $ERROR could not deploy $stack stack, something went wrong!
    fi
}

deploy_all_stacks() {
    for dir in */ ; do
        stack=$(echo $dir | grep -oE '[^/]*')
        deploy_stack $stack
    done
}

delete_stack() {
    stack=$(echo $1 | grep -oE '[^/]*')
    dir=$stack/
    echo -e $INFO deleting${YELLOW} $stack ${NC}stack
    docker-compose -f ${dir}docker-compose.yml down
    if [ $? -ne 0 ]; then
        echo -e $ERROR could not delete $stack stack, something went wrong!
    fi
}

delete_all_stacks() {
    for dir in */ ; do
        stack=$(echo $dir | grep -oE '[^/]*')
        delete_stack $stack
    done
}

####################################################################
######################## ARGUMENTS PARSING #########################
####################################################################

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
        display_help_page
        exit 0
        ;;
    -v|--version)
        display_version
        exit 0
        ;;
    -ls|--list)
        list_stacks
        exit 0
        ;;
    -u|--up)
        shift
        if [[ ! -z "$1" ]]; then
            deploy_stack $1
        else
            echo -e "$WARNING no stack was specified"
            echo -e "usage example: $0 --up mongodb" 
            exit 0
        fi
        exit 0
        ;;
    -ua|--up-all)
        deploy_all_stacks
        exit 0
        ;;
    -d|--down)
        shift
        if [[ ! -z "$1" ]]; then
            delete_stack $1
        else
            echo -e "$WARNING no stack was specified"
            echo -e "usage example: $0 --down mongodb" 
            exit 0
        fi
        exit 0
        ;;
    -da|--down-all)
        delete_all_stacks
        exit 0
        ;;
    -*|--*) # unknown option
        echo -e "$WARNING invalid option, type $0 -h|--help to display help page."
        exit 0
        ;;
    *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        shift # past argument
        ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

####################################################################
############################### MAIN ###############################
####################################################################

exit 0