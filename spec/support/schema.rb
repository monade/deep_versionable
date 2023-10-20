require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

module Schema
  def self.create
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table :users, force: true do |t|
        t.string   :first_name
        t.string   :last_name
        t.timestamps null: false
      end

      create_table :reactions, force: true do |t|
        t.bigint   :comment_id
        t.timestamps null: false
      end

      create_table :emojis, force: true do |t|
        t.string   :name
        t.bigint   :reaction_id
        t.timestamps null: false
      end

      create_table :comments, force: true do |t|
        t.string  :text
        t.bigint   :pots_id
        t.timestamps null: false
      end

      create_table :posts, force: true do |t|
        t.string  :body
        t.bigint   :user_id
        t.timestamps null: false
      end
    end
  end
end
