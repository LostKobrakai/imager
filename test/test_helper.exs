require Logger
Finch.start_link(name: Imager.Finch)
Bandit.start_link(plug: Imager.Endpoint, port: 4001)
ExUnit.start()
