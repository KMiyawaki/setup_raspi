#!/bin/bash

sudo apt-get install -y x11vnc
sudo x11vnc -storepasswd /etc/.vncpasswd
sudo cp ./x11vnc.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable x11vnc
sudo systemctl start x11vnc
