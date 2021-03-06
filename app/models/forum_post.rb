class ForumPost < ActiveRecord::Base

  validates_presence_of :char_id, :ip, :text

  belongs_to :topic, class_name: ForumTopic, foreign_key: :topic_id
  belongs_to :char
  belongs_to :user

  after_create :touch_topic
  # before_destroy :check_if_last
  after_destroy :remove_post
  before_update :change_char, if: :char_id_changed?

  belongs_to :avatar, class_name: CharAvatar, foreign_key: :avatar_id

  def touch_topic
    self.topic.add_post(self)
    ForumTopicRead.create(user_id: self.user_id, forum_topic_id: self.topic_id)
  end

  def remove_post
    self.topic.remove_post(self) if self.topic
  end

  def check_if_last
    self.topic.last_post_id == self.id
  end

  def change_char
    topic.update last_post_char_name: char.name if topic.last_post_id == id
    Forum.where(last_post_id: id).update_all last_post_char_name: char.name
  end

  after_update :set_topic_char

  def set_topic_char
    self.topic.update({char_id: self.char_id, poster_name: self.char.name}) if char_id_changed? && is_first_post?
  end

  def is_first_post?
    self.class.where(topic_id:topic_id).first == id
  end


end
