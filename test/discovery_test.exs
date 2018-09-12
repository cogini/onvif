defmodule DiscoveryTest do
  use ExUnit.Case

  alias Onvif.Discovery

  test "parse Hello" do
    xml = """
    <?xml version="1.0" encoding="utf-8" standalone="yes" ?>
    <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:sc="http://www.w3.org/2003/05/soap-encoding"
      xmlns:dn="http://www.onvif.org/ver10/network/wsdl" xmlns:tds="http://www.onvif.org/ver10/device/wsdl"
      xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing">
      <s:Header>
        <a:MessageID>uuid:7dffd1ac-a95b-4479-ae60-0128450c7104</a:MessageID>
        <a:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</a:To>
        <a:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/Hello</a:Action>
      </s:Header>
      <s:Body>
        <d:Hello>
          <a:EndpointReference>
            <a:Address>uuid:503b687a-b9d7-474f-a2d0-a18c8b25a464</a:Address>
          </a:EndpointReference>
        <d:Types>dn:NetworkVideoTransmitter tds:Device</d:Types>
        <d:Scopes>onvif://www.onvif.org/location/country/china onvif://www.onvif.org/name/Dahua onvif://www.onvif.org/hardware/IPC-HFW2228M-I1-V2 onvif://www.onvif.org/Profile/Streaming onvif://www.onvif.org/type/Network_Video_Transmitter onvif://www.onvif.org/extension/unique_identifier</d:Scopes>
        <d:XAddrs>http://192.168.1.45/onvif/device_service</d:XAddrs>
        <d:MetadataVersion>1</d:MetadataVersion>
        </d:Hello>
      </s:Body>
    </s:Envelope>
    """

    {:ok, doc} = Discovery.parse_xml(xml)
    {:ok, header} = Discovery.parse_header(doc)
    assert header.action == 'http://schemas.xmlsoap.org/ws/2005/04/discovery/Hello'
  end

  test "parse Resolve" do
    xml = """
    <?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsd="http://schemas.xmlsoap.org/ws/2005/04/discovery"><soap:Header><wsa:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</wsa:To><wsa:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/Resolve</wsa:Action><wsa:MessageID>urn:uuid:5af46af6-916f-4c25-9729-789859a46409</wsa:MessageID></soap:Header><soap:Body><wsd:Resolve><wsa:EndpointReference><wsa:Address>urn:uuid:434e4638-4732-4333-5338-fc15b47817b1</wsa:Address></wsa:EndpointReference></wsd:Resolve></soap:Body></soap:Envelope>
    """

    {:ok, doc} = Discovery.parse_xml(xml)
    {:ok, header} = Discovery.parse_header(doc)
    assert header.action == 'http://schemas.xmlsoap.org/ws/2005/04/discovery/Resolve'
  end

  test "parse ProbeMatches" do
    xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:SOAP-ENC="http://www.w3.org/2003/05/soap-encoding" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsdd="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:tds="http://www.onvif.org/ver10/device/wsdl" xmlns:dn="http://www.onvif.org/ver10/network/wsdl">
        <SOAP-ENV:Header>
            <wsa:MessageID>urn:uuid:01234567-dead-beef-baad-abcdeffedcba</wsa:MessageID>
            <wsa:RelatesTo>urn:uuid:01234567-dead-beef-baad-abcdeffedcba</wsa:RelatesTo>
            <wsa:ReplyTo SOAP-ENV:mustUnderstand="true">
                <wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address>
            </wsa:ReplyTo>
            <wsa:To SOAP-ENV:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>
            <wsa:Action SOAP-ENV:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches</wsa:Action>
            <wsdd:AppSequence MessageNumber="161" InstanceId="0"></wsdd:AppSequence>
        </SOAP-ENV:Header>
        <SOAP-ENV:Body>
            <wsdd:ProbeMatches>
                <wsdd:ProbeMatch>
                    <wsa:EndpointReference>
                        <wsa:Address>uuid:c9790c3a-701b-464d-a189-0060351c8ada</wsa:Address>
                    </wsa:EndpointReference>
                    <wsdd:Types>dn:NetworkVideoTransmitter tds:Device</wsdd:Types>
                    <wsdd:Scopes>onvif://www.onvif.org/Profile/Streaming onvif://www.onvif.org/type/video_encoder onvif://www.onvif.org/type/audio_encoder onvif://www.onvif.org/type/ptz onvif://www.onvif.org/hardware/HD_PREDATOR onvif://www.onvif.org/name/PREDATOR onvif://www.onvif.org/location/</wsdd:Scopes>
                    <wsdd:XAddrs>SERVICE_URI</wsdd:XAddrs>
                    <wsdd:MetadataVersion>1</wsdd:MetadataVersion>
                </wsdd:ProbeMatch>
            </wsdd:ProbeMatches>
        </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
    """
    {:ok, doc} = Discovery.parse_xml(xml)
    {:ok, header} = Discovery.parse_header(doc)
    assert header.action == 'http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches'
  end

end
