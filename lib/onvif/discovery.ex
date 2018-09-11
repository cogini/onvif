defmodule Onvif.Discovery do
  @moduledoc "Discover devices"

  use GenServer

  require Logger

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

    port = config[:port] || 3702

    {:ok, _sock} = :gen_udp.open(port, [:binary, {:active, true}, {:add_membership, {{239, 255, 255, 250}, {0,0,0,0}}}])

    {:ok, %{}}
  end

  @spec handle_info(term, map) :: {:noreply, map}
  def handle_info({:udp, _port, sender_ip, sender_port, data}, state) do
    Logger.debug("Received UDP datagram from #{inspect sender_ip} #{sender_port} #{inspect data}")

    {:noreply, state}
  end
  def handle_info(event, state) do
    Logger.debug("handle_info: #{inspect event} #{inspect state}")
    {:noreply, state}
  end

end
