
# Security and privacy

This document provides incomplete suggestions on how to have control over your online privacy and
how to maximize security of a computer system.

## Table of contents

- [Security and privacy](#security-and-privacy)
  - [Table of contents](#table-of-contents)
  - [The difference between security and privacy](#the-difference-between-security-and-privacy)
  - [Security suggestions](#security-suggestions)
    - [User standard user account](#user-standard-user-account)
    - [Digitally signed and trusted software](#digitally-signed-and-trusted-software)
    - [Trusted and encrypted web sites](#trusted-and-encrypted-web-sites)
    - [Password manager](#password-manager)
    - [Email client and service](#email-client-and-service)
    - [Antivirus and firewall](#antivirus-and-firewall)
    - [Web browser](#web-browser)
    - [Software updates](#software-updates)
    - [Separate account or computer](#separate-account-or-computer)
    - [Encryption](#encryption)
    - [Backup](#backup)
  - [Privacy suggestions](#privacy-suggestions)
    - [VPN or proxy](#vpn-or-proxy)
    - [DNS encryption](#dns-encryption)
    - [Browser extensions](#browser-extensions)
  - [Additional research](#additional-research)

## The difference between security and privacy

Both security and privacy are important in the digital world.

Privacy refers to the control that you have over your personal information and how that information
is used.
Personal information is any information that can be used to determine your identity such as email,
Credit card or bank details, home address, birthdate etc.
Personal information may also refer to hardware ID's, IP address, browsing habits etc. which if
gained access to may uniquely identify your system.

Security, on the other hand, refers to how your personal information is protected.\
Security generally refers to the prevention of unauthorized access of data,
often involving protection against hackers or cyber criminals.

In regard to Windows Firewall Ruleset, an example of privacy issue would be a firewall rule or
portion of source code which leaks yours or someones else's personal information.\
An example of security issue would be a firewall rule or portion of source code which let's an
attacker compromise yours or someones else's system.\
A security or privacy issue may also be related to documentation in this repository such as
outdated information or suggestions concerning security or privacy.

[Table of Contents](#table-of-contents)

## Security suggestions

### User standard user account

Using standard (non Administrative) Windows account for almost all use.\
Administrative account should be used for administration only, if possible offline.

Following site explains how to create local (standard) account:\
[Create a local user or administrator account in Windows][local account]

[Table of Contents](#table-of-contents)

### Digitally signed and trusted software

Installing and running only digitally signed software, and only those publishers you trust.\
Installing cracks, warez and similar is the most common way to let hackers in.

Following site explains [How to verify Digital Signatures of programs in Windows][digital signature]

[Table of Contents](#table-of-contents)

### Trusted and encrypted web sites

Visit only known trusted web sites, preferably HTTPS, and check links before clicking them.\
To visit odd sites and freely click around do it in isolated browser session or virtual machine

How to configure isolated browser session depends on your web browser.\
For MS-Edge following site explains how to get started:\
[Microsoft Edge support for Microsoft Defender Application Guard][app guard]

If you browser doesn't support isolated browser session an alternative is to use virtual machine.\
Following site explains how to get started with Hyper-V in Windows:\
[Install Hyper-V on Windows 10][hyper-v]

[Table of Contents](#table-of-contents)

### Password manager

Use password manager capable of auto typing passwords and with the support of virtual keyboard.\
Don't use hardware keyboard to type passwords.
Your passwords should meet length and complexity requirements.\
Never use same password to log in to multiple places, use unique password for each login.

Recommended password manager is PasswordSafe:\
[Password Safe][pwsafe]

More about the author of this program:\
[Schneier on Security - Password Safe][schneier]

[Table of Contents](#table-of-contents)

### Email client and service

Don't let your email client or web interface auto load email content.\
Configure your mail client to be restrictive, also important not to open attachments you don't
recognize or didn't ask for.

Recommended email service list:\
[Privacy-Conscious Email Services][prxbx]

Suggested email service (from the list):\
[Proton mail][proton mail]

[Table of Contents](#table-of-contents)

### Antivirus and firewall

Never disable antivirus or firewall except to troubleshoot issues.\
Btw. Troubleshooting doesn't include installing software or visiting some web site.

Suggested anti virus:\
[Windows defender][defender]

Suggested firewall:\
[Windows Defender Firewall with Advanced Security][firewall]\
Of course with ruleset from this repository.

[Table of Contents](#table-of-contents)

### Web browser

Protect your web browser maximum possible by restrictively adjusting settings, and
avoid using addons except one to block ads, which is known to be trusted by online community.

Suggested web browsers are subjective and it depends a lot on how much speed is one willing to trade
for security, what matters most is to use the one which receives regular updates,
most mainstream web browsers do.

It's also important to configure your web browser properly, one example of browser configuration is
following web site: [Securing Your Web Browser][secure browser]

[Table of Contents](#table-of-contents)

### Software updates

Keep your operating system, anti virus and web browser patched maximum possible, that means checking
for updates on daily basis for these essential programs.

OS, AV and browsers are most essential to be up to date, but on regular basis you also want to
update the rest of software on your computer, especially networking programs.

[Table of Contents](#table-of-contents)

### Separate account or computer

High value data and larger financial transactions should be performed on separate computer or user
account whose only purpose is to do this and nothing else, and to keep valueable data protected
away from network.

[Table of Contents](#table-of-contents)

### Encryption

Encrypt your valueable hard drives or individual files, for computers or user accounts such as those
which are used for special purposes like transaction or online purchases this is essential.

Suggested software for file and email encryption is [Gpg4win][gpg4win]\
Suggested software for disk encryption is subjective.

[Table of Contents](#table-of-contents)

### Backup

Always keep a backup of everything on at least 1 drive that is offline and away from online machine.
If you have to bring it online, take down the rest of network.

Suggestion of backup software is subjective, preferred method is external hard drive or separate computer.

[Table of Contents](#table-of-contents)

## Privacy suggestions

When it comes to privacy, briefly, there are 2 very different defense categories:

- Hide your online activity, is what people usually refer to when talking about "privacy".\
This relates to data such as hardware ID's, browser fingerprinting, IP address etc.

- Prevent identity theft, refers to your personal information which could identify you.\
This related to data such as credit card number, home address, phone number etc.

[Table of Contents](#table-of-contents)

### VPN or proxy

When you connect to internet your computer is assigned a unique IP address, and likewise every other
computer or server on the internet has it's own IP address, that's how computers and servers
communicate over the internet.\

By having someones IP a potential attacker can determine ones approximate geographical location as
well as scan their IP for vulnerabilities which can help to gain access to remote system.

VPN or proxy is used to hide your real IP from the endpoint to which you connect, such as a web
server or game server.

If somehow you end up on malicious server an attacker behind such a server might scan your IP to see
possibilities to compromise your system or privacy

By using VPN or proxy you do not connect directly to an endpoint but instead over VPN or proxy server.
By using VPN or proxy a potential attacker will have difficulty scanning your IP or determining your
location.

However VPN or proxy is not recommended for all scenarios and in some cases it may be dangerous,
for ex. connecting to your bank is better done directly because VPN or proxy server might as well be
malicious or there could be a bad employ working at VPN server watching for traffic going over VPN.

Another downsite to using VPN or proxy is that your internet connection will be slower.

One example where VPN is perfectly useful however is to avoid censorship, for example some sites
might be restricted for your country, by using a proxy it would look as if you connect from some
other country possibly not restricted and this would let you circumvent the restriction and access
the site.

Another example where VPN or proxy proves useful is to avoid an IP ban.\
However major benefit of using VPN and proxy is privacy because it hides your online identity,
allowing you to browse the internet anonymously.

It's difficult to suggest VPN since VPN's aren't free and proxy services which you can find online
aren't to be trusted.\
Therefore suggested software for VPN or proxy that is free is [Psiphon][psiphon]

Psiphon is a standalone executable which doesn't require elevation, it has servers world wide and
you're able to choose from a set of countries in UI.

[Table of Contents](#table-of-contents)

### DNS encryption

When you wish to connect to some server such as microsoft.com your computer needs to resolve
"microsoft.com" into an IP address which the computer understands.\
You computer does this by contacting a DNS server such as google DNS, your computer then stores the
IP address into local cache so that it doesn't need to contact DNS server again for subsequent queries.

Your ISP (Internet Service Provider) or any other intermediate attacker might watch over your DNS
queries and harvest your browsing habits, which is a hit to privacy.

By using DNS encryption this can be prevented.\
DNS encryption works by configuring computer to query DNS server which supports DNS encryption.

You only have to be careful to use DNS server which is trusted and one which provides maximum security
and privacy, this means servers which don't collect logs and supports `DNSSEC`.

DNS encryption is supported by some web browsers and even OS's however not all have this functionality.\
Suggested DNS encryption software is open source [Simple DNSCrypt][dnscrpyt] which is a UI frontend
for dnscrypt-proxy which ships with Simple DNSCrypt.

[Table of Contents](#table-of-contents)

### Browser extensions

Some browser extensions are essential for privacy, there are extensions which automatically handle
cookies, hide adds, switch to HTTPS, prevent tracking and few other features which help to guard
your online privacy.

You only need to ensure to use trusted extensions, preferably open source, those with positive
reviews and those which hang around for long time.

Common recommendation is to minimize amount of extensions in your browser as much as possible,
because no matter how trusted an extension is you will have to allow it to access some of your data.\
By minimizing amount of extensions you reduce the risk or installing the wrong one.

Suggested browser extensions are:

1. [uBlock Origin][ublock]
2. [HTTPS Everywhere][https]
3. [Cookies Auto Delete][cad]

[Table of Contents](#table-of-contents)

## Additional research

Following web sites are good starting point for additional research:

- [PRISM ⚡ BREAK][prism break]

[Table of Contents](#table-of-contents)

[digital signature]: https://www.ghacks.net/2018/04/16/how-to-verify-digital-signatures-programs-in-windows "Visit ghacks.net"
[local account]: https://support.microsoft.com/en-us/windows/create-a-local-user-or-administrator-account-in-windows-20de74e0-ac7f-3502-a866-32915af2a34d
[app guard]: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-security-windows-defender-application-guard
[hyper-v]: https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v
[pwsafe]: https://pwsafe.org/index.shtml
[schneier]: https://www.schneier.com/academic/passsafe/
[prxbx]: https://prxbx.com/email
[proton mail]: https://proton.me/mail
[defender]: https://www.microsoft.com/en-us/windows/comprehensive-security
[firewall]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/windows-firewall-with-advanced-security
[gpg4win]: https://www.gpg4win.org/
[psiphon]: https://www.psiphon.onl/windows
[dnscrpyt]: https://simplednscrypt.org
[ublock]: https://github.com/gorhill/uBlock
[cad]: https://github.com/Cookie-AutoDelete/Cookie-AutoDelete
[https]: https://www.eff.org/https-everywhere
[secure browser]: https://www.cisa.gov/uscert/publications/securing-your-web-browser
[prism break]: https://prism-break.org/en/
