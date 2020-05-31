defmodule Lngrpc.Plugs.Lsat do
  @moduledoc """
      Plug to handle an LSAT-compliant authentication flow.
      If no mac, instruct LND to create one.
      Respond to client with mac and invoice in authenticate header.
      Client pays invoice, receives preimage.
      User responds with mac and preimage via Authorization field.
  """

  def init(opts), do: opts

  @doc """
  Matches on the authorization header of the form Authorization "LSAT <macaroon>:<preimage>.
  """
  def call(%Plug.Conn{req_headers: [{"Authorization", lsat}]} = conn, _opts) do
    case valid_lsat?(lsat) do
      {:ok, msg} -> validate_preimage(msg)
      {:error, msg} -> msg
    end
  end

  @doc """
  No Authorization header.
  Set WWW-Authenticate: "LSAT macaroon=<mac>, invoice=<invoice>"
  """
  def call(%Plug.Conn{} = conn, _opts) do
    lsat = build_lsat()

    conn
    |> Plug.Conn.put_resp_header("www-authenticate", lsat)
    |> Plug.Conn.put_status(:payment_required)
  end

  def call(conn, _opts) do
    conn
  end

  def validate_preimage(%{macaroon: mac, preimage: preimage}) do
    # TODO
  end

  defp build_lsat() do
    {:ok, channel} = Lnrpc.Utils.setup()
    mac = macaroon_request(channel) |> Base.encode64()
    %{payment_request: invoice, r_hash: _hash} = invoice_request(channel)

    "LSAT macaroon=" <> mac <> " invoice=" <> invoice
  end

  defp macaroon_request(channel) do
    case Lnrpc.Lightning.Server.bake_macaroon(channel) do
      {:ok, %Lnrpc.BakeMacaroonResponse{macaroon: mac}} -> mac
      msg -> msg
    end
  end

  defp invoice_request(channel) do
    case Lnrpc.Lightning.Server.create_invoice(channel) do
      {:ok, body = %Lnrpc.AddInvoiceResponse{}} -> body
      msg -> msg
    end
  end

  def valid_lsat?(lsat) do
    # regex to extract mac and preimage
    regex = ~r{^LSAT\s(?<mac>.+):(?<preimage>[[:alnum:]]+)$}

    case Regex.named_captures(regex, lsat) do
      %{"mac" => mac, "preimage" => preimage} -> {:ok, %{macaroon: mac, preimage: preimage}}
      _ -> {:error, "Invalid LSAT"}
    end
  end
end
