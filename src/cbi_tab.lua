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





function test_dig_tbl()
local util = require "luci.util"
  ret_tbl="<div width=600px ><table>\n<tr><th>URL</th><th>Test result</th></tr>"
  t_dest={"www.nic.cz","www.seznam.cz"}
  -- URL, DNSSEC enabled , should pass
  t_domains={
      {"api.turris.cz",True},               --should pass
      {"www.google.com",True},              --should pass
      {"www.youtube.com",True},             --should pass
      {"www.facebook.com",True},            --should pass
      {"*.wilda.nsec.0skar.cz",True},       --should pass
      {"www.wilda.nsec.0skar.cz",True},     --should pass
      {"www.wilda.0skar.cz",True},          --should pass
      {"*.wilda.0skar.cz",True},            --should pass
      {"*.wild.0skar.cz",True},             --should pass
      {"*.wild.nsec.0skar.cz",True},        --should pass
      {"*.wilda.rhybar.ecdsa.0skar.cz",True},--should fail
      {"*.wilda.rhybar.0skar.cz",True},     --should fail
      {"www.rhybar.cz ",True}               --should fail
  }


  for key,value in pairs(t_domains) do
    --local aaa=value[1]
    local state=""
    --local ret= util.ubus("resolver-debug.py", "test_dig",'{"domain":"' .. value[1] .. '","resolver":"8.8.8.8","dnssec":"true"}' )
    local ret= util.ubus("resolver-debug.py", "test_dig",
    {domain=value[1],
    resolver="8.8.8.8",
    dnssec="true"} )
    if ret["status"] == tostring(value[2]) then
      state="OK"
    else
      state="Failed"
    end
    state=ret["status"]
    ret_tbl=ret_tbl .. "<tr><td>".. value[1] .."</td><td>" .. state .."</td></tr>\n"
  end

	ret_tbl=ret_tbl .. "</table></div>"
  return ret_tbl
end

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
    local dump = util.ubus("resolver-debug.py", "test_dig",'{"domain":"www.nic.cz","resolver":"8.8.8.8","dnssec":"true"}')
    luci.http.write_json(dump["status"])
    --'{"domain":"www.nic.cz","resolver":"8.8.8.8","dnssec":"true"}'

--# ubus -v call  resolver-debug.py "test_dig" '{"domain":"www.nic.cz","resolver":"8.8.8.8","dnssec":"true"}'

testik= [[<table>
<tr><th>Domain</th><th>DNS</th><th>DNSSEC</th></tr>
<tr><td>oskar.cz</td><td>OK</td><td>Failed</td></tr>
<tr><td>wild.oskar.cz</td><td>OK</td><td>Failed</td></tr>
</table>]]
luci.template.render("myapp-mymodule/view_tab",{domain=test_dig_tbl()})
 
--if field2 == nil then
--   luci.http.write(field1)
--else
--    luci.http.write(field1..field2)
--end

--    luci.http.write(testik)
--    luci.http.write_json(dump)

end

return m
