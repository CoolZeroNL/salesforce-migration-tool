#!/bin/bash
function error {
    echo "$1" >&2
}

function usage {
    error "
    Usage: $0 <ant target> <setup file> [folder]
    "
    exit 1
}
#################################################################
target="${1}"
setup="${2}"
folder="${3}"

build_xml="build.xml"

if [ -z "$target" ]; then
    error "<target> not supplied"
    usage
fi

if [ ! -f "${setup}" ]; then
    error "<setup file> not supplied"
    usage
fi

. "${setup}"

if [ -z "$username" ]; then
    error "<username> not set"
    exit 1
fi

if [ -z "$password" ]; then
    error "<password> not set"
    exit 1
fi

if [ -z "$token" ]; then
    error "<token> not set"
    exit 1
fi

if [ -z "$serverurl" ]; then
    serverurl="login.salesforce.com"
fi

passwordtoken="$password$token"

#################################################################
if [ -z "$retrievebase" ]; then
    error "<retrievebase> not set"
    exit 1
fi

if [ ! -d "$retrievebase" ]; then
    error "<${retrievebase}> is not a directory"
    exit 1
fi

#################################################################
if [ ! -f "${build_xml}" ]; then
    error "build xml<${build_xml}> does not exist"
    exit 1
fi

#################################################################
if [ -z "$ant_salesforce_jar" ]; then
    error "<ant_salesforce_jar> is not set"
    exit 1
fi

if [ ! -f "${ant_salesforce_jar}" ]; then
    error "${antsalesforcefilename}<${ant_salesforce_jar}> does not exist"
    exit 1
fi

################################################################

echo "**************************************************************************"
echo
echo "CONFIRM deploying source to <${username}>"
echo
echo "${antsalesforcefilename}<${ant_salesforce_jar}>"
echo "build xml<${build_xml}>"
echo "username<${username}>"
echo "serverurl<${serverurl}>"
echo "retrievebase<${retrievebase}>"
echo "**************************************************************************"
echo
echo "This action will overwrite items in Salesforce with the version in your folder."
echo "is this username correct <${username}> ?"
read -p "y/N?" -t 10 confirm_deploy
echo

if [ -z ${confirm_deploy} ] || [ ${confirm_deploy,,} != 'y' ]; then
    error "User cancelled"
    exit 2
fi

################################################################
echo "Starting at $(date)..."
time ant -f "${build_xml}" "${target}" -Dfolder="${folder}" -Dusername="${username}" -Dpassword="${passwordtoken}" -Dserverurl="${serverurl}" -DantSalesforceJar="${ant_salesforce_jar}" -DretrieveBase="${retrievebase}" -v
echo "Completed at $(date)"
echo "End"
exit 0
