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

  @spec prefix_mandatory_char(binary, binary) :: binary
  def prefix_mandatory_char(prefixed_string, prefixed_char) do
    with value when value != "" <- prefixed_string,
         {:prefixing_char_valid, true} <-
           {:prefixing_char_valid, String.length(prefixed_char) == 1},
         {:need_prefix_string, true} <-
           {:need_prefix_string, String.slice(prefixed_string, 0, 1) != prefixed_char} do
      "#{prefixed_char}#{prefixed_string}"
    else
      "" ->
        raise ArgumentError, message: "First argument must contain at least one character"

      {:prefixing_char_valid, false} ->
        raise ArgumentError, message: "Second argument must be one character exactly"

      {:need_prefix_string, false} ->
        prefixed_string
    end
  end
end
