defmodule Onvif.Discovery do
  @moduledoc "Discover devices"

  use GenServer

  require Logger
  import SweetXml

  @spec send_data(iodata) :: :ok | {:error, :not_owner} | {:error, :inet.posix()}
  def send_data(data) do
    {:ok, sock} = :gen_udp.open(0)
    :gen_udp.send(sock, {239, 255, 255, 250}, 3702, data)
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
    Logger.debug("Received UDP datagram from #{inspect sender_ip} #{sender_port} #{inspect data}")

    doc = parse(data, namespace_conformant: true)
    # Logger.debug("doc: #{inspect doc}")

    header = xpath(doc,
      ~x"//s:Envelope/s:Header"
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("a", "http://schemas.xmlsoap.org/ws/2004/08/addressing"),
      action: ~x"./a:Action/text()",
      message_id: ~x"./a:MessageID/text()",
      to: ~x"./a:To/text()"
    )
    Logger.debug("header: #{inspect header}")

    handle(header, doc)

    {:noreply, state}
  end
  def handle_info(event, state) do
    Logger.debug("handle_info: #{inspect event} #{inspect state}")
    {:noreply, state}
  end

  defp handle(%{action: 'http://schemas.xmlsoap.org/ws/2005/04/discovery/Hello'}, doc) do
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

end
