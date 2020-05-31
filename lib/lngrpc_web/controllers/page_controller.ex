defmodule LngrpcWeb.PageController do
  use LngrpcWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
