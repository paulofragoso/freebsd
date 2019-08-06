# freebsd

Files to help to install FreeBSD on Bare Metal or VMs used at NLINK ISP.

It works in this way:

Step 1: Boot from Memstick or CD disc 1 and selects Live CD.

Setp 2: Log in with root user without password.

Setp 3: Setup your NIC with internet access. If you have dhcp server can do it in this way:

	dhclient em0

Setp 3: Change directory to /tmp and download sshd_live.sh from this project.

	cd /tmp
	fetch https://github.com/paulofragoso/freebsd/blob/master/sshd_live.sh

Setp 4: Runs this script:

	sh sshd_live.sh
