json.topics @topics do |topic|
  json.(topic, :id, :head, :poster_name, :posts_count, :last_post_id, :last_post_char_name, :last_post_char_id, :char_id)
  json.last_post_at I18n.l(topic.last_post_at, format: :full) if topic.last_post_at
  json.hidden topic.hidden?
  json.closed topic.closed?
end

json.total (@all_topics.count.to_f / 25).ceil if @all_topics
