# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Version, type: :model do
  it 'should correctly reify a version' do
    post = Post.create!(
      body: 'Body Post',
      user: User.create!(
        first_name: 'John',
        last_name: 'Doe'
      ),
      comments: [
        Comment.create!(
          text: 'Comment 1',
          reactions: [
            Reaction.create!(
              emoji: Emoji.create!(name: 'Emoji 1'),
            ),
            Reaction.create!(
              emoji: Emoji.create!(name: 'Emoji 2'),
            )
          ]
        ),
        Comment.create!(
          text: 'Comment 2',
          reactions: [
            Reaction.create!(
              emoji: Emoji.create!(name: 'Emoji 3'),
            ),
            Reaction.create!(
              emoji: Emoji.create!(name: 'Emoji 4'),
            )
          ]
        )
      ]
    )

    post.versionize!

    reified_post = post.versions.last.reify

    expect(reified_post).to be_a(Version::Post)
    expect(reified_post.id).to eq(1)
    expect(reified_post.body).to eq('Body Post')

    expect(reified_post.user).to be_a(Version::User)
    expect(reified_post.user.id).to eq(1)
    expect(reified_post.user.first_name).to eq('John')
    expect(reified_post.user.last_name).to eq('Doe')

    expect(reified_post.comments).to be_a(Array)
    expect(reified_post.comments.length).to eq(2)

    expect(reified_post.comments[0]).to be_a(Version::Comment)
    expect(reified_post.comments[0].id).to eq(1)
    expect(reified_post.comments[0].text).to eq('Comment 1')
    expect(reified_post.comments[0].reactions).to be_a(Array)
    expect(reified_post.comments[0].reactions.length).to eq(2)
    expect(reified_post.comments[0].reactions[0]).to be_a(Version::Reaction)
    expect(reified_post.comments[0].reactions[0].id).to eq(1)
    expect(reified_post.comments[0].reactions[0].emoji).to be_a(Version::Emoji)
    expect(reified_post.comments[0].reactions[0].emoji.id).to eq(1)
    expect(reified_post.comments[0].reactions[0].emoji.name).to eq('Emoji 1')
    expect(reified_post.comments[0].reactions[1]).to be_a(Version::Reaction)
    expect(reified_post.comments[0].reactions[1].id).to eq(2)
    expect(reified_post.comments[0].reactions[1].emoji).to be_a(Version::Emoji)
    expect(reified_post.comments[0].reactions[1].emoji.id).to eq(2)
    expect(reified_post.comments[0].reactions[1].emoji.name).to eq('Emoji 2')

    expect(reified_post.comments[1]).to be_a(Version::Comment)
    expect(reified_post.comments[1].id).to eq(2)
    expect(reified_post.comments[1].text).to eq('Comment 2')
    expect(reified_post.comments[1].likes).to be_a(Array)
    expect(reified_post.comments[1].likes.length).to eq(2)
    expect(reified_post.comments[1].likes[0]).to be_a(Version::Like)
    expect(reified_post.comments[1].likes[0].id).to eq(3)
    expect(reified_post.comments[1].likes[0].user).to be_a(Version::User)
    expect(reified_post.comments[1].likes[0].user.id).to eq(4)
    expect(reified_post.comments[1].likes[0].user.name).to eq('User 2')
    expect(reified_post.comments[1].likes[1]).to be_a(Version::Like)
    expect(reified_post.comments[1].likes[1].id).to eq(4)
    expect(reified_post.comments[1].likes[1].user).to be_a(Version::User)
    expect(reified_post.comments[1].likes[1].user.id).to eq(5)
    expect(reified_post.comments[1].likes[1].user.name).to eq('User 4')
  end
end

