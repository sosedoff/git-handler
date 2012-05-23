class Array
  def include_all?(values)
    (values - self).empty?
  end

  def include_any?(values)
    (self & values).any?
  end
end