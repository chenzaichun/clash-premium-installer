#!/bin/bash

cd "`dirname $0`"

INSTALL_DIR=/usr/local/bin
function assert() {
    "$@"

    if [ "$?" != 0 ]; then
    echo "Execute $@ failure"
    exit 1
    fi
}

function assert_command() {
    if ! which "$1" > /dev/null 2>&1;then
    echo "Command $1 not found"
    exit 1
    fi
}

function _install() {
    assert_command install
    assert_command iptables
    assert_command ip
    assert_command install

    if [ ! -d "/usr/lib/udev/rules.d" ];then
    echo "udev not found"
    exit 1
    fi

    if [ ! -d "/usr/lib/systemd/system" ];then
    echo "systemd not found"
    exit 1
    fi

    if [ ! -d "/sys/fs/cgroup/net_cls" ];then
    echo "cgroup not support net_cls"
    exit 1
    fi

    if [ ! -f "./clash-premium" ];then
    echo "Clash core not found."
    echo "Please download it from https://github.com/Dreamacro/clash/releases/tag/premium, and rename to ./clash"
    fi

    assert install -d -m 0755 /usr/lib/clash
    #assert install -d -m 0644 /srv/clash/

    assert install -m 0755 ./clash-premium ${INSTALL_DIR}/clash-premium

    assert install -m 0755 scripts/bypass-proxy-pid ${INSTALL_DIR}/bypass-proxy-pid
    assert install -m 0755 scripts/bypass-proxy ${INSTALL_DIR}/bypass-proxy

    assert install -m 0700 scripts/clean-tun.sh /usr/lib/clash/clean-tun.sh
    assert install -m 0700 scripts/setup-tun.sh /usr/lib/clash/setup-tun.sh
    assert install -m 0700 scripts/setup-cgroup.sh /usr/lib/clash/setup-cgroup.sh

    assert install -m 0644 scripts/clash.service /usr/lib/systemd/system/clash-premium.service
    assert install -m 0644 scripts/99-clash.rules /usr/lib/udev/rules.d/99-clash.rules

    echo "Install successfully"
    echo ""
    echo "Home directory on /srv/clash"
    echo ""
    echo "Use 'systemctl start clash' to start"
    echo "Use 'systemctl enable clash' to enable auto-restart on boot"

    exit 0
}

function _uninstall() {
    assert_command systemctl
    assert_command rm

    systemctl stop clash
    systemctl disable clash

    rm -rf /usr/lib/clash
    rm -rf /usr/lib/systemd/system/clash-premium.service
    rm -rf /usr/lib/udev/rules.d/99-clash.rules
    rm -rf ${INSTALL_DIR}/clash
    rm -rf ${INSTALL_DIR}/bypass-proxy-uid
    rm -rf ${INSTALL_DIR}/bypass-proxy

    echo "Uninstall successfully"

    exit 0
}

function _help() {
    echo "Clash Premiun Installer"
    echo ""
    echo "Usage: ./installer.sh [option]"
    echo ""
    echo "Options:"
    echo "  install      - install clash premiun core"
    echo "  uninstall    - uninstall installed clash premiun core"
    echo ""

    exit 0
}

case "$1" in
"install") _install;;
"uninstall") _uninstall;;
*) _help;
esac
