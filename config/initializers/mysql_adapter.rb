module ActiveRecord
  module Tasks
    class MySQLDatabaseTasks
      # override to add more mysqldump options
      def structure_dump(filename)
        args = prepare_command_options('mysqldump')
        args.concat(["--result-file", "#{filename}"])
        args.concat(["--no-data"])
        ##########################################
        # added options
        args.concat(["--routines"]) # procedure & function
        args.concat(["--skip-comments"])
        ##########################################
        args.concat(["#{configuration['database']}"])
        unless Kernel.system(*args)
          $stderr.puts "Could not dump the database structure. "\
                       "Make sure `mysqldump` is in your PATH and check the command output for warnings."
        ##########################################
        # added replacing DEFINER in a file (structure.sql)
        else
          text = File.read(filename)
          File.open(filename, "w") do |file|
            file.puts text.gsub(/(\/\*!\d+)?\s*DEFINER\s*=\s*`\S+`@`\S+`\s*(SQL SECURITY DEFINER)?\s*(\*\/)?/i, " ")
          end
          text = File.read(filename)
          File.open(filename, "w") do |file|
            file.puts text.gsub(/\s+AUTO_INCREMENT=\d+\s+/i, " ")
          end  
        ##########################################
        end
      end
    end
  end
end