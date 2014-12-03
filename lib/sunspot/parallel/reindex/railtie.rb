module Sunspot
  module Solr
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "sunspot/parallel/reindex/tasks.rb"
      end
    end
  end
end
