class User < Struct.new :id, :name, :email

  def to_authentication_hash
    self.to_h
  end

  def self.from_authentication_hash hash
    hash.symbolize_keys!
    hash[:id] = hash[:id].to_i
    User.new *hash.values_at(*User.members)
  end

end
