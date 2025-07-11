#!/bin/bash
set -e
source "$1"
kolla-ansible precheck -i "$2"
