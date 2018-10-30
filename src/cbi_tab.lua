local util = require "luci.util"

function test_domain(domain,resolver,dnssec)
  local ret= util.ubus( "resolver-debug.py",
                        "test_dig",
                        {domain=domain,
                        resolver=resolver,
                        dnssec=dnssec})
  return ret["status"]
end

function test_dig_tbl()
  local util = require "luci.util"
  local ret_tbl = "<div width=600px ><table>\n<tr><th>URL</th><th>Test result</th></tr>"
  local t_dest = {"www.nic.cz", "www.seznam.cz"}
  -- URL, DNSSEC enabled , should pass
  local t_domains = {
      {"api.turris.cz", True},               --should pass
      {"www.google.com", True},              --should pass
      {"www.youtube.com", True},             --should pass
      {"www.facebook.com", True},            --should pass
      {"*.wilda.nsec.0skar.cz", True},       --should pass
      {"www.wilda.nsec.0skar.cz", True},     --should pass
      {"www.wilda.0skar.cz", True},          --should pass
      {"*.wilda.0skar.cz", True},            --should pass
      {"*.wild.0skar.cz", True},             --should pass
      {"*.wild.nsec.0skar.cz", True},        --should pass
      {"*.wilda.rhybar.ecdsa.0skar.cz", True},--should fail
      {"*.wilda.rhybar.0skar.cz", True},     --should fail
      {"www.rhybar.cz ", True}               --should fail
  }


  for key,value in pairs(t_domains) do
    local state
    local ret= util.ubus("resolver-debug.py", "test_dig",
                          {domain=value[1],
                          resolver="8.8.8.8",
                          dnssec="true"} )
    if ret["status"] == tostring(value[2]) then
        state = "OK"
    else
        state = "Failed"
    end
    state = ret["status"]
    ret_tbl = ret_tbl .. "<tr><td>".. value[1] .."</td><td>" .. state .."</td></tr>\n"
  end

	ret_tbl=ret_tbl .. "</table></div>"
  return ret_tbl
end


m = Map("cbi_file", translate("DNS Resolver Debuger"),
        translate("This app should help you debug DNS resolver on your router."))
d = m:section(TypedSection, "info", "Omnia resolver debug")


d:tab("general", translate("General Settings"))
d:tab("specific", translate("Specific tests"))

btn_resolver = d:taboption("general", Button, "_btn_resolver", translate("Run resolver test"))

function btn_resolver.write()
    local txt_domains = luci.http.formvalue("cbid.cbi_file.A.domain")
    local cb_dnssec = luci.http.formvalue("cbid.cbi_file.A._check_dnssec")
    luci.template.render("myapp-mymodule/view_tab", {domain=test_dig_tbl()})
end

o = d:taboption("specific", TextValue, "domain", "Domain")
o.description = "Domain name which should be tested. You can put multiple domains separated by new line."  
o.size = 35 

f = d:taboption("specific", Flag, "_check_dnssec", "Test DNSSEC")
f.default = 0

local mode = d:taboption("specific", ListValue, "mode", translate("Resolver"))
mode:value("8.8.8.8", translate("Google"))
mode:value("127.0.0.1", translate("Router resolver"))
mode:value("1.1.1.1", translate("OpenDNS"))
mode.default = "auto"

btn_domain = d:taboption("specific",Button, "_btn_domain", translate("Run domain test"))

function btn_domain.write()
    local ret_tbl
    local ret
    local dnssec
    local resolver = "8.8.8.8"
    local txt_domains = luci.http.formvalue("cbid.cbi_file.A.domain")
    local cb_dnssec = luci.http.formvalue("cbid.cbi_file.A._check_dnssec")
    local ret_tmp

    if cb_dnssec == "1" then
        dnssec = "true"
    else
        dnssec = "false"
    end

    ret_tmp = "<table>\n<tr><td>Domain</td><td>Status</td></tr>"
    for domain in string.gmatch(txt_domains, '[^\r\n]+') do
        ret = test_domain(domain, resolver, dnssec)
        ret_tmp = ret_tmp .. "<tr><td>" .. domain .. "</td><td>" .. ret .. "</td></tr>\n"
    end
    ret_tmp = ret_tmp .. "</table>"

    luci.template.render("myapp-mymodule/view_tab", {domain=ret_tmp})
end

return m
