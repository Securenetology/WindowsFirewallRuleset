
# Firewall Parameters

Parameters and their values are not the same as they are displayed in Firewall GUI such as
GPO or Advanced Windows firewall.

Explain what is what by mapping powershell parameters to GUI display equivalents.

In addition, explanation of other parameters which are not self explanatory or well documented
and usually need googling out what they do.

## Table of contents

- [Firewall Parameters](#firewall-parameters)
  - [Table of contents](#table-of-contents)
  - [Port](#port)
    - [LocalPort/RemotePort](#localportremoteport)
    - [LocalPort TCP Inbound](#localport-tcp-inbound)
    - [LocalPort UDP Inbound](#localport-udp-inbound)
    - [LocalPort TCP Outbound](#localport-tcp-outbound)
  - [Address](#address)
    - [RemoteAddress](#remoteaddress)
  - [Interface](#interface)
    - [InterfaceType](#interfacetype)
    - [InterfaceAlias](#interfacealias)
  - [Users](#users)
  - [Edge traversal](#edge-traversal)
  - [Policy store](#policy-store)
  - [Application layer enforcement](#application-layer-enforcement)
  - [Unicast response](#unicast-response)
  - [Parameter value example](#parameter-value-example)
  - [Log file fields](#log-file-fields)
  - [Conversion of parameter direction](#conversion-of-parameter-direction)
    - [Outbound](#outbound)
    - [Inbound](#inbound)
  - [Hidden parameters](#hidden-parameters)
    - [StatusCode](#statuscode)
    - [PolicyDecisionStrategy](#policydecisionstrategy)
    - [ConditionListType](#conditionlisttype)
    - [ExecutionStrategy](#executionstrategy)
    - [SequencedActions](#sequencedactions)
    - [Profiles](#profiles)
    - [EnforcementStatus](#enforcementstatus)
    - [LSM](#lsm)
    - [Platforms](#platforms)
  - [UDP mapping](#udp-mapping)
    - [LocalOnlyMapping](#localonlymapping)
    - [LooseSourceMapping](#loosesourcemapping)

## Port

### LocalPort/RemotePort

- `Any` All Ports

### LocalPort TCP Inbound

- `RPCEPMap` RPC Endpoint Mapper
- `RPC` RPC Dynamic Ports
- `IPHTTPSIn` IPHTTPS

### LocalPort UDP Inbound

- `PlayToDiscovery` PlayTo Discovery
- `Teredo` Edge Traversal

### LocalPort TCP Outbound

- `IPHTTPSOut` IPHTTPS

## Address

- *Keywords can be restricted to IPv4 or IPv6 by appending a 4 or 6*
- Appending 4 or 6 to "Any" address is not valid

### RemoteAddress

- `Any` Any IP Address
- `LocalSubnet` Local Subnet
- `Internet` Internet
- `Intranet` Intranet
- `DefaultGateway` Default Gateway
- `DNS` DNS Servers
- `WINS` WINS Servers
- `DHCP` DHCP Servers
- `IntranetRemoteAccess` Remote Corp Network
- `PlayToDevice` PlayTo Renderers
- `<unknown>` Captive Portal Addresses

## Interface

### InterfaceType

- `Any` All interface types
- `Wired` Wired
- `Wireless` Wireless
- `RemoteAccess` Remote access

### InterfaceAlias

**NOTE:** Not fully compatible with interfaceType because interfaceType parameter has higher
precedence over InterfaceAlias, Mixing interfaceType with InterfaceAlias doesn't make sense,
except if InterfaceType is "Any", use just one of these two parameters.

```powershell
[WildCardPattern] ([string])
[WildCardPattern] ([string], [WildCardOptions])
```

## Users

- `Localuser` Authorized local Principals
- `<unknown>` Excepted local Principals
- `Owner` Local User Owner
- `RemoteUser` Authorized Users

## Edge traversal

- `Block` Allow edge traversal
- `Allow` Block edge traversal
- `DeferToUser` Defer to user / Defer allow to user
- `DeferToApp` Defer to application / Defer allow to application

## Policy store

1. Persistent store

   > Is what you see in Windows Firewall with Advanced security, accessed trough control panel or
  System settings.

   Example: `-PolicyStore PersistentStore`

2. GPO store:

    > is specified as computer name, and it is what you see in Local group policy, accessed trough
    secpol.msc or gpedit.msc

    Example: `-PolicyStore ([System.Environment]::MachineName])`

3. RSOP store:

    > Stands for "resultant set of policy" and is collection of all GPO stores that apply to local computer.\
    > This applies to domain computers, on home computer RSOP consists of single local GPO (group
    policy object)

    Example: `-PolicyStore RSOP`

4. Active store:

    > Active store is collection (sum) of Persistent store and all GPO stores (RSOP) that apply to
    local computer. in other words it's a master store.

    Example: `-PolicyStore ActiveStore`

5. SystemDefaults:

    > Read-only store contains the default state of firewall rules that ship with Windows Server 2012.

6. StaticServiceStore:

    > Read-only store contains all the service restrictions that ship with Windows Server 2012.

7. ConfigurableServiceStore:

    > This read-write store contains all the service restrictions that are added for third-party services.
    > In addition, network isolation rules that are created for Windows Store application containers
    will appear in this policy store.

For more information see [New-NetFirewallRule](https://docs.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=winserver2012r2-ps&redirectedfrom=MSDN)

## Application layer enforcement

The meaning of this parameter value depends on which parameter it is used:

1. `"*"` Applies to: services only OR application packages only
2. `Any` Applies to: all programs AND (services OR application packages)

Both of which are applied only if a packet meet the specified rule conditions

## Unicast response

The option "Allow unicast response to multicast or broadcast traffic"

Prevents this computer from receiving unicast responses to its outgoing multicast or broadcast messages.

If you set this setting to "Yes (default)", and this computer sends a multicast or broadcast message
to other computers, Windows Defender Firewall waits as long as three seconds for unicast responses
from the other computers and then blocks all later responses.

Otherwise if you set the option to "No", Windows Defender Firewall blocks the unicast responses
sent by those other computers.

"Not configured" is equivalent to "Yes (default)" as long as control panel firewall does not
override this option.

**NOTE:** This setting has no effect if the unicast message is a response to a DHCP broadcast message
sent by this computer.
Windows Defender Firewall always permits those DHCP unicast responses.
However, this policy setting can interfere with the NetBIOS messages that detect name conflicts.

## Parameter value example

This is how parameters are used on command line, most of them need to be enclosed in quotes if
assigned to variable first.

```none
Name                  = "NotePadFirewallRule"
DisplayName           = "Firewall Rule for program.exe"
Group                 = "Program Firewall Rule Group"
Ensure                = "Present"
Enabled               = True
Profile               = "Domain, Private"
Direction             = Outbound
RemotePort            = 8080, 8081
LocalPort             = 9080, 9081
Protocol              = TCP
Description           = "Firewall Rule for program.exe"
Program               = "c:\windows\system32\program.exe"
Service               = WinRM
Authentication        = "Required"
Encryption            = "Required"
InterfaceAlias        = "Ethernet"
InterfaceType         = Wired
LocalAddress          = 192.168.2.0-192.168.2.128, 192.168.1.0/255.255.255.0, 10.0.0.0/8
LocalUser             = "O:LSD:(D;;CC;;;S-1-15-3-4)(A;;CC;;;S-1-5-21-3337988176-3917481366-464002247-1001)"
Package               = "S-1-15-2-3676279713-3632409675-756843784-3388909659-2454753834-4233625902-1413163418"
Platform              = "6.1"
RemoteAddress         = 192.168.2.0-192.168.2.128, 192.168.1.0/255.255.255.0, 10.0.0.0/8
RemoteMachine         = "O:LSD:(D;;CC;;;S-1-5-21-1915925333-479612515-2636650677-1621)(A;;CC;;;S-1-5-21-1915925333-479612515-2636650677-1620)"
RemoteUser            = "O:LSD:(D;;CC;;;S-1-15-3-4)(A;;CC;;;S-1-5-21-3337988176-3917481366-464002247-1001)"
DynamicTransport      = ProximitySharing
EdgeTraversalPolicy   = Block
IcmpType              = 51, 52
IcmpType              = 34:4
LocalOnlyMapping      = $true
LooseSourceMapping    = $true
OverrideBlockRules    = $true
Owner                 = "S-1-5-21-3337988176-3917481366-464002247-500"
```

## Log file fields

Their meaning in order how they appear in firewall log file:

`#Version:`

- Displays which version of the Windows Firewall security log is installed

`#Software:`

- Displays the name of the software creating the log

`#Time:`

- Indicates that all of the timestamps in the log are in local time

`#Fields:`

- Displays a static list of fields that are available for security log entries, as follows:

`date`

- Displays the year, month, and day that the recorded transaction occurred

`time`

- Displays the hour, minute, and seconds at which the recorded transaction occurred

`action`

- Displays which operation was observed by Windows Firewall
- The options available are OPEN, OPEN-INBOUND, CLOSE, DROP, and INFO-EVENTS-LOST

`protocol`

- Displays the protocol that was used for the communication
- The options available are TCP, UDP, ICMP, and a protocol number for packets

`src-ip`

- Displays the source IP address (the IP address of the computer attempting to establish communication)

`dst-ip`

- Displays the destination IP address of a communication attempt

`src-port`

- Displays the source port number of the sending computer
- Only TCP and UDP display a valid src-port entry
- All other protocols display a src-port entry of `-`

`dst-port`

- Displays the port number of the destination computer
- Only TCP and UDP display a valid dst-port entry
- All other protocols display a dst-port entry of `-`

`size`

- Displays the packet size, in bytes.

`tcpflags`

- Displays the TCP control flags found in the TCP header of an IP packet:\
`Ack` Acknowledgment field significant\
`Fin` No more data from sender\
`Psh` Push function\
`Rst` Reset the connection\
`Syn` Synchronize sequence numbers\
`Urg` Urgent Pointer field significant

`tcpsyn`

- Displays the TCP sequence number in the packet

`tcpack`

- Displays the TCP acknowledgement number in the packet

`tcpwin`

- Displays the TCP window size, in bytes, in the packet

`icmptype`

- Displays a number that represents the Type field of the ICMP message

`icmpcode`

- Displays a number that represents the Code field of the ICMP message

`info`

- Displays an entry that depends on the type of action that occurred
- For example, an INFO-EVENTS-LOST action will result in an entry of the number of events that occurred\
but were not recorded in the log from the time of the last occurrence of this event type.

`path`

- Displays the direction of the communication
- The options available are SEND, RECEIVE, FORWARD, and UNKNOWN

For more information see [Interpreting the Windows Firewall Log](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc758040(v=ws.10))

## Conversion of parameter direction

Following are mappings between log file, firewall UI and PowerShell parameters.

The true meaning of source/destination is not straightforward, explanation is given in section above
and here is how to convert this info to other firewall/traffic contexts.

### Outbound

```none
Log         GUI               PowerShell
src-ip      Local Address     LocalAddress
dst-ip      Remote Address    RemoteAddress
src-port    Local Port        LocalPort
dst-port    Remote Port       RemotePort
```

### Inbound

```none
Log         GUI               PowerShell
src-ip      Remote Address    RemoteAddress
dst-ip      Local Address     LocalAddress
src-port    Remote Port       RemotePort
dst-port    Local Port        LocalPort
```

## Hidden parameters

Following hidden parameters are part of CIM class and are not visible in firewall UI

### StatusCode

The detailed status of the rule, as a numeric error code.\
A value of `65536` means `STATUS_SUCCESS` or `NO_ERROR`, meaning there is no problem with this rule.

### PolicyDecisionStrategy

This field is ignored

### ConditionListType

This field is ignored

### ExecutionStrategy

This field is ignored.

### SequencedActions

This field is ignored.

### Profiles

Which profiles this rule is active on

The meaning of a value is as follows:\
**NOTE:** Combinations sum up, ex. a value of 5 means "Public" and "Domain"

```none
Any     = 0
Public  = 4
Private = 2
Domain  = 1
```

### EnforcementStatus

If this object is retrieved from the ActiveStore, describes the current enforcement status of the rule.

```none
0 = Invalid
1 = Full
2 = FirewallOffInProfile
3 = CategoryOff
4 = DisabledObject
5 = InactiveProfile
6 = LocalAddressResolutionEmpty
7 = RemoteAddressResolutionEmpty
8 = LocalPortResolutionEmpty
9 = RemotePortResolutionEmpty
10 = InterfaceResolutionEmpty
11 = ApplicationResolutionEmpty
12 = RemoteMachineEmpty
13 = RemoteUserEmpty
14 = LocalGlobalOpenPortsDisallowed
15 = LocalAuthorizedApplicationsDisallowed
16 = LocalFirewallRulesDisallowed
17 = LocalConsecRulesDisallowed
18 = NotTargetPlatform
19 = OptimizedOut
20 = LocalUserEmpty
21 = TransportMachinesEmpty
22 = TunnelMachinesEmpty
23 = TupleResolutionEmpty
```

### LSM

One might think this has something to do with "Local Session Manager" but it's a shorthand for
"Loose Source Mapping", the meaning is the same as "LooseSourceMapping" property.

### Platforms

Specifies which platforms the rule is applicable on.\
If null, the rule applies to all platforms (the default).\
Each entry takes the form `Major.Minor+`

If `+` is specified, then it means that the rule applies to that version or greater.\
`+` may only be attached to the final item in the list.

For more information see [MSFT_NetFirewallRule class](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/wfascimprov/msft-netfirewallrule)
or [Second link](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/legacy/jj676843(v=vs.85))

## UDP mapping

Applies only to UDP.\
UDP traffic is inferred by checking the following fields:

1. local address
2. remote address
3. protocol,
4. local port
5. remote port

TODO: Rules which do not specify some of these fields, how does the above apply then?\
ex. only to new connections or existing connections. (statefull/stateless filtering)

### LocalOnlyMapping

Whether to group UDP packets into conversations based only upon the local address and port.

If this parameter is set to True, then the remote address and port will be ignored when inferring
remote sessions.\
Sessions will be grouped based on local address, protocol, and local port.

### LooseSourceMapping

Whether to group UDP packets into conversations based upon the local address, local port,
and remote port.

If set, the rule accepts packets incoming from a host other than the one the packets were sent to.

TODO: Explain why this parameter can't be specified for inbound rule

For more information see [New-NetFirewallRule](https://docs.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=winserver2012r2-ps&redirectedfrom=MSDN)