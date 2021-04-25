alias CustomerFeedback.Users

default_admin_params = %{
  name: "Alpha and Omega"
}

{:ok, _admin} = Users.create_admin(default_admin_params)
