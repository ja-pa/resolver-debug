#!/bin/bash

if [ -f ".ssh_passwd" ]; then

	sshpass -f .ssh_passwd	ssh root@192.168.1.1 'mkdir -p /usr/lib/lua/luci/controller/myapp'
	sshpass -f .ssh_passwd	ssh root@192.168.1.1 'mkdir -p /usr/lib/lua/luci/view/myapp-mymodule'
	sshpass -f .ssh_passwd	ssh root@192.168.1.1 'mkdir -p /usr/lib/lua/luci/model/cbi/myapp-mymodule'

	sshpass -f .ssh_passwd scp src/new_tab.lua root@192.168.1.1:/usr/lib/lua/luci/controller/myapp/
	sshpass -f .ssh_passwd scp src/view_tab.htm root@192.168.1.1:/usr/lib/lua/luci/view/myapp-mymodule/
	sshpass -f .ssh_passwd scp src/cbi_tab.lua root@192.168.1.1:/usr/lib/lua/luci/model/cbi/myapp-mymodule/
	sshpass -f .ssh_passwd scp src/cbi_file root@192.168.1.1:/etc/config/
	sshpass -f .ssh_passwd scp src/resolver-debug.py root@192.168.1.1:/usr/libexec/rpcd/

	sshpass -f .ssh_passwd ssh root@192.168.1.1 '/etc/init.d/lighttpd restart'
	echo "Copy done!"
else
	echo "Error - password file not found!"
	echo "Please make file .ssh_passwd with ssh password"
fi

