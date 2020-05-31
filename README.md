# LSATs for Elixir

LSATs are a set of rules to work with payable cookies.
The main rule is that they work over HTTP. 
You use the 402 Payment Required status code, the Authorization and Authenticate headers to request and provide information to the user.
These cookies can encode access levels, services, and/or capabilities to access a given website or API. 
Effectively, you can provide a user with an API key without asking for signup or personal information, just payment. 

A service must run a Lightning Node to generate invoices and process payments. 
These invoices are cryptographic "tickets" that encode a set of capabilities. 
Once paid, the user gets a "preimage", a proof that they paid this invoice. 
They submit that proof, along with their cookie, to the service in the Authorization header. 

The user, of course, needs to have a Lightning-enabled wallet to access this service. 

### Setup

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

