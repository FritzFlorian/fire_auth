# FireAuth

Server side verification of firebase authentication using ID tokens.

In short this library will allow you to use 
[firebase auth](https://firebase.google.com/docs/auth/)
as an authentication method for your backend.
The client app/webapp can generate an token that is then sent with
each request to your backend to identifiy users.

## Client Side

On the client side you will have to generate an ID token.
See the [firebase doc](https://firebase.google.com/docs/auth/)
for detailed instructions.

After you got the token simply include it as a header in each request:
```
Authorization : Bearer <put-your-token-here>
```

## Server Side

Start by setting your firebase project id in your config file:
```elixir
config :fire_auth,
  project_id: "project-id"
```

Add the following plug to validate the id token:
```elixir
plug FireAuth
```
This will validate the id token in the request header and put
information about it into `conn.assigns.fire_auth.info`.

To use the library for full authentication (load a user form the DB) use this plug:
```elixir
plug FireAuth, [load_user: &load_user/1, load_groups: &load_groups/2]
```
Where `&load_user/1` and `&load_groups/2` are used to load the
user model from your database and to extract the users groups
out of the loaded user model.

For example this would be typical implementations:
```elixir
def load_user(%{id: firebase_id} = _info) do
	# Ideally do an insert or update here
	Repo.get_by(User, firebase_id: firebase_id)
end

def load_groups(user, _info) do
	user.groups
end
```

With this set you can secure individual routes using
the `FireAuth.Secure` plug:
```elixir
# can only be accesed if the request contains an valid token
plug FireAuth.Secure

# only secure the :index action (in a phoenix project) 
plug FireAuth.Secure when action in [:index]

# can only be accessed by users with the required_group
plug FireAuth.Secure, group: "required_group"
   
```

It is a very simple system, but works very well for most
smaller projects and is especially nice nice to get started fast.
