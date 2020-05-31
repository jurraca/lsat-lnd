defmodule Lnrpc.Lightning.Server do
  use GRPC.Server, service: Lnrpc.Lightning.Service

  def get_admin_macaroon() do
    Application.get_env(:lngrpc, :admin_macaroon)
    |> Lnrpc.Utils.encode_macaroon()
  end

  @doc """
    Request a macaroon. Pass a GRPC channel and an admin macaroon as credential
    Returns {:ok, %Lnrpc.BakeMacaroonResponse{macaroon: new_macaroon}}
  """
  def bake_macaroon(channel) do
    Lnrpc.Lightning.Stub.bake_macaroon(
      channel,
      %Lnrpc.BakeMacaroonRequest{
        permissions: [
          %Lnrpc.MacaroonPermission{
            entity: "invoices",
            action: "read"
          }
        ]
      },
      metadata: [macaroon: get_admin_macaroon()]
    )
  end

  def create_invoice(channel) do
    Lnrpc.Lightning.Stub.add_invoice(
      channel,
      %Lnrpc.Invoice{
        value: 10,
        memo: "for access"
      },
      metadata: [macaroon: get_admin_macaroon()]
    )
  end

  @spec wallet_balance(GRPC.Channel.t()) ::
          {:error, GRPC.RPCError.t()} | {:ok, any} | {:ok, any, map} | GRPC.Client.Stream.t()
  def wallet_balance(channel) do
    Lnrpc.Lightning.Stub.wallet_balance(
      channel,
      %Lnrpc.WalletBalanceRequest{},
      metadata: [macaroon: get_admin_macaroon()]
    )
  end
end
