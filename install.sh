#!/bin/bash
# Fetches latest and installs dependencies for the project within a dev vm

function inst_prompt() {
    prompt="$1"
    echo -e -n "\033[1;32m"
    echo -e -n "------- Installing ---------"
    echo -e -n '\n\n'
    echo -e -n "\033[0;32m$prompt"
    echo -e -n '\033[0m'
    echo -e -n '\n\n'
}

smart_dependencies=("static" "imminence" "asset-manager" "govuk_content_api" "smart-answers")
for i in  "${smart_dependencies[@]}"
do
    inst_prompt "Changing to \033[1;35m$i"
    cd "/var/govuk/$i"
    inst_prompt "Fetching latest for \033[1;35m$i"
    git fetch
    inst_prompt "Installing dependencies for $i"
    bundle install
done
