defmodule Lnrpc.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Logger.Server
  run(Lnrpc.Lightning.Server)
end
