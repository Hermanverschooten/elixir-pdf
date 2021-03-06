defprotocol Pdf.Size do
  @moduledoc false
  def size_of(object)
end

defimpl Pdf.Size, for: BitString do
  def size_of(string), do: byte_size(string)
end

defimpl Pdf.Size, for: Integer do
  def size_of(number), do: Pdf.Size.size_of(Integer.to_string(number))
end

defimpl Pdf.Size, for: Float do
  def size_of(number),
    do: Pdf.Size.size_of(Pdf.Export.to_iolist(number))
end

defimpl Pdf.Size, for: Date do
  def size_of(_date), do: 12
end

defimpl Pdf.Size, for: DateTime do
  def size_of(%{utc_offset: 0}), do: 19
  def size_of(_date), do: 24
end

defimpl Pdf.Size, for: List do
  def size_of([]), do: 0
  def size_of([_ | _] = list), do: Enum.reduce(list, 0, &(Pdf.Size.size_of(&1) + &2))
end

defimpl Pdf.Size, for: Tuple do
  def size_of({:name, string}), do: 1 + Pdf.Size.size_of(string)

  def size_of({:string, string}), do: 2 + Pdf.Size.size_of(string)

  def size_of({:object, number, generation}),
    do: 4 + Pdf.Size.size_of(number) + Pdf.Size.size_of(generation)

  def size_of({:command, [_ | _] = list}), do: length(list) - 1 + Pdf.Size.size_of(list)
  def size_of({:command, command}), do: Pdf.Size.size_of(command)
end
