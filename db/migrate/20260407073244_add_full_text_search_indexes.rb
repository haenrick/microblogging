class AddFullTextSearchIndexes < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE INDEX index_posts_on_content_fts
        ON posts USING gin(to_tsvector('simple', coalesce(content, '')));

      CREATE INDEX index_users_on_username_bio_fts
        ON users USING gin(to_tsvector('simple', coalesce(username, '') || ' ' || coalesce(bio, '')));
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX IF EXISTS index_posts_on_content_fts;
      DROP INDEX IF EXISTS index_users_on_username_bio_fts;
    SQL
  end
end
