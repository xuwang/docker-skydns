#Build A SkyDNS Docker Image

*See [SkyDNS](https://github.com/skynetservices/skydns/tree/master)
*See [Etcd](https://github.com/coreos/etcd)
*See [Create The Smallest Possible Docker Container](http://blog.xebia.com/2014/07/04/create-the-smallest-possible-docker-container/)

###Build image:

	./build

You should see some output:

    ... 
    Successfully built c2a85185ca6f
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    skydns              7025dba3834f        c2a85185ca6f        1 minutes ago      6.074 MB
    skydns              latest              c2a85185ca6f        1 minutes ago      6.074 MB
    skybuild            latest              7a7ad6bdca60        2 minutes ago      839.4 MB
    
###Run SkyDNS container:

SkyDNS requires [Etcd](https://github.com/coreos/etcd) running on your system.

Set SkyDNS configuration in etcd:

	etcdctl set /skydns/config '{"domain":"skydns.local.","dns_addr":"127.0.0.1:53","ttl":3600, "nameservers": ["8.8.8.8:53","8.8.4.4:53"]}'
		
Run SkyDNS service docker:

	docker run --name skydns -p 5353:53 skydns:latest skydns -machines="127.0.0.1:4001"

Route dns port 53 to 5353:

    sudo /sbin/iptables -D INPUT -p udp --dport 5333 -j ACCEPT
    sudo /sbin/iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5333
    sudo /sbin/iptables -A INPUT -p udp --dport 5333 -j ACCEPT
    sudo /sbin/iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5333
    sudo /sbin/iptables -D INPUT -p udp --dport 5333 -j ACCEPT
    sudo /sbin/iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5333

Add 127.0.0.1 to /etc/resol.conf:

    sudo echo "nameserver 127.0.0.1" >> /etc/resolv.conf

Register a CNAME in SkyDNS:

    etcdctl set /skydns/local/skydns/mygoogle '{"host":"www.google.com"}'
    
    ping mygoogle.skydns.local


### Tell Docker to use SkyDNS:

    /usr/bin/docker -d --dns=<docker0_ip> --dns-search=skydns.local

###Install skydns binary to target:

If you just want to get standalone skydns binary, here copy it from skybuild container:

	docker run --rm -v /usr/local/bin:/target skybuild cp /gopath/bin/skydns target
	
