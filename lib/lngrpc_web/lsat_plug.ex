defmodule Lngrpc.Plugs.Lsat do
  @moduledoc """
      Plug to handle an LSAT-compliant authentication flow.
      First, check if the user has a macaroon set on the session.
      Then, check
      Then, check that macaroon against existing grants.
      If no mac, instruct LND to create one. X
      Respond to client with mac and invoice as a cookie. X
      Client pays invoice, receives preimage.
      User responds with mac and preimage via Authorization field.
  """

  def init(opts), do: opts

  @doc """
  Matches on the authorization header.
  should be Authorization: LSAT AGIAJEemVQUTEyNCR0exk7ek90Cg==:1234abcd1234abcd1234abcd
  """
  def call(%Plug.Conn{req_headers: [{"Authorization", value}]} = conn, _opts) do
    IO.inspect(value, label: "Auth")

    case valid_lsat?(value) do
      # validate macaroon and preimage
      {:ok, msg} -> msg
      {:error, msg} -> msg
    end
  end

  @doc """
  No Authorization header.
  Set WWW-Authenticate: LSAT macaroon="AGIAJEemVQUTEyNCR0exk7ek90Cg==", invoice="lnbc1500n1pw5kjhmpp5fu6xhthlt2...f4sd"
  """
  def call(%Plug.Conn{} = conn, _opts) do

    lsat = build_lsat()

    conn
    |> Plug.Conn.put_resp_header("www-authenticate", lsat)
    |> Plug.Conn.put_status(:payment_required)
  end

  def call(conn, _opts) do
    IO.inspect("fallback")
    conn
  end

  def build_lsat() do
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
    %{"mac" => mac, "preimage" => preimage} = Regex.named_captures(regex, lsat)
    {:ok, %{macaroon: mac, preimage: preimage}}
  end

  def valid_lsat?(lsat) do
    # invalid LSAT
  end

 # fetch an existing macaroon
  def fetch_macaroon() do
    nil
  end
end
