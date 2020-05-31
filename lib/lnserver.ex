defmodule Lnrpc.Lightning.Server do
  use GRPC.Server, service: Lnrpc.Lightning.Service

  @admin_macaroon Lnrpc.Utils.encode_macaroon(
                    "/home/jurraca/code/go/dev/alice/data/chain/bitcoin/simnet/admin.macaroon"
                  )

  # Lnrpc.Lightning.Stub.fn(channel, request, metadata: [macaroon: macaroon])

  @doc """
    Request a macaroon. Pass a GRPC channel and an admin macaroon as credential
    Returns {:ok, %Lnrpc.BakeMacaroonResponse{macaroon: new_macaroon}}
  """
  def bake_macaroon(channel, macaroon \\ @admin_macaroon) do
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
      metadata: [macaroon: macaroon]
    )
  end

  def create_invoice(channel, macaroon \\ @admin_macaroon) do
    Lnrpc.Lightning.Stub.add_invoice(
      channel,
      %Lnrpc.Invoice{
        value: 10,
        memo: "for access"
      },
      metadata: [macaroon: macaroon]
    )
  end

  def wallet_balance(channel, macaroon \\ @admin_macaroon) do
    Lnrpc.Lightning.Stub.wallet_balance(
      channel,
      %Lnrpc.WalletBalanceRequest{},
      metadata: [macaroon: macaroon]
    )
  end
end
