[[ -x /opt/cisco/secureclient/bin/vpn ]] || return

alias vpnup='/opt/cisco/secureclient/bin/vpn -s < ~/.vpn-creds'
alias vpndown='/opt/cisco/secureclient/bin/vpn disconnect'
alias vpnstat='/opt/cisco/secureclient/bin/vpn stats'
