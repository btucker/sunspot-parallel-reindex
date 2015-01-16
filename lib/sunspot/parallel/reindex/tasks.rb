namespace :sunspot do
  namespace :reindex do
    desc "Reindex models in parallel"
    task :parallel, [:batch_size, :models, :exec_processor_size] => :environment do |t, args|
      with_session(Sunspot::SessionProxy::Retry5xxSessionProxy.new(Sunspot.session)) do
        reindex_options = { :batch_commit => false,
                            :exec_processor_size => Parallel.processor_count,
                            :batch_size => 1000 }

        case args[:exec_processor_size]
        when 'false'
          reindex_options[:exec_processor_size] = 1
        when /^\d+$/
          reindex_options[:exec_processor_size] = args[:exec_processor_size].to_i if args[:exec_processor_size].to_i > 0
        end

        case args[:batch_size]
        when 'false'
          reindex_options[:batch_size] = 1000
        when /^\d+$/
          reindex_options[:batch_size] = args[:batch_size].to_i if args[:batch_size].to_i > 0
        end

        puts "#{Parallel.processor_count} procesor(s)"
        puts "reindex using #{reindex_options[:exec_processor_size]} procesor(s)"

        # Load all the application's models. Models which invoke 'searchable' will register themselves
        # in Sunspot.searchable.
        Rails.application.eager_load!
        Rails::Engine.subclasses.each{|engine| engine.instance.eager_load!}
  
        if args[:models].present?
          # Choose a specific subset of models, if requested
          model_names = args[:models].split(/[+ ]/)
          sunspot_models = model_names.map{ |m| m.constantize }
        else
          # By default, reindex all searchable models
          sunspot_models = Sunspot.searchable
        end

        total_documents = sunspot_models.map { | m | m.count }.sum
        sorted_models = sunspot_models.sort{|a, b| a.count <=> b.count}

        # Set up progress_bar to, ah, report progress
        begin
          require 'progress_bar'
          reindex_options[:progress_bar] = ProgressBar.new(total_documents)
        rescue LoadError => e
          $stdout.puts "Skipping progress bar: for progress reporting, add gem 'progress_bar' to your Gemfile"
        rescue Exception => e
          $stderr.puts "Error using progress bar: #{e.message}"
        end

        $stdout.puts "Reindex model list:"
        sorted_models.each { |model|
          $stdout.puts " name=#{model.name} record_size=#{model.count}"
        }
        $stdout.flush

        sorted_models.each do |model|
          model.solr_remove_all_from_index
          model.solr_index_parallel(reindex_options)
        end
      end
    end
  end
  namespace :parallel do
    task :reindex => Rake::Task['sunspot:reindex:parallel']
  end
end
