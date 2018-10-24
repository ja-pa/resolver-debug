local util = require "luci.util"
m = Map("cbi_file", translate("First Tab Form"), translate("Please fill out the form below")) -- cbi_file is the config file in /etc/config
d = m:section(TypedSection, "info", "Part A of the form")  -- info is the section called info in cbi_file
a = d:option(Value, "name", "Name"); a.optional=false; a.rmempty = false;  -- name is the option in the cbi_file


o = d:option(TextValue, "_contact", "Kontakt")
o.rmempty = false
o.datatype = "string" 
o.default="Ahoj lidi"
o.description = "z.B. E-Mail, Telefon oder Chat-Name"  
o.size = 35 

f = d:option(Flag,"_flagaa","Test DNS")
f.default=0


function o.cfgvalue()
	return "test necoho strasne dlouho"
end


btn = d:option(Button, "_btn", translate("Click this to run a script"))

function btn.write()

	luci.http.write("Haha, rebooting now...")
	luci.template.render("myapp-mymodule/view_tab")
    --o.default="Ahoj lidi jak se mate"
    --luci.sys.call("/usr/bin/ls")
    aa=luci.util.exec("ls /")
    local field1 = luci.http.formvalue("cbid.cbi_file.A._contact")
    local field2 = luci.http.formvalue("cbid.cbi_file.A._flagaa")

    --ubus call resolver_rpcd.py list_dns '{}'
    --local dump = util.ubus("resolver_rpcd.py", "list_dns", { })
    --
testik= [[<table>
<tr><th>Domain</th><th>DNS</th><th>DNSSEC</th></tr>
<tr><td>oskar.cz</td><td>OK</td><td>Failed</td></tr>
<tr><td>wild.oskar.cz</td><td>OK</td><td>Failed</td></tr>
</table>]]
 
    if field2 == nil then
	luci.http.write(field1)
	else
	luci.http.write(field1..field2)
	end

	luci.http.write(testik)
	
	--luci.http.write_json(dump["list_dns"][1])
	--

end

return m
