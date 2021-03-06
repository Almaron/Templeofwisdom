class SprHerb < SprPage
  serializable_attributes :look, :place, :names, :healing, :life, :other

  validates_uniqueness_of :name

  def main_params
    %i(look place names)
  end

  def use_params
    %i(healing life)
  end
end