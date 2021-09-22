# Splunk Cluster in a box

Builds a splunk instance from scratch, was something I built a while back when doing a thing. See also [yaleman/splunk_cluster_apps](https://github.com/yaleman/splunk_cluster_apps) for the app deployment side and [yaleman/splunk_cluster_indexers](https://github.com/yaleman/splunk_cluster_apps) for the indexer clustering config.

 - uses cloudflare for user-facing things
 - smartstore storage backend
 - hasn't been tested since I cleaned it all up, but from what I can tell, it should just work

# DO NOT JUST RUN TERRAFORM APPLY - RUNTERRAFORM.SH DOES IT RIGHT

Need help? [Log an issue](https://github.com/yaleman/splunk_cluster_core/issues)

# DO NOT JUST RUN THIS IN GENERAL - you really need to read through all of it to understand how it all works. 😁 I havne'


Steps for use:

1. Fork this, then search for TODO or CHECKTHIS because you'll need to tweak those things.
2. Update the config in `locals.tf`
2. Also update all the variables in `variables.tf`
3. Create the required SSM parameters. The names are in `aws_ssm_parameter.tf`.
4. On the first run for an account you will likely have to log into the AWS marketplace and accept Splunk's EULA.
5. Don't just run `terraform apply` - run the command un `runterraform.sh` - the `cloudflare` and `letsencrypt` providers are special.

# Certificates

`update_certificates.sh` needs to be run regularly to keep the LetsEncrypt certs up to date.

This needs AWS credentials with sufficient access to update the Route 53 zone for DNS validation and also the SSM entries.

# Cluster notes

If you replace an index cluster peer, removing the old one is done by logging into the cluster master and doing:

    /opt/splunk/bin/splunk remove cluster-peers -peers 6FFCB192-0B2E-44A8-A41D-F04B40209611,B3F9651B-F884-4AA3-8957-A9397F09FB08

Where the last bit are the GUIDs from `/en-US/manager/system/clustering` on the cluster master.

# DNS

This is designed to be set up in a standalone base domain (`variables.tf` -> `base_domain`) eg splunk.example.com, which you delegate from your primary domain. This is because there's a bunch of DNS configuration done for things like certs and load balancers.

# Licensing

Put the license file in the AWS SSM parameter `/application/splunk/licensing/file1` (`aws_ssm_parameter.tf`) and it'll be deployed to the clustermaster on build (`instance_clustermaster.tf`). This means a cluster master rebuild for license updates, this could be automated through scripting (similar to the cert puller script) but hasn't been yet.

# Search head

DON'T MESS WITH THIS IT'S A SPECIAL FLOWER...

... because blaergh.

Additional volumes should be mapped as follows:

| volume | mount point | why? | 
| --- | --- | --- |
| /dev/sdu1 | `/opt/splunk/etc/users` | user-specific settings, searches and other things |
| /dev/sdp1 | `/opt/splunk/etc/apps` | search head apps |

The fstab is this as of 2020-05-25

```
UUID=add39d87-732e-4e76-9ad7-40a00dbb04e5     /           xfs    defaults,noatime  1   1
/dev/sdp1 /opt/splunk/etc/apps ext4 defaults,noatime 1 1
/dev/sdu1 /opt/splunk/etc/users ext4 defaults,noatime 1 1
```

# Transferring data from an old host

Example for security "cold" and "warm" data, this was ... for reasons.

`rsync --bwlimit=20480 -avz /var/log/splunk*/security/*db/* migrator(0|1).example.com:/splunkdata/security_archive/db/`

# System Auth

# enabling authentication between deployment clients and the DS

Deployment server's restmap.conf, set

    [broker:broker]
    requireAuthentication = true

## authentication for clients doing indexer discovery

outputs.conf uses pass4SymmKey when doing discovery, stored in an SSM parameter

# Making cloudflare argo work

Relatively simple, it should be installed and configured for the local host, you just need to register it with Cloudflare if it breaks. The clustermaster has all the config to make it go, pulls the auth tokens and certs and such from secrets manager. By the time you read this, looking for help, cloudflared will have changed enough to need you to learn it, but here's some old info:

    sh-4.2$ sudo /usr/local/bin/cloudflared login
    Please open the following URL and log in with your Cloudflare account:

    https://dash.cloudflare.com/argotunnel?callback=https%3A%2F%2Flogin.argotunnel.com%2FlC<snip>

    Leave cloudflared running to download the cert automatically.
    You have successfully logged in.
    If you wish to copy your credentials to a server, they have been saved to:
    /root/.cloudflared/cert.pem
    sh-4.2$ sudo mv /root/.cloudflared/cert.pem /etc/cloudflared/
    sh-4.2$ sudo systemctl enable cloudflared
    sh-4.2$ sudo systemctl start cloudflared


## This needs AWS secrets manager configurations too

Tunnel file and certs are in:

 - `cloudflared_${SPLUNK_ROLE}_tunnelfile`
 - `cloudflared_${SPLUNK_ROLE}_cert`