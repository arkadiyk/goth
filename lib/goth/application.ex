defmodule Goth.Application do
  @moduledoc false
  use Application

  Application.put_env(:goth, :proxy, "http://myproxy.example.com:8080")

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Goth.Registry},
      {Finch, finch_config()},
      Goth.TokenStore
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Goth.Supervisor)
  end

  defp finch_config do
    if proxy = Application.get_env(:goth, :proxy) do
      %{scheme: scheme, host: host, port: port} = URI.parse(proxy)
      [name: Goth.Finch, pools: [default: [conn_opts: [proxy: {String.to_existing_atom(scheme), host, port, []}]]]]
    else
      [name: Goth.Finch]
    end
  end
end
