local util = require "luci.util"
m = Map("cbi_file", translate("DNS Resolver Debuger"), translate("This app should help you debug DNS resolver on your router.")) -- cbi_file is the config file in /etc/config
d = m:section(TypedSection, "info", "Part A of the form")  -- info is the section called info in cbi_file



o = d:option(TextValue, "domain", "Domain")
o.rmempty = false
o.datatype = "string" 
o.default=""
o.description = "Domain name which should be tested. You can put multiple domains separated by new line."  
o.size = 35 

f = d:option(Flag,"_check_dnssec","Test DNSSEC")
f.default=0


---function o.cfgvalue()
---	return "test necoho strasne dlouho"
--end

--aasdfasdf
btn_resolver = d:option(Button, "_btn_resolver", translate("Run resolver test"))
btn_domain = d:option(Button, "_btn_domain", translate("Run domain test"))


function btn_resolver.write()

    --luci.http.write("Haha, rebooting now...")
    --    luci.template.render("admin_status/openvpnlog", {lua_log_variable=local_lua_log_variable, lua_title_variable="OpenVPN Log (tun)"})
    --luci.http.redirect("tab_from_view",{domain="testik domain"})
    
    
    --luci.template.render("myapp-mymodule/view_tab")
    --http://192.168.2.1/cgi-bin/luci/admin/new_tab/tab_from_view
    --No page is registered at '/admin/new_tab/myapp-mymodule/view_tab'.
    --o.default="Ahoj lidi jak se mate"
    --luci.sys.call("/usr/bin/ls")
    aa=luci.util.exec("ls /")
    local field1 = luci.http.formvalue("cbid.cbi_file.A.domain")
    local field2 = luci.http.formvalue("cbid.cbi_file.A._check_dnssec")
    --o.write("Ahoj lidi")

    --ubus call resolver_rpcd.py list_dns '{}'
    --local dump = util.ubus("resolver-debugrpcd.py", "list_dns", { })
    --local dump = util.ubus("resolver-debug.py", "test_dig",{"domain":"www.nic.cz","resolver":"8.8.8.8","dnssec":"true"} )

--# ubus -v call  resolver-debug.py "test_dig" '{"domain":"www.nic.cz","resolver":"8.8.8.8","dnssec":"true"}'

testik= [[<table>
<tr><th>Domain</th><th>DNS</th><th>DNSSEC</th></tr>
<tr><td>oskar.cz</td><td>OK</td><td>Failed</td></tr>
<tr><td>wild.oskar.cz</td><td>OK</td><td>Failed</td></tr>
</table>]]
luci.template.render("myapp-mymodule/view_tab",{domain=testik})
 
--if field2 == nil then
--   luci.http.write(field1)
--else
--    luci.http.write(field1..field2)
--end

--    luci.http.write(testik)
--    luci.http.write_json(dump)

end

return m
