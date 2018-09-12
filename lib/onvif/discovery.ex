defmodule Onvif.Discovery do
  @moduledoc "Discover devices"

  use GenServer

  require Logger
  import SweetXml
  require EEx

  # require Record
  # Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  # Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  # Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")

  @spec send_multicast(iodata) :: :ok | {:error, :not_owner} | {:error, :inet.posix()}
  def send_multicast(data) do
    {:ok, sock} = :gen_udp.open(0)
    :gen_udp.send(sock, {239, 255, 255, 250}, 3702, data)
  end

  def send(data) do
    {:ok, sock} = :gen_udp.open(0)
    :gen_udp.send(sock, {127, 0, 0, 1}, 3702, data)
  end

  def probe do
    template = """
    <?xml version="1.0" encoding="utf-8"?>
    <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:sc="http://www.w3.org/2003/05/soap-encoding"
        xmlns:dn="http://www.onvif.org/ver10/network/wsdl" xmlns:tds="http://www.onvif.org/ver10/device/wsdl"
        xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing">
      <s:Header>
        <a:MessageID>uuid:<%= uuid %></a:MessageID>
        <a:ReplyTo><a:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</a:Address></a:ReplyTo>
        <a:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</a:To>
        <a:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</a:Action>
      </s:Header>
      <s:Body>
        <d:Probe>
          <d:Types>tds:NetworkVideoTransmitter</d:Types>
        </d:Probe>
      </s:Body>
    </s:Envelope>
    """

    #     <d:Types xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:dp0="http://www.onvif.org/ver10/network/wsdl">dp0:NetworkVideoTransmitter</d:Types>
    # <d:Types>tds:Device</d:Types>

    # <a:To s:mustUnderstand="true">urn:schemas-xmlsoap-org:ws:2005:04:discovery</a:To>

    # template2 = """
    # <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing">
    #   <s:Header>
    #     <a:Action s:mustUnderstand="1">http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</a:Action>
    #     <a:MessageID>uuid:21859bf9-6193-4c8a-ad50-d082e6d296ab</a:MessageID>
    #     <a:ReplyTo><a:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</a:Address></a:ReplyTo>
    #     <a:To s:mustUnderstand="1">urn:schemas-xmlsoap-org:ws:2005:04:discovery</a:To>
    #   </s:Header>
    #   <s:Body>
    #     <Probe xmlns="http://schemas.xmlsoap.org/ws/2005/04/discovery">
    #     <d:Types xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:dp0="http://www.onvif.org/ver10/network/wsdl">dp0:NetworkVideoTransmitter</d:Types>
    #     </Probe>
    #   </s:Body>
    # </s:Envelope>
    # """

     # SCOPE_NAME = "onvif://www.onvif.org/name/"
     # String SCOPE_HARDWARE = "onvif://www.onvif.org/hardware/"

    # <?xml version="1.0" encoding="utf-8" standalone="yes" ?>
    # <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:sc="http://www.w3.org/2003/05/soap-encoding"
    #   xmlns:dn="http://www.onvif.org/ver10/network/wsdl" xmlns:tds="http://www.onvif.org/ver10/device/wsdl"
    #   xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing">
    #   <s:Header>
    #     <a:MessageID>uuid:7dffd1ac-a95b-4479-ae60-0128450c7104</a:MessageID>
    #     <a:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</a:To>
    #     <a:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/Hello</a:Action>
    #   </s:Header>
    #   <s:Body>
    #     <d:Hello>
    #       <a:EndpointReference>
    #         <a:Address>uuid:503b687a-b9d7-474f-a2d0-a18c8b25a464</a:Address>
    #       </a:EndpointReference>
    #     <d:Types>dn:NetworkVideoTransmitter tds:Device</d:Types>
    #     <d:Scopes>onvif://www.onvif.org/location/country/china onvif://www.onvif.org/name/Dahua onvif://www.onvif.org/hardware/IPC-HFW2228M-I1-V2 onvif://www.onvif.org/Profile/Streaming onvif://www.onvif.org/type/Network_Video_Transmitter onvif://www.onvif.org/extension/unique_identifier</d:Scopes>
    #     <d:XAddrs>http://192.168.1.45/onvif/device_service</d:XAddrs>
    #     <d:MetadataVersion>1</d:MetadataVersion>
    #     </d:Hello>
    #   </s:Body>
    # </s:Envelope>

    template
    |> EEx.eval_string(uuid: uuid())
    |> send_multicast()
  end

  # GenServer callbacks

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(config) do
    Process.flag(:trap_exit, true) # Die gracefully
    Logger.info("Starting #{__MODULE__} #{inspect config}")

    {:ok, _sock} = :gen_udp.open(3702, [:binary, {:active, true}, {:add_membership, {{239, 255, 255, 250}, {0,0,0,0}}}])

    {:ok, %{}}
  end

  @spec handle_info(term, map) :: {:noreply, map}
  def handle_info({:udp, _port, sender_ip, sender_port, data}, state) do
    Logger.debug("UDP datagram from #{:inet.ntoa(sender_ip)}:#{sender_port} #{inspect data}")

    case parse_xml(data) do
      {:ok, doc} ->
        {:ok, header} = parse_header(doc)
        Logger.debug("header: #{inspect header}")

        handle_message(header, doc)
      {:error, reason} ->
        Logger.debug("Could not parse XML: #{inspect reason}")
    end

    {:noreply, state}
  end
  def handle_info(event, state) do
    Logger.debug("handle_info: #{inspect event} #{inspect state}")
    {:noreply, state}
  end

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

  @spec parse_header(term) :: map
  def parse_header(doc) do
    header = xpath(doc,
      ~x"//s:Envelope/s:Header"
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("a", "http://schemas.xmlsoap.org/ws/2004/08/addressing"),
      action: ~x"./a:Action/text()" |> add_namespace("a", "http://schemas.xmlsoap.org/ws/2004/08/addressing"),
      message_id: ~x"./a:MessageID/text()" |> add_namespace("a", "http://schemas.xmlsoap.org/ws/2004/08/addressing"),
      to: ~x"./a:To/text()" |> add_namespace("a", "http://schemas.xmlsoap.org/ws/2004/08/addressing")
    )
    {:ok, header}
  end

  defp handle_message(%{action: 'http://schemas.xmlsoap.org/ws/2005/04/discovery/Hello'}, doc) do
    body = xpath(doc,
      ~x"//s:Envelope/s:Body/d:Hello"
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("sc", "http://www.w3.org/2003/05/soap-encoding")
      |> add_namespace("dn", "http://www.onvif.org/ver10/network/wsdl")
      |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
      |> add_namespace("d", "http://schemas.xmlsoap.org/ws/2005/04/discovery")
      |> add_namespace("a", "http://schemas.xmlsoap.org/ws/2004/08/addressing"),
      address: ~x"./a:EndpointReference/a:Address/text()",
      types: ~x"./d:Types/text()",
      scopes: ~x"./d:Scopes/text()",
      xaddrs: ~x"./d:XAddrs/text()",
      metadata_version: ~x"./d:MetadataVersion/text()"
    )
    Logger.debug("Hello: #{inspect body}")
  end
  defp handle_message(%{action: action}, _doc) do
    Logger.debug("Ignoring #{action}")
  end

  def message_id do
    "urn:uuid:" <> uuid()
  end

  @spec init_uuid() :: :uuid.state
  def init_uuid do
    mac_address = mac_address()
    :uuid.new(self(), mac_address: mac_address)
  end

  @spec uuid() :: binary
  def uuid() do
    state = Process.get(:uuid_state) || init_uuid()
    {uuid, new_state} = :uuid.get_v1(state)
    Process.put(:uuid_state, new_state)
    :uuid.uuid_to_string(uuid, :binary_standard)
  end

  def mac_address do
    mac_address(Process.get(:mac_address))
  end
  def mac_address(nil) do
    value = :uuid.mac_address()
    Process.put(:mac_address, value)
    value
  end
  def mac_address(value), do: value

end
