defmodule DocChatWeb.SearchLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, search_activated: false, question: nil)}
  end

  def handle_event("submit_question", %{"question" => question}, socket) do
    {:noreply, assign(socket, search_activated: true, question: question)}
  end

  def render(assigns) do
    ~L"""
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
            value="<%= @question %>" />
            <button type="submit" class="p-2 bg-blue-500 text-white flex items-center justify-center w-10">
              <i class="fas fa-paper-plane"></i>
            </button>
          </form>
        </div>
      </div>
    
      <!-- Sidebar for history and chat area, only when search is activated -->
      <%= if @search_activated do %>
      <div class="flex w-full mt-10">
        <!-- Sidebar for history -->
        <div class="w-1/4 bg-gray-200 p-4 overflow-y-auto">
          <h2 class="text-xl font-bold mb-4">History</h2>
          <!-- History items here -->
        </div>
    
        <!-- Main chat area -->
        <div class="w-3/4 flex flex-col">
          <div class="flex-grow overflow-y-auto p-4">
            <!-- Chat messages go here -->
          </div>
        </div>
      </div>
      <% end %>
    </div>
    """
  end 
end
