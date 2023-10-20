# frozen_string_literal: true

require_relative "../migration_generator"

module DeepVersionable
  class InstallGenerator < MigrationGenerator
    source_root File.expand_path("templates", __dir__)
    class_option(
      :with_changes,
      type: :boolean,
      default: false,
      desc: "Store changeset (diff) with each version"
    )
    class_option(
      :uuid,
      type: :boolean,
      default: false,
      desc: "Use uuid instead of bigint for item_id type (use only if tables use UUIDs)"
    )

    desc "Generates (but does not run) a migration to add a versions table." \
         "  See section 5.c. Generators in README.md for more information."

    def create_migration_file
      add_deep_versionable_migration(
        "create_versions",
      )
    end
  end
end
