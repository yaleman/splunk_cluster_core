
echo "Creating the service for update_servername.sh"

echo "Writing /opt/update_servername.sh"
echo "${update_servername_file}" | base64 -d > /opt/update_servername.sh

chmod +x /opt/update_servername.sh

# check if systemd exists (7.x splunk doesn't have it)

if [ -f /bin/systemctl ]; then
    
    cat > /etc/systemd/system/splunk_update_servername.service <<- 'EOM'
[Unit]
Description=Rewrites server.conf to replace the server name

[Service]
Type=oneshot
ExecStart=/opt/update_servername.sh

[Install]
WantedBy=multi-user.target

EOM

    echo "Forcing splunk to wait for servername fixer"
    # create the 'service.requires' folder
    mkdir -p /etc/systemd/system/Splunkd.service.requires 
    # put the service thing in the requires folder
    ln -s /etc/systemd/system/splunk_update_servername.service /etc/systemd/system/Splunkd.service.requires

    systemctl daemon-reload
    systemctl enable splunk_update_servername
    sytemctl start splunk_update_servername
else
    # init-based platform
    echo "Creating symlink to update_servername in /etc/init.d"
    ln -s /opt/update_servername.sh /etc/init.d/update_servername
    echo "Adding update_servername to init"
    chkconfig --add update_servername

    /etc/init.d/update_servername
fi
echo "Done creating the service for update_servername.sh"
