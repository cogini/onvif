defmodule DiscoveryTest do
  use ExUnit.Case

  test "parse GetSystemDateAndTimeResponse" do
		{:ok, xml} = File.read("test/data/device_service/GetSystemDateAndTimeResponse.xml")
		{:ok, doc} = Onvif.parse_xml(xml)
    {:ok, result} = Onvif.parse_response(doc, "device_service", "GetSystemDateAndTime")
    assert result == {{2018, 9, 12}, {5, 34, 10}}
	end

end
