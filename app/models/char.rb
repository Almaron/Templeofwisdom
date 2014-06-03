class Char < ActiveRecord::Base

  validates :name, :uniqueness => true, :presence => true

  belongs_to :group, :class_name => CharGroup
  belongs_to :status, :class_name => CharStatus

  has_one :profile, class_name: CharProfile
  accepts_nested_attributes_for :profile

  mount_uploader :avatar, AvatarUploader

  has_many :char_delegations
  has_many :users, :through => :char_delegations

  def delegate_to(user, options={})
    user_id = user.is_a?(User) ? user.id : user
    @cd = self.char_delegations.find_or_initialize_by(:user_id => user_id)
    options.each_pair { |option, value| @cd.send(:"#{option}=", value) }
    @cd.save
  end

  def undelegate(user)
    user_id = user.is_a?(User) ? user.id : user
    self.char_delegations.find_by(:user_id => user_id).destroy
  end

  def owned_by
    self.users.where(char_delegations: {owner:1}).first
  end

  def delegated_to
    self.users.where(char_delegations: {owner:0})
  end

  has_many :char_skills
  has_many :skills, through: :char_skills

  def phisic_skills
    self.char_skills.phisic
  end

  def magic_skills
    self.char_skills.magic
  end
end
