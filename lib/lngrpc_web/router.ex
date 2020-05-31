defmodule LngrpcWeb.Router do
  use LngrpcWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Lngrpc.Plugs.Lsat, nil
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LngrpcWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LngrpcWeb do
  #   pipe_through :api
  # end
end
