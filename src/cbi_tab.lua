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
    ---aa=luci.util.exec("ls /")
    local field1 = luci.http.formvalue("cbid.cbi_file.A.domain")
    local field2 = luci.http.formvalue("cbid.cbi_file.A._check_dnssec")


luci.template.render("myapp-mymodule/view_tab",{domain=test_dig_tbl()})

end

return m
