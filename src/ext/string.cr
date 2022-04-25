class String
  # The `#lpad` method takes a string size, and an optional padding string, and it
  # returns a new string, of the specified size, with any empty space to the left
  # filled with repetitions of the padding string. If the size is smaller than the
  # size of the original string, it is truncated from the left to match the requested
  # final size.
  def lpad(size, padding = " ")
    pad_str = padding.to_s
    pad_size = size - self.size
    base_size = pad_size > 0 ? (size - pad_size) : size
    offset = base_size == size ? self.size - base_size : 0

    String.build(capacity: size) do |str|
      str << (pad_str * (pad_size // pad_str.size + 1))[0..(pad_size - 1)] if pad_size > 0
      str << self[(0 + offset)..(base_size + offset)]
    end
  end

  # The `#rpad` method takes a string size, and an optional padding string, and it
  # returns a new string, of the specified size, with any empty space to the right
  # filled with repetitions of the padding string. If the size is smaller than the
  # size of the original string, it is truncated from the right to match the requested
  # final size.
  def rpad(size, padding = " ")
    pad_str = padding.to_s
    pad_size = size - self.size
    base_size = pad_size > 0 ? (size - pad_size) : size

    String.build(capacity: size) do |str|
      str << self[0..(base_size - 1)]
      str << (pad_str * (pad_size // pad_str.size + 1))[0..(pad_size - 1)] if pad_size > 0
    end
  end
end
