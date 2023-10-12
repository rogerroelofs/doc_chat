# DocChat

This app uses the OpenAI api to use the docs from apricot-articles to feed GPT4 to answer questions about how to use Apricot.

Configure your OpenAI API key and org id in `.env` with the following:

```
OPENAI_KEY=YOUR_KEY
OPENAI_ORG_ID=YOUR_ORG_ID
```
The key and org id can be made at https://platform.openai.com/account/api-keys and https://platform.openai.com/account/org-settings respectively.

Configure your postgres password in `.env` like so:
```
POSTGRES_PASSWORD=<whatever>
```
For a local Postgres server, run:
```docker-compose up -d```

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix with `iex -S mix phx.server`.

To import data:
```
iex(1)> DocChat.Articles.import("./filtered")
```

To try searching:
```
iex(1)> DocChat.Articles.search("Rules Alerts")
```

To try talking to ChatGPT:
```
iex(1)> DocChat.Articles.ask("How do I make a Rule?")
```

To get out of Iex press Ctrl-c twice.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
