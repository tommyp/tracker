defmodule TrackerWeb.GoalLive.Show do
  use TrackerWeb, :live_view

  alias Tracker.Goals

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:goal, Goals.get_goal!(id))}
  end

  defp page_title(:show), do: "Show Goal"
  defp page_title(:edit), do: "Edit Goal"
end
