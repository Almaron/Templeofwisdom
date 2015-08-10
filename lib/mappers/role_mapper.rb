module Mappers
  class RoleMapper
    attr_reader :mdb, :fdb, :logger

    def initialize(main, forum, logger)
      @mdb, @fdb, @logger = main, forum, logger
    end

    def map
      role = Role.new
      db.query('SELECT * FROM temple_main.a_rolls ORDER BY head').each do |row|
        unless role.head == row['head']
          role.head = role.head.strip
          role.save

          role = set_role(row)
        end
        cr = role.char_roles.build char_id: char_map.index(row['char_id'])
        role_skills(row['skills']).each do |rs|
          cr.role_skills.build rs
        end
      end
    end

    private

    def set_role(row)
      role = Role.new head: row['head']
      role.topic_ids = parse_ids(row['links'])
    end

    def parse_ids(links)
      URI.extract(links).map do |link|
        params = Rack::Utils.parse_nested_query(URI(link).query).symbolize_keys
        unless (topic_id = params[:t])
          topic_id = fdb.query("SELECT topic_id FROM hor_posts WHERE post_id = #{params[:p]}").first['topic_id']
        end
        topics_map.index topic_id
      end
    end

    def role_skills(skills)
      JSON.parse(skills).map do |skl|
        {
          skill_id: skill_map[skl['skill'].to_i],
          done: skl['done'].to_i
        }
      end
    end

    def topics_map
      @topics_map ||= TopicIdMapper.new(fdb).map
    end

    def char_map
      @char_map ||= CharIdMapper.new(mdb).map
    end

    def skill_map
      @skill_id ||= SkillMapper.map
    end
  end
end
