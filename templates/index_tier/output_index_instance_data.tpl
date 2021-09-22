
###############################
# ${instance_type} Instance Data
###############################
%{ for instance in instances }
Interface URL: http://${instance.public_dns}:8000

Splunk Login Details
Username: admin
Password: SPLUNK-${instance.id}

SSH endpoint: ec2-user@${instance.public_dns}
%{ endfor }