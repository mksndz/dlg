# frozen_string_literal: true

require 'rake'

task(:feed_the_dpla, [:records_per_file] => [:environment]) do |_, args|
  svc = MassExporterService.new(:jsonl)
  svc.perform
end