defmodule Onvif.Device do
  @moduledoc "Device connection info"

  defstruct [
    host: "",
    method: :http,
  ]

  @type t :: %__MODULE__{
    host: binary,
    method: atom,
  }

end
