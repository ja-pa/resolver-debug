local util = require "luci.util"
m = Map("cbi_file", translate("DNS Resolver Debuger"), translate("This app should help you debug DNS resolver on your router.")) -- cbi_file is the config file in /etc/config
d = m:section(TypedSection, "info", "Part A of the form")  -- info is the section called info in cbi_file



btn_resolver = d:option(Button, "_btn_resolver", translate("Run resolver test"))


o = d:option(TextValue, "domain", "Domain")
o.rmempty = false
o.datatype = "string" 
o.default=""
o.description = "Domain name which should be tested. You can put multiple domains separated by new line."  
o.size = 35 

f = d:option(Flag,"_check_dnssec","Test DNSSEC")
f.default=0

btn_domain = d:option(Button, "_btn_domain", translate("Run domain test"))

---function o.cfgvalue()
---	return "test necoho strasne dlouho"
--end


function test_domain(domain,resolver,dnssec)
  local ret= util.ubus("resolver-debug.py", "test_dig",
                          {domain=domain,
                          resolver=resolver,
                          dnssec=dnssec})
  return ret["status"]
end

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
    --local aaa = aaa.
    luci.template.render("myapp-mymodule/view_tab",{domain=test_dig_tbl()})
end

function btn_domain.write()
    ---aa=luci.util.exec("ls /")
    --local field1 = luci.http.formvalue("cbid.cbi_file.A.domain")
    --local field2 = luci.http.formvalue("cbid.cbi_file.A._check_dnssec")
    --local aaa = aaa.
    local dnssec
    local resolver="8.8.8.8"
    local field1 = luci.http.formvalue("cbid.cbi_file.A.domain")
     local field2 = luci.http.formvalue("cbid.cbi_file.A._check_dnssec")
    local ret_tmp = "" -- ret_tmp .. field1 .. " <br> " .. "status=" .. bbb
      if field2 == "1" then
        dnssec="true"
      else
        dnssec="false"
      end
    
    for line in string.gmatch(field1,'[^\r\n]+') do
      --print( line=="" and "(blank)" or line)
      local bbb = test_domain(line,"8.8.8.8",dnssec)
      ret_tmp =ret_tmp .. line .. " " .. "status=" .. bbb .. "<br>" 
    end
    
    luci.template.render("myapp-mymodule/view_tab",{domain=ret_tmp})
end



return m
