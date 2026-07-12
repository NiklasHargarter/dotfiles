for _cisco_vpn in /opt/cisco/secureclient/bin/vpn /opt/cisco/anyconnect/bin/vpn; do
  [[ -x $_cisco_vpn ]] && break
done
[[ -x $_cisco_vpn ]] || { unset _cisco_vpn; return; }

alias vpnup="$_cisco_vpn -s < ~/.vpn-creds"
alias vpndown="$_cisco_vpn disconnect"
alias vpnstat="$_cisco_vpn stats"
unset _cisco_vpn
