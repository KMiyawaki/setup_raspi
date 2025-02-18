#!/bin/bash

sudo apt-get install -y x11vnc
sudo x11vnc -storepasswd /etc/.vncpasswd
sudo touch /etc/systemd/system/x11vnc.service
sudo cat > /etc/systemd/system/x11vnc.service << EOF
[Unit]
Description=x11vnc (Remote access)
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -display :0 -rfbauth /etc/.vncpasswd -rfbport 5900 -forever -loop -noxdamage -repeat -shared
ExecStop=/bin/kill -TERM $MAINPID
ExecReload=/bin/kill -HUP $MAINPID
KillMode=control-group
Restart=on-failure

[Install]
WantedBy=graphical.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable x11vnc
sudo systemctl start x11vnc
