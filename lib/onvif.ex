defmodule Onvif do
  @moduledoc false

	require Logger

  import SweetXml

  def request(device, service, operation, params) do
    url = "#{device.method}://#{device.host}/onvif/#{service}"

    message = request_message(service, operation, params)
    soap_action = soap_action(service, operation)

    Logger.debug("Request: #{url} #{soap_action} #{message}")

    case HTTPoison.post(url, message, [{"Content-Type", "application/soap+xml"}, {"SOAPAction", soap_action}]) do
      {:ok, response} ->
        Logger.debug("Response: #{inspect response}")
        if response.status_code == 200 do
					{:ok, doc} = parse_xml(response.body)
					parse_response(doc, service, operation)
        else
          Logger.error "Error invoking #{service} #{operation}. URL: #{url}. Request: #{inspect message}. Response #{inspect response}."
        end
      {:error, reason} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def request_message("device_service", "GetSystemDateAndTime", _params) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:tds="http://www.onvif.org/ver10/device/wsdl">
    <s:Body><tds:GetSystemDateAndTime /></s:Body>
    </s:Envelope>
    """
  end

  @doc "Translate service and operation into SOAPAction"
  def soap_action(service, operation)
  def soap_action("device_service", "GetDeviceInformation" = operation), do: "http://www.onvif.org/ver10/device/wsdl/#{operation}"
  def soap_action("device_service", "GetSystemDateAndTime" = operation), do: "http://www.onvif.org/ver10/device/wsdl/#{operation}"

  @spec parse_xml(binary) :: {:ok, term} | {:error, term}
  def parse_xml(xml) do
    try do
      doc = parse(xml, namespace_conformant: true, quiet: true)
      {:ok, doc}
    catch
      :exit, e ->
        {:error, e}
    end
  end

	def parse_response(doc, "device_service", "GetSystemDateAndTime") do
    r = xpath(doc,
      ~x"//s:Envelope/s:Body/tds:GetSystemDateAndTimeResponse/tds:SystemDateAndTime/tt:UTCDateTime"
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
      hour: ~x"./tt:Time/tt:Hour/text()"i |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
      minute: ~x"./tt:Time/tt:Minute/text()"i |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
      second: ~x"./tt:Time/tt:Second/text()"i |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
      year: ~x"./tt:Date/tt:Year/text()"i |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
      month: ~x"./tt:Date/tt:Month/text()"i |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
      day: ~x"./tt:Date/tt:Day/text()"i |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
		{:ok, {{r.year, r.month, r.day}, {r.hour, r.minute, r.second}}}
  end

end
