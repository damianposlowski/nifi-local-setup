#!/bin/bash


export version='2.0.0-M3'
export nifi_registry_port='18080'
export nifi_dev_port='8443'
export nifi_stg_port='8444'
export nifi_prd_port='8445'




wget https://dlcdn.apache.org/nifi/${version}/nifi-${version}-bin.zip
wget https://dlcdn.apache.org/nifi/${version}/nifi-toolkit-${version}-bin.zip
wget https://dlcdn.apache.org/nifi/${version}/nifi-registry-${version}-bin.zip

unzip nifi-${version}-bin.zip -d ./nifi-prd && cd  ./nifi-prd/nifi-${version} &&  mv * .. && cd .. && rm -rf nifi-${version}
cd ..
unzip nifi-${version}-bin.zip -d ./nifi-stg && cd  ./nifi-stg/nifi-${version} &&  mv * .. && cd .. && rm -rf nifi-${version}
cd ..
unzip nifi-${version}-bin.zip -d ./nifi-dev && cd  ./nifi-dev/nifi-${version} &&  mv * .. && cd .. && rm -rf nifi-${version}
cd ..
unzip nifi-toolkit-${version}-bin.zip -d ./nifi-toolkit && cd  ./nifi-toolkit/nifi-toolkit-${version} &&  mv * .. && cd .. && rm -rf nifi-toolkit-${version}
cd ..
unzip nifi-registry-${version}-bin.zip -d ./nifi-registry && cd  ./nifi-registry/nifi-registry-${version} &&  mv * .. && cd .. && rm -rf nifi-registry-${version}
cd ..


prop_replace () {
  target_file=${3:-${nifi_props_file}}
  echo 'replacing target file ' ${target_file}
  sed -i -e "s|^$1=.*$|$1=$2|"  ${target_file}
}



echo "Create NiFi Toolkit Client configuration"
mkdir -p ./nifi-toolkit/nifi-envs
cp ./nifi-toolkit/conf/cli.properties.example ./nifi-toolkit/nifi-envs/nifi-PRD
cp ./nifi-toolkit/conf/cli.properties.example ./nifi-toolkit/nifi-envs/nifi-STG
cp ./nifi-toolkit/conf/cli.properties.example ./nifi-toolkit/nifi-envs/nifi-DEV
cp ./nifi-toolkit/conf/cli.properties.example ./nifi-toolkit/nifi-envs/registry-PRD

prop_replace baseUrl http://localhost:${nifi_prd_port} ./nifi-toolkit/nifi-envs/nifi-PRD
prop_replace baseUrl http://localhost:${nifi_stg_port} ./nifi-toolkit/nifi-envs/nifi-STG
prop_replace baseUrl http://localhost:${nifi_dev_port} ./nifi-toolkit/nifi-envs/nifi-DEV
prop_replace baseUrl http://localhost:${nifi_registry_port} ./nifi-toolkit/nifi-envs/registry-PRD



# Start NiFi Registry
./nifi-registry/bin/nifi-registry.sh start 

# Edit NiFi configs PRD
prop_replace nifi.web.http.port ${nifi_prd_port} ./nifi-prd/conf/nifi.properties
prop_replace nifi.web.https.port ''  ./nifi-prd/conf/nifi.properties
prop_replace nifi.web.http.host localhost  ./nifi-prd/conf/nifi.properties
prop_replace nifi.web.https.host ''  ./nifi-prd/conf/nifi.properties
prop_replace nifi.remote.input.secure false ./nifi-prd/conf/nifi.properties
prop_replace nifi.ui.banner.text PRD ./nifi-prd/conf/nifi.properties
prop_replace nifi.security.keystore '' ./nifi-prd/conf/nifi.properties
prop_replace nifi.security.keystoreType '' ./nifi-prd/conf/nifi.properties
prop_replace nifi.security.keystorePasswd '' ./nifi-prd/conf/nifi.properties
prop_replace nifi.security.keyPasswd '' ./nifi-prd/conf/nifi.properties
prop_replace nifi.security.truststore '' ./nifi-prd/conf/nifi.properties
prop_replace nifi.security.truststoreType '' ./nifi-prd/conf/nifi.properties
prop_replace nifi.security.truststorePasswd '' ./nifi-prd/conf/nifi.properties

# Edit NiFi configs STG
prop_replace nifi.web.http.port ${nifi_stg_port} ./nifi-stg/conf/nifi.properties
prop_replace nifi.web.https.port ''  ./nifi-stg/conf/nifi.properties
prop_replace nifi.web.http.host localhost  ./nifi-stg/conf/nifi.properties
prop_replace nifi.web.https.host ''  ./nifi-stg/conf/nifi.properties
prop_replace nifi.remote.input.secure false ./nifi-stg/conf/nifi.properties
prop_replace nifi.ui.banner.text STG ./nifi-stg/conf/nifi.properties
prop_replace nifi.security.keystore '' ./nifi-stg/conf/nifi.properties
prop_replace nifi.security.keystoreType '' ./nifi-stg/conf/nifi.properties
prop_replace nifi.security.keystorePasswd '' ./nifi-stg/conf/nifi.properties
prop_replace nifi.security.keyPasswd '' ./nifi-stg/conf/nifi.properties
prop_replace nifi.security.truststore '' ./nifi-stg/conf/nifi.properties
prop_replace nifi.security.truststoreType '' ./nifi-stg/conf/nifi.properties
prop_replace nifi.security.truststorePasswd '' ./nifi-stg/conf/nifi.properties

# Edit NiFi configs DEV
prop_replace nifi.web.http.port ${nifi_dev_port} ./nifi-dev/conf/nifi.properties
prop_replace nifi.web.https.port ''  ./nifi-dev/conf/nifi.properties
prop_replace nifi.web.http.host localhost  ./nifi-dev/conf/nifi.properties
prop_replace nifi.web.https.host ''  ./nifi-dev/conf/nifi.properties
prop_replace nifi.remote.input.secure false ./nifi-dev/conf/nifi.properties
prop_replace nifi.ui.banner.text DEV ./nifi-dev/conf/nifi.properties
prop_replace nifi.security.keystore '' ./nifi-dev/conf/nifi.properties
prop_replace nifi.security.keystoreType '' ./nifi-dev/conf/nifi.properties
prop_replace nifi.security.keystorePasswd '' ./nifi-dev/conf/nifi.properties
prop_replace nifi.security.keyPasswd '' ./nifi-dev/conf/nifi.properties
prop_replace nifi.security.truststore '' ./nifi-dev/conf/nifi.properties
prop_replace nifi.security.truststoreType '' ./nifi-dev/conf/nifi.properties
prop_replace nifi.security.truststorePasswd '' ./nifi-dev/conf/nifi.properties


echo " Start NiFi PRD"
./nifi-prd/bin/nifi.sh start
echo " Start NiFi STG"
./nifi-stg/bin/nifi.sh start
echo " Start NiFi DEV"
./nifi-dev/bin/nifi.sh start




# Remove Resources 
rm -f nifi-${version}-bin.zip
rm -f nifi-toolkit-${version}-bin.zip
rm -f nifi-registry-${version}-bin.zip



echo "### Adding Registry Client to PRD"
./nifi-toolkit/bin/cli.sh nifi create-reg-client --baseUrl http://localhost:${nifi_prd_port} --registryClientUrl http://localhost:${nifi_registry_port} --registryClientName PRD
echo "### Adding Registry Client to STG"
./nifi-toolkit/bin/cli.sh nifi create-reg-client --baseUrl http://localhost:${nifi_stg_port}  --registryClientUrl http://localhost:${nifi_registry_port} --registryClientName PRD
echo "### Adding Registry Client to DEV"
./nifi-toolkit/bin/cli.sh nifi create-reg-client --baseUrl http://localhost:${nifi_dev_port}  --registryClientUrl http://localhost:${nifi_registry_port} --registryClientName PRD
