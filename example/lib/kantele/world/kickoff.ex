defmodule Kantele.World.Kickoff do
  @moduledoc """
  Kicks off the world by loading and booting it
  """

  use GenServer

  alias Kantele.World.Cache
  alias Kantele.World.Loader

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @doc false
  def reload() do
    GenServer.cast(__MODULE__, :reload)
  end

  @impl true
  def init(_) do
    {:ok, %{}, {:continue, :load}}
  end

  @impl true
  def handle_cast(:reload, state) do
    {:noreply, state, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, state) do
    world = Loader.load_world()

    Enum.each(world.items, &cache_item/1)

    Enum.each(world.zones, fn zone ->
      zone
      |> Cache.cache_zone()
      |> Loader.strip_zone()
      |> start_zone()
    end)

    Enum.each(world.rooms, &start_room/1)
    Enum.each(world.characters, &start_character/1)

    {:noreply, state}
  end

  defp start_zone(zone) do
    config = %{
      supervisor_name: Kantele.World,
      callback_module: Kantele.World.Zone
    }

    case GenServer.whereis(Kalevala.World.Zone.global_name(zone)) do
      nil ->
        Kalevala.World.start_zone(zone, config)

      pid ->
        reset_characters(zone)
        Kalevala.World.Zone.update(pid, zone)
    end
  end

  defp start_room(room) do
    config = %{
      supervisor_name: Kalevala.World.RoomSupervisor.global_name(room),
      callback_module: Kantele.World.Room
    }

    item_instances = Map.get(room, :item_instances, [])
    room = Map.delete(room, :item_instances)

    case GenServer.whereis(Kalevala.World.Room.global_name(room)) do
      nil ->
        Kalevala.World.start_room(room, item_instances, config)

      pid ->
        Kalevala.World.Room.update_items(pid, item_instances)
        Kalevala.World.Room.update(pid, room)
    end
  end

  defp start_character(character) do
    config = [
      supervisor_name: Kalevala.World.CharacterSupervisor.global_name(character.meta.zone_id),
      character_module: Kantele.Character,
      communication_module: Kantele.Communication,
      initial_controller: Kantele.Character.SpawnController,
      quit_view: {Kantele.Character.QuitView, "disconnected"}
    ]

    Kalevala.World.start_character(character, config)
  end

  defp cache_item(item) do
    Kantele.World.Items.put(item.id, item)
  end

  # clean out all existing characters by terminating them
  defp reset_characters(zone) do
    Enum.map(character_pids(zone.id), fn pid ->
      send(pid, :terminate)
    end)
  end

  defp character_pids(zone_id) do
    case GenServer.whereis(Kalevala.World.CharacterSupervisor.global_name(zone_id)) do
      nil ->
        []

      pid ->
        Enum.map(DynamicSupervisor.which_children(pid), fn {_, pid, _, _} ->
          pid
        end)
    end
  end
end
