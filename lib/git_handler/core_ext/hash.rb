class Hash
  def keys_all?(keys)
    self.keys.include_all?(keys)
  end

  def keys_any?(keys)
    self.keys.include_any?(keys)
  end
end