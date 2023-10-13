defmodule DocChatWeb.SearchLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, search_activated: false, question: nil, messages: [], loading: false, chain: nil)}
  end

  def handle_event("submit_question", %{"question" => question}, socket) do
    user_question = %{content: question, role: :user}
    new_messages = socket.assigns.messages ++ [user_question]

    Task.async(fn ->
      chain = socket.assigns.chain
      if chain != nil do
        DocChat.Articles.ask(question, chain)
      else
        DocChat.Articles.ask(question)
      end
    end)
    {:noreply, assign(socket, search_activated: true, question: question, messages: new_messages, loading: true)}
  end

  def handle_info({ref, result}, socket) do
    Process.demonitor(ref, [:flush])
    {:ok, chain} = result
    {:noreply,
      assign(socket,
        search_activated: false,
        question: "",
        chain: chain,
        messages: format_messages(chain.messages),
        loading: false)}
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
    <div class="flex flex-col">
      <!-- Scrollable message container -->
      <h1 class="mt-8 ml-8 text-2xl font-bold">Doc Chat</h1>
      <div id="message-container" phx-hook="ScrollToBottom" class="flex flex-col space-y-4 p-4 w-1/2 mx-auto overflow-y-auto h-1/2 h-[600px]">
        <%= for msg <- @messages do %>
          <div class={ "self-start w-full " <> (if msg.role == :user, do: "text-black", else: "bg-gray-100 text-black") }>
            <div class="px-4 py-0 prose">
              <div class={msg.role}><%= Phoenix.HTML.raw(Earmark.as_html!(msg.content)) %></div>
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
          <form phx-submit="submit_question" class="flex w-1/2 mx-auto relative">
            <input type="text"
              name="question"
              placeholder="Enter your question..."
              class="p-2 flex-grow outline-none rounded-full pl-6 focus:outline-none"
              phx-input="search"
              value={@question} />
            <button type="submit" class="absolute inset-y-0 right-0 p-2 flex items-center justify-center w-10 pr-6">
              <i class="fas fa-paper-plane text-gray-600"></i>
            </button>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
