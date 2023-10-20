# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeepVersionable do
  it 'should include itself in the model' do
    expect(Post.included_modules).to include(DeepVersionable)
  end

  it 'should correctly parse the include hash' do
    include = {
      include: [
        :user,
        comments: {
          include: [
            reactions: {
              include: [
                :emojis
              ]
            }
          ]
        }
      ]
    }

    expect(Post._deep_versionable_relations).to eq(include)
  end

  it 'should declare versionable classes' do
    expect(Object.const_defined?('Version::User')).to be_truthy
    expect(Object.const_defined?('Version::Comment')).to be_truthy
    expect(Object.const_defined?('Version::Reaction')).to be_truthy
    expect(Object.const_defined?('Version::Emoji')).to be_truthy
    expect(Object.const_defined?('Version::Post')).to be_truthy
  end

  it 'should declare versionable serializers' do
    expect(Object.const_defined?('Version::UserSerializer')).to be_truthy
    expect(Object.const_defined?('Version::CommentSerializer')).to be_truthy
    expect(Object.const_defined?('Version::ReactionSerializer')).to be_truthy
    expect(Object.const_defined?('Version::EmojiSerializer')).to be_truthy
    expect(Object.const_defined?('Version::PostSerializer')).to be_truthy
  end

  it 'should declare versionable serializers starting from existing serializers' do
    expect(Version::UserSerializer.superclass).to eq(UserSerializer)
    expect(Version::PostSerializer.superclass).to eq(PostSerializer)
    expect(Version::CommentSerializer.superclass).to eq(CommentSerializer)
    expect(Version::ReactionSerializer.superclass).to eq(ReactionSerializer)
    expect(Version::EmojiSerializer.superclass).to eq(ApplicationSerializer)
  end
end

