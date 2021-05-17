defmodule CustomerFeedback.Utils do
  @moduledoc """
  Contains common functions that does not related to some specific context, but may be used in many parts of the project
  """

  @spec changeset_error_to_string(Ecto.Changeset.t()) :: binary
  def changeset_error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> stringify_errors()
  end

  @spec stringify_errors(map) :: binary
  defp stringify_errors(errors) when is_map(errors) do
    errors
    |> Enum.map(fn
      {k, v} when is_map(v) ->
        joined_errors = stringify_errors(v)
        "#{k}: [#{joined_errors}]"

      {k, v} ->
        joined_errors = Enum.join(v, ", ")
        "#{k}: #{joined_errors}"
    end)
    |> Enum.join("; ")
  end

  @spec safe_to_integer(integer | binary) :: integer
  def safe_to_integer(value) when is_integer(value), do: value
  def safe_to_integer(value) when is_binary(value) do
    {integer_value, _} = Integer.parse(value)
    integer_value
  end
end