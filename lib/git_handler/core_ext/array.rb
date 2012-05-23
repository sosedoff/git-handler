class Array
  def include_all?(values)
    (self - values).empty?
  end

  def include_any?(values)
    (self & values).any?
  end
end