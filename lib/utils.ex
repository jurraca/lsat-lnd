defmodule Lnrpc.Utils do
  @moduledoc """
      Basic utilities for dealing with LN GRPC.
  """

  @doc """
      Create a GRPC cred via SSL, using the lnd cert, usually at `~/.lnd/tls.cert`.
      Returns a %GRPC.Credential struct
  """
  def build_credentials() do
    cert_path = Application.get_env(:lngrpc, :cert)
    %GRPC.Credential{ssl: [cacertfile: cert_path]}
  end

  def encode_macaroon(macaroon_path) do
    macaroon_path
    |> File.read!()
    |> Base.encode16()
  end

  def create_channel(addr, credential) do
    GRPC.Stub.connect(addr, cred: credential)
  end

  def setup() do
    create_channel("127.0.0.1:10001", build_credentials())
  end
end
