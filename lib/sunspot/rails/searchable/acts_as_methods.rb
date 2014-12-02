require 'parallel'

module Sunspot
  module Rails
    module Searchable
      module ActsAsMethods
        def solr_index_parallel(opts={})

          options = {
            :batch_size => Sunspot.config.indexing.default_batch_size,
            :batch_commit => true,
            :include => self.sunspot_options[:include],
            :start => opts.delete(:first_id) || 0
          }.merge(opts)
          
          find_in_batch_options = {
            :batch_size => options[:batch_size],
            :start => options[:start]
          }
          
          exec_processor_size = options[:exec_processor_size]
          progress_lambda = lambda { |item, _, _|
            if options[:progress_bar]
              options[:progress_bar].increment!(item.size)
            end
          }
          
          if options[:batch_size]
            batch_counter = 0
            self.includes(options[:include]).find_in_batches(find_in_batch_options) do |records|
              ::ActiveRecord::Base.establish_connection
              ::Parallel.each(records.in_groups(exec_processor_size),
                            in_processes: exec_processor_size,
                            finish: progress_lambda) do |batch|
                ::ActiveRecord::Base.establish_connection
                solr_benchmark(batch.size, batch_counter += 1) do
                  Sunspot.index(batch.select { |r| r.indexable? })
                  Sunspot.commit if options[:batch_commit]
                end
              end
            end
          else
            records = all(:include => options[:include]).select { |model| model.indexable? }
            Sunspot.index!(records)
          end

          # perform a final commit if not committing in batches
          Sunspot.commit unless options[:batch_commit]
        end
      end
    end
  end
end
