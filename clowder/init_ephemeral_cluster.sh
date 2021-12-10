#!/usr/bin/env

# See step 7 of this link: https://clouddot.pages.redhat.com/docs/dev/getting-started/ephemeral/onboarding.html
echo "Loggin to Openshift cluster"
sh ~/ephemeral-login.sh
echo "Checking for reserved namespace"
export NAMESPACE=$(bonfire namespace list --mine | grep "ephemeral" | awk '{print $1"|"$2}' | grep '|true' | awk -F'|' '{print $1}' | head -n1) # we use the first one available

if [[ $NAMESPACE == *"ephemeral-"* ]]; then
    echo "Namespace $NAMESPACE reserved, extending for 8 hours"    
    bonfire namespace reserve -d 8 $NAMESPACE 
else
    echo "Reserving namespace for 8 hours"
    export NAMESPACE=$(bonfire namespace reserve -d 8)
    echo "Namespace $NAMESPACE reserved"
fi

echo "Using $NAMESPACE as default oc project"
oc project $NAMESPACE

echo "Deploying apps to $NAMESPACE"
bonfire deploy drift xjoin-search -n $NAMESPACE

sh ./clowder/clowder-port-forward.sh
