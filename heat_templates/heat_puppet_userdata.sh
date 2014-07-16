#!/bin/bash
#
# This script is intended to be a generic script that can
# be used to perform configuration using master-less-puppet
# (ie: puppet apply)
#
set -x

if [ -n $WC_URL ]; then
  trap "curl -X PUT -H 'Content-Type:' --data-binary '{\"Status\": \"FAILURE\", \"Reason\": \"Unexpected Failure\", \"Data\": \"Userdata script has executed unexpectedly.\", \"UniqueId\": \"instance1\"}' $WC_URL" ERR
fi

# install puppet
apt-key adv --recv-key --keyserver pool.sks-keyservers.net 4BD6EC30
echo "deb http://apt.puppetlabs.com precise main" > /etc/apt/sources.list.d/puppetlabs.list
echo "deb http://apt.puppetlabs.com precise dependencies" >> /etc/apt/sources.list.d/puppetlabs.list
apt-get update
apt-get -y install puppet ruby1.9.1-full git rubygems vim curl
update-alternatives --set ruby /usr/bin/ruby1.9.1
update-alternatives --set gem /usr/bin/gem1.9.1
# install librarian-puppet-simple. I would be using r10k, but it just seemed to result
# in stack traces, happy to switch once I can get it working
gem install librarian-puppet-simple

#
# This script is based on the idea that it should refer to a Puppet project (essentially an
# artifact with a Puppetfile and a manifests directory with site.pp)
#
TMP_PATH=`mktemp -d`
git clone $PUPPET_REPO $TMP_PATH

# put the Puppetfile into the system location
cp $TMP_PATH/Puppetfile /etc/puppet/Puppetfile
# install Puppet modules (and what-not)
cd /etc/puppet
librarian-puppet install --verbose

curl -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py
pip install -U setuptools

# allow this variable to be supplied from a heat str_replace param
# or set it to a default
if [ -z "$HIERA_DATA_DIR" ]; then
  HIERA_DIR='/etc/puppet/hiera/data'
else
  HIERA_DIR=$HIERA_DATA_DIR
fi

# setup hiera data
# this template assumes that hiera data is stored in the data dir
# and that hiera.yaml maps it's yaml datadir to that directory.
# it also assumes that user.yaml can override the bits that need to
# be customized for this project
if [ -d $TMP_PATH/hiera ]; then
  cp $TMP_PATH/hiera/hiera.yaml /etc/puppet/hiera.yaml
  mkdir -p $HIERA_DIR
  if [ -d $TMP_PATH/hiera/data ]; then
    cp -Rvf $TMP_PATH/hiera/data/* $HIERA_DIR
  fi
  # write in the hiera file with our user hiera data (which should be used to store secrets)

#
# This extra hiera_data is a huge pain
#
cat <<EOF > $HIERA_DIR/$HIERA_USER_DATA_DIR/user.yaml
$USER_HIERA_YAML
EOF
fi
# write connection specific overrides
cat <<EOF >> $HIERA_DIR/$HIERA_USER_DATA_DIR/user.yaml
$CONNECTION_HIERA_OVERRIDES
EOF

# export all facts specified in FACTS parameter
for i in $(echo "$FACTS" | tr -d ' ' | tr ";" "\n")
do
  export FACTER_${i}
done

$PRE_PUPPET_CONFIG

puppet apply --detailed-exitcodes $TMP_PATH/manifests/site.pp --modulepath=/etc/puppet/modules $PUPPET_OPTIONS --config_version="echo heat_puppet_run"
PUPPET_RET=$?

$POST_PUPPET_CONFIG

if [ -n $WC_URL ]; then
  if [ $PUPPET_RET = 4 ]; then
  curl -X PUT -H 'Content-Type:' --data-binary '{"Status": "FAILURE", "Reason": "Unexpected Failure", "Data": "Userdata script has executed unexpectedly.", "UniqueId": "instance1"}'
  else
    curl -X PUT -H 'Content-Type:' --data-binary '{"Status": "FAILURE", "Reason": "Puppet Failed to Apply", "Data": "Userdata script has executed unexpectedly.", "UniqueId": "instance1"}' $WC_URL
  fi
fi
