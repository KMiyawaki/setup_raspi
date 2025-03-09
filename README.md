# Setup Raspberry Pi

`Raspberry Pi 4`に`Ubuntu`をインストールして設定する手順。

## Ubuntu と LXDE のインストール

[`Raspberry Pi Imager`](https://www.raspberrypi.com/software/)では`Wifi`設定なしで`SD`カードに書き込む。
`OS`は`Ubuntu20.04 64bit`サーバを選択する。

有線`LAN`に接続し、起動後に以下を実行する。

```shell
sudo apt update
sudo apt upgrade
sudo apt autoremove -y
sudo apt install net-tools emacs git
sudo apt install -y lxde
# 途中でディスプレイマネージャを効かれた場合は lightdm を選択する。
sudo reboot
# ログイン時に`LXDE`を選択すること。
# 初回起動時にクリップボードアプリの history 保存について聞かれるので No にする。
```

ターミナルの色を変える。

![2025-02-18%20084812.png](./images/2025-02-18%20084812.png)

`/usr/share/lxde/wallpapers`から壁紙を選ぶ。

## 日本語化

```shell
sudo apt install -y language-pack-ja-base language-pack-ja fcitx-mozc
sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
```

「設定」「言語サポート」から日本語化設定を行う。

## 自動ログイン設定

```shell
sudo emacs /etc/lightdm/lightdm.conf.d/50-myconfig.conf -nw
```

以下を書き込む。ユーザ名が`pi`である前提。

```shell
[SeatDefaults]
autologin-user=pi
autologin-user-timeout=0
user-session=LXDE
```

## シャットダウン時の Stop job is running 防止

```shell
sudo cp /etc/systemd/system.conf /etc/systemd/system.conf.org
sudo emacs /etc/systemd/system.conf -nw
```

以下を設定する。

```shell
DefaultTimeoutStartSec=10s
DefaultTimeoutStopSec=10s
# DefaultTimeoutStopSec=10s # コメント のように設定値の後ろにコメントをつけてはいけない。
```

参考：[A stop job is running for session c1 of user...? What is this and how to avoid it?](https://www.reddit.com/r/archlinux/comments/5xnynk/a_stop_job_is_running_for_session_c1_of_user_what/)

## スワップ

```shell
./make_swap.sh
```

## VNC

```shell
./install_vnc.sh
```

## モニター、カメラ、シリアルポート、音声用設定

`config.txt`を編集する。

```shell
cd /boot/firmware/
sudo cp config.txt config.txt.org
sudo emacs config.txt -nw
# 以下の2行を最下段の[all]に貼り付けて保存する。
[all]

# The following settings are "defaults" expected to be overridden by the
# included configuration. The only reason they are included is, again, to
# support old firmwares which don't understand the "include" command.
start_x=1
gpu_mem=128
```

`usercfg.txt`を編集する。

```shell
cd /boot/firmware/
sudo cp usercfg.txt usercfg.txt.org
sudo emacs usercfg.txt -nw
# 以下の通り。
# Place "config.txt" changes (dtparam, dtoverlay, disable_overscan, etc.) in
# this file. Please refer to the README file for a description of the various
# configuration files on the boot partition.

dtoverlay=uart2
dtoverlay=uart5
dtoverlay=vc4-fkms-v3d
# dtoverlay=vc4-kms-v3d # この設定では音声出力できない。
disable_overscan=1

# over clock
over_voltage=6
arm_freq=2000
gpu_freq=700

[HDMI:0]
hdmi_drive=2
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt 1024 600 60 6 0 0 0

[HDMI:1]
hdmi_force_hotplug=1
hdmi_drive=2
hdmi_group=2
hdmi_mode=87
hdmi_cvt 1024 600 60 6 0 0 0
```

現在のところ`HDMI-0`、`HDMI-1`を同じ解像度にしている。  
もしも`HDMI-1`に解像度を指定しない、あるいは`HDMI-0`異なる解像度を指定すると、`HDMI-1`にモニターが接続されていなくてもその解像度が`HDMI-0`（ロボットの場合はタッチパネル）に適用されてしまう。

現在のタッチパネルは`1024x600`だが、それ以上の解像度が適用された場合、デスクトップ画面全体がモニタに入りきらないためアイコンが画面外に出てしまう。

一方、`[HDMI:1] hdmi_force_hotplug=1`を指定しなかった場合、電源投入後にモニターを`HDMI-1`に接続しても検出はできない。

## デュアルモニタ

一度別モニタを`HDMI-1`に接続し、タスクバーを作成する。
その後、`:~/.config/lxpanel/LXDE/panels/left`などというファイルが生成されているはずなので、そこに以下をペーストする。
これは最初から存在しているタスクバーの設定（`panel`というファイル）をほぼコピーしたものである。

違いは`monitor=1`の部分と`Plugin { type=tray`がないことである。
`Plugin { type=tray`はネットワーク設定などのアプレットが入っているが、これは複数モニタがあっても一つにしか表示できないようである。

```txt
Global {
  monitor=1
  edge=bottom
  align=left
  margin=0
  widthtype=percent
  width=100
  height=26
  transparent=0
  tintcolor=#000000
  alpha=0
  setdocktype=1
  setpartialstrut=1
  autohide=0
  heightwhenhidden=0
  usefontcolor=1
  fontcolor=#ffffff
  background=1
  backgroundfile=/usr/share/lxpanel/images/background.png
}
Plugin {
  type=space
  Config {
    Size=2
  }
}
Plugin {
  type=menu
  Config {
    image=/usr/share/lxde/images/lxde-icon.png
    system {
    }
    separator {
    }
    item {
      command=run
    }
    separator {
    }
    item {
      image=gnome-logout
      command=logout
    }
  }
}
Plugin {
  type=launchbar
  Config {
    Button {
      id=pcmanfm.desktop
    }
    Button {
      id=lxde-x-www-browser.desktop
    }
    Button {
      id=lxterminal.desktop
    }
    Button {
      id=oit_stop_all.desktop
    }
    Button {
      id=oit_save_map.desktop
    }
    Button {
      id=oit_capture.desktop
    }
  }
}
Plugin {
  type=space
  Config {
    Size=4
  }
}
Plugin {
  type=wincmd
  Config {
    Button1=iconify
    Button2=shade
  }
}
Plugin {
  type=space
  Config {
    Size=4
  }
}
Plugin {
  type=pager
  Config {
  }
}
Plugin {
  type=space
  Config {
    Size=4
  }
}
Plugin {
  type=taskbar
  expand=1
  Config {
    tooltips=1
    IconsOnly=0
    AcceptSkipPager=1
    ShowIconified=1
    ShowMapped=1
    ShowAllDesks=0
    UseMouseWheel=1
    UseUrgencyHint=1
    FlatButton=0
    MaxTaskWidth=150
    spacing=1
  }
}
Plugin {
  type=cpu
  Config {
  }
}
Plugin {
  type=volume
  Config {
    VolumeMuteKey=XF86AudioMute
    VolumeDownKey=XF86AudioLowerVolume
    VolumeUpKey=XF86AudioRaiseVolume
  }
}
Plugin {
  type=dclock
  Config {
    ClockFmt=%R
    TooltipFmt=%A %x
    BoldFont=0
    IconOnly=0
    CenterText=0
  }
}
Plugin {
  type=launchbar
  Config {
    Button {
      id=lxde-screenlock.desktop
    }
    Button {
      id=lxde-logout.desktop
    }
  }
}
```


`HDMI-2`をプライマリとして使うコマンド。

```shell
xrandr --output HDMI-2 --auto --primary --left-of HDMI-1
```

`HDMI-1`をプライマリとして使うコマンド。

```shell
xrandr --output HDMI-1 --auto --primary --left-of HDMI-2
```

## その他の設定

`PCManFM`ファイルマネージャの設定から、ショートカットダブルクリック時に選択肢を出さないように設定する。

![2025-02-16%20160737.png](./images/2025-02-16%20160737.png)

以下を`.bashrc`に追記して、音声が`HDMI`から出力されるようにする。

```shell
cd
emacs .bashrc -nw
# 最下段に以下を追記
pactl set-default-sink alsa_output.platform-bcm2835_audio.stereo-fallback
# 再起動する
# 設定結果を確認する
pactl info
・・・
デフォルトシンク: alsa_output.platform-bcm2835_audio.stereo-fallback # こうなっていることを確認
デフォルトソース: alsa_output.platform-bcm2835_audio.stereo-fallback.monitor
```

次のコマンドで音声出力を確認する。

```shell
sudo apt install alsa-utils
speaker-test -t wav -c 2
```

他に必要なソフトをインストールする。
- 軽量なエディタ`geany`。`Raspberry pi4`で`VS Code`を動かすのは重過ぎる。
- メモ帳代わりの`gedit`。
- 画像処理アプリの`gimp`。

```shell
sudo apt install -y geany gedit gimp
```
