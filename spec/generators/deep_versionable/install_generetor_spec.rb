# frozen_string_literal: true

require "spec_helper"
require "generator_spec/test_case"
require "generators/deep_versionable/install/install_generator"

RSpec.describe DeepVersionable::InstallGenerator, type: :generator do
  include GeneratorSpec::TestCase
  destination File.expand_path("tmp", __dir__)

  after do
    prepare_destination # cleanup the tmp directory
  end

  before do
    prepare_destination
    run_generator
  end

  it "generates a migration for creating the 'versions' table" do
    expected_parent_class = lambda {
      old_school = "ActiveRecord::Migration"
      ar_version = ActiveRecord::VERSION
      format("%s[%d.%d]", old_school, ar_version::MAJOR, ar_version::MINOR)
    }.call

    expect(destination_root).to(
      have_structure {
        directory("db") {
          directory("migrate") {
            migration("create_versions") {
              contains("class CreateVersions < " + expected_parent_class)
            }
          }
        }
      }
    )
  end
end
