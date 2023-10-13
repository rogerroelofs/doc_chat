defmodule DocChatWeb.SearchLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, search_activated: false, question: "", messages: [], loading: false)}
  end

  def handle_event("submit_question", %{"question" => question}, socket) do
    user_question = %{content: question, role: :user}
    new_messages = socket.assigns.messages ++ [user_question]
  
    ref = Task.async(fn ->
      DocChat.Articles.ask(question)
    end)
  
    {:noreply, assign(socket, search_activated: true, question: "", messages: new_messages, loading: true, task_ref: ref)}
  end
  
  def handle_info({ref, {:ok, answer}}, socket) when ref == socket.assigns.task_ref do
    Process.demonitor(ref, [:flush])
    
    actual_answer = %{content: answer, role: :assistant}
    new_messages = socket.assigns.messages ++ [actual_answer]
    
    {:noreply, assign(socket, search_activated: false, question: "", messages: new_messages, loading: false)}
  end

  defp format_messages(messages) do
    Enum.filter(messages, fn(msg) ->
      msg.content != nil && Enum.member?([:user, :assistant], msg.role)
    end)
    |> Enum.map(fn(msg) ->
      %{
        content: msg.content,
        role: msg.role
      }
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen flex-col">
      <!-- Scrollable message container -->
      <div class="flex flex-col space-y-4 p-4 w-1/2 mx-auto overflow-y-auto h-1/2">
        <%= for msg <- @messages do %>
          <div class={ "self-start w-full " <> (if msg.role == :user, do: "text-black", else: "bg-gray-100 text-black") }>
            <div class="px-4 py-2">
              <%= msg.content %>
            </div>
          </div>
        <% end %>

        <%= if @loading do %>
          <div class="self-start w-full text-black bg-gray-100">
            <div class="px-4 py-2">
              Loading...
            </div>
          </div>
        <% end %>
      </div>

      <!-- Search bar -->
      <div class="flex-grow flex items-center">
        <div class="text-center w-full">
          <!-- Title disappears when @search_activated is true -->
          <%= if not @search_activated do %>
            <h1 class="text-4xl font-bold mb-4">Doc Chat</h1>
          <% end %>

          <form phx-submit="submit_question" class="flex border rounded overflow-hidden w-1/2 mx-auto">
            <input type="text"
              name="question"
              placeholder="Enter your question..."
              class="p-2 flex-grow outline-none"
              phx-input="search"
              value={@question} />
            <button type="submit" class="p-2 bg-blue-500 text-white flex items-center justify-center w-10">
              <i class="fas fa-paper-plane"></i>
            </button>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
