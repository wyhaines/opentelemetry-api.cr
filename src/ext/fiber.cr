class Fiber
  def <=>(val)
    self.object_id <=> val.object_id
  end
end
