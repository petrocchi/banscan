# banscan
banport - Easy and fast TCP/UDP port scanner for penetration test

## Help command:
```s
bar@kali:~$ ./banscan.rb -h

banport <t|u> <host> [OPTION]
banport - Easy TCP/UDP port scanner for penetration test

  <t|u>			TCP or UDP scan
  <host>		Host or IP target

[OPTION]
  empty			Default range ports (1 to 1024)
  port			Singole port
  port,port		Many ports (21,22,23,25,80,139,443,445,3389)
  port-port		Range of ports (21-445)

Examples:
  ./banport t localhost
  ./banport t 127.0.0.1 21,25,80,139,443,445,3389
  ./banport u 192.168.1.1 13-1000

bar@kali:~$
```


## Examples:
```s
bar@kali:~$ ./banscan.rb t 192.168.1.6
[+] banscan start to (192.168.1.6) on port from 1 to 1024

22/tcp         open
23/tcp         open
37/tcp         open
113/tcp        open
139/tcp        open
445/tcp        open

[+] Finish
bar@kali:~$

bar@kali:~$ ./banscan.rb u 192.168.1.6
[+] banscan start to (192.168.1.6) on port from 1 to 1024

37/udp         open
68/udp         filtered|open
137/udp        filtered|open
138/udp        filtered|open
512/udp        filtered|open
817/udp        filtered|open

[+] Finish
bar@kali:~$

```
