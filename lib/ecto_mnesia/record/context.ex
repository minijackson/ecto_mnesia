defmodule Ecto.Mnesia.Record.Context do
  @moduledoc """
  Context for operations with a database.
  """
  alias Ecto.Mnesia.Table
  alias Ecto.Mnesia.Record.Context

  defstruct schema: nil, table: nil, fields: [], select: [], match_body: nil

  def new(table, schema) when is_binary(table) and is_atom(schema) do
    table = table |> Table.get_name()
    mnesia_attributes = table |> Table.attributes()

    fields = 1..length(mnesia_attributes)
    |> Enum.map(fn index ->
      {Enum.at(mnesia_attributes, index - 1), {index - 1, String.to_atom("$#{index}")}}
    end)

    %Context{schema: schema, table: table, fields: fields, select: mnesia_attributes, match_body: nil}
  end

  def update_select(context, nil), do: context
  def update_select(context, %Ecto.Query{select: select}), do: update_select(context, select)
  def update_select(context, select), do: %{context | select: select}

  def update_match_body(context, match_body), do: %{context | match_body: match_body}

  def find_index!(field, %Context{fields: fields, table: table}) when is_atom(field) do
    case Keyword.get(fields, field) do
      nil -> raise ArgumentError, "Field `#{inspect field}` does not exist in table `#{inspect table}`"
      {index, _placeholder} -> index
    end
  end

  def find_placeholder!(field, %Context{fields: fields, table: table}) when is_atom(field) do
    case Keyword.get(fields, field) do
      nil -> raise ArgumentError, "Field `#{inspect field}` does not exist in table `#{inspect table}`"
      {_index, placeholder} -> placeholder
    end
  end
  def find_placeholder!(field, %Context{}), do: field

  def get_placeholders(%Context{fields: fields}) do
    fields
    |> Enum.map(fn {_name, {_index, placeholder}} -> placeholder end)
  end
end
