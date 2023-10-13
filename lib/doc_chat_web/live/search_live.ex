defmodule DocChatWeb.SearchLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, search_activated: false, question: nil, messages: [])}
  end

  def handle_event("submit_question", %{"question" => question}, socket) do
    Task.async(fn ->
      DocChat.Articles.ask(question)
    end)
    {:noreply, assign(socket, search_activated: true, question: question)}
  end

  def handle_info({ref, result}, socket) do
    Process.demonitor(ref, [:flush])
    {:ok, chain} = result
    messages = format_messages(chain.messages)
    {:noreply,
      assign(socket,
        search_activated: false,
        question: "",
        chain: chain,
        messages: messages)}
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

      <!-- Display submitted question at the top -->
      <%= if @search_activated do %>
      <div class="text-center w-full mt-4">
        <p class="text-xl">Question: <%= @question %></p>
      </div>
      <% end %>

      <!-- Search bar centered -->
      <div class="flex-grow flex items-center">
        <div class="text-center w-full">
          <!-- Title -->
          <h1 class="text-4xl font-bold mb-4">Doc Chat</h1>

          <!-- Search box -->
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

      <!-- Sidebar for history and chat area, only when search is activated -->
      <div class="flex w-full mt-10">
        <!-- Sidebar for history -->
        <div class="w-1/4 bg-gray-200 p-4 overflow-y-auto">
          <h2 class="text-xl font-bold mb-4">History</h2>
          <!-- History items here -->
        </div>

        <!-- Main chat area -->
        <div class="w-3/4 flex flex-col">
          <div class="flex-grow overflow-y-auto p-4 prose">
            <%= Enum.map(@messages, fn(msg) -> %>
              <div class={msg.role}><%= Phoenix.HTML.raw(Earmark.as_html!(msg.content)) %></div>
            <% end) %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
