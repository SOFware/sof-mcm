# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require "reissue/gem"

Reissue::Task.create :reissue do |task|
  task.version_file = "lib/sof/mcm/version.rb"
end

require "standard/rake"
