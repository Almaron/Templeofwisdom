module Notes
  class CharAccept < SystemNote
    def create(char)
      Notification.create({
        user_id: char.owner.id,
        head: I18n.t('notifications.system.head.notify_char_accept'),
        text: render(partial: 'shared/notifications/notify_char_accept', locals: {char: char, forum_id: char_forum_id(char)})
      })
    end

    def char_forum_id(char)
      AdminConfig.find_by(name: "char_profile_forum_id_#{char.group_id}").value.to_i
    end
  end
end