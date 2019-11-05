# playhooky

Send software version release data to IFTTT webhooks

## Build  
1. Run ```configure```  
2. Run ```make```  

## Install  
1. Run ```sudo make install```  
2. For each check install a crontab entry for ```<INSTALLDIR>/bin/<CHECK>```

## Inst

## Prebuild Checks  
| Software | Webhook Name |  
| --- | --- |  
| Debian Linux | debversion |  
| Github Enterprise | gheversion |  
| Apache httpd | httpdversion |  
| Linux Kernel | kernversion |  
| Monit | monitversion |  
| Net-SNMP | snmpversion |  
| OpenSSH | sshversion |  
| OpenSSL | sslversion |  
| Core Linux | tcversion | 
| PHP 5 | php5version |  
| PHP 7 | php7version |  

