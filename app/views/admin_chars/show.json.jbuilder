json.(@char, :id, :name, :group_id, :status_id, :status_line)
json.group_name I18n.t("char_groups.names.#{@char.group.name}")

json.profile_attributes do
  json.(@char.profile_info, :birth_date, :real_age, :place, :beast, :phisics, :items, :bio, :look, :character, :person, :other, :comment, :points)
end

json.avatars @char.avatars, partial:'char_avatars/char_avatar', as: :avatar

json.magic_skills @char.magic_skills.eager_load(:skill, :level) do |ch|
  json.(ch, :skill_id, :level_id)
  json.skill_name ch.skill.name
  json.level_name ch.level.name
end

json.phisic_skills @char.phisic_skills.eager_load(:skill, :level) do |ch|
  json.(ch, :skill_id, :level_id)
  json.skill_name ch.skill.name
  json.level_name ch.level.name
end