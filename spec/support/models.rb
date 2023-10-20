class User < ActiveRecord::Base
  has_many :posts
end
class Comment < ActiveRecord::Base
  belongs_to :post
  has_many :reactions
end

class Reaction < ActiveRecord::Base
  belongs_to :comment
  has_one :emoji
end

class Emoji < ActiveRecord::Base
  belongs_to :reaction
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  as_deep_versionable
  deep_versionable include: [
    :user,
    comments: [
      reactions: [
        :emojis
      ]
    ]
  ]
end
