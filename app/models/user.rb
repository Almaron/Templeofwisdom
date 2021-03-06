class User < ActiveRecord::Base
  trimmed_fields :name, :email, :password, :password_confirmation

  include Cancans

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  default_scope {order(:name)}
  scope :present, ->{where("activation_state != 'destroyed'")}
  scope :active, ->{where(activation_state: 'active')}
  scope :destroyed, ->{where(activation_state: 'destroyed')}

  def pending?
    activation_state == 'pending'
  end

  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  has_many :questions, class_name: MasterQuestion
  has_many :answers, class_name: MasterAnswer

  attr_accessor :current_ip

  validates_confirmation_of :password, :if => :password, message: I18n.t("activerecord.errors.models.user.attributes.password.confirmation")
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, email: true, uniqueness: true

  has_one :profile, class_name: UserProfile, dependent: :destroy
  accepts_nested_attributes_for :profile
  after_create {self.create_profile}

  has_many :ips, class_name: UserIp

  def add_ip(ip)
    ips.find_or_create_by!(ip:ip)
  end

  def is_in?(groups)
    groups = groups.is_a?(Array) ? groups : [groups]
    groups.include? self.group.to_sym
  end

  has_many :forum_post_drafts, dependent: :delete_all
  has_many :forum_topic_drafts, dependent: :delete_all

  def destroyed?
    activation_state == 'destroyed'
  end

  has_many :char_delegations
  has_many :chars, :through => :char_delegations

  def default_char=(char)
    char_id = char.is_a?(Char) ? char.id : char
    if (cd = self.char_delegations.find_by(owner:true, char_id:char_id))
      self.char_delegations.update_all(default:false)
      cd.update(default:true)
    end
  end

  def default_char
    @default_char ||= self.chars.where(char_delegations: {owner:1, default:1}).first
  end

  def owned_chars
    self.chars.where(char_delegations: {owner:1})
  end

  def own_chars
    owned_chars.visible
  end

  def delegated_chars
    self.chars.where(char_delegations: {owner:0})
  end

  def has_char?(char_id)
    char_ids.include? char_id
  end

  def has_privilege?
    false
  end

  has_many :role_apps

  #Messages

  has_many :messages, dependent: :destroy
  has_many :message_receivers, dependent: :destroy

  def unread_messages_count
    self.message_receivers.where(read:0).group(:message_id).to_a.size
  end

  def delete_message(message)
    mid = message.is_a? Message ? message.id : message
    self.receivers.where(message_id:mid).destroy_all
  end

  def read_message(message)
    mid = message.is_a? Message ? message.id : message
    self.receivers.where(message_id:mid).update_all(read:1)
  end

  has_many :notifications

  def unread_notifications_count
    self.notifications.where(read:0).count
  end

  has_many :skill_requests

  def has_privilige?(privilege = 'view_hidden')
    false
  end


end
