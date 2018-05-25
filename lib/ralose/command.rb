module RaLoSe
  class Command

    RED         = "\e[31m".freeze
    RESET_COLOR = "\e[0m".freeze

    # [a9c56d04-d706-49ae-b0a2-e7636c650d5e]
    REQUEST_ID_RE = /\[[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\]/.freeze

    def self.run!
      # Pipe handling based on: https://www.jstorimer.com/blogs/workingwithcode/7766125-writing-ruby-scripts-that-respect-pipelines



      colorized_output = true
      case_insensitive = false

      require 'optparse'
      OptionParser.new do |options|
        # This banner is the first line of the help documentation.
        options.banner = "Usage: ralose [options] [files]\n\n" \
          "Prints out all lines for a Rails request where one line in that request " \
          "matches the passed search string."

        # Separator just adds a new line with the specified text.
        options.separator ""
        options.separator "Specific options:"

        options.on("-i", "Perform case insensitive matching. By default, ralose is case sensitive.") do |be_case_insensitive|
          case_insensitive = be_case_insensitive
        end

        options.on("--no-color", "Disable colorized output") do |use_color|
          colorized_output = use_color
        end

        # on_tail says that this option should appear at the bottom of
        # the options list.
        options.on_tail("-h", "--help", "You're looking at it!") do
          $stderr.puts options
          exit 1
        end
      end.parse!

      query = ARGV.shift

      current_request_id = nil
      current_request_lines = []
      print_current_request = false

      # Read from file passed in ARGV, or STDIN.
      ARGF.each_line do |line|

        request_id = line[REQUEST_ID_RE]

        if request_id.nil?
          next
        end

        if request_id != current_request_id
          if print_current_request
            current_request_lines.each do |current_request_line|
              begin
                $stdout.puts current_request_line

              # Handle case where output pipe is closed before writing is completed.
              rescue Errno::EPIPE
                exit(74)
              end
            end
          end

          current_request_id    = request_id
          current_request_lines = []
          print_current_request = false
        end

        if case_insensitive
          query_index = line.downcase.index(query.downcase)
        else
          query_index = line.index(query)
        end

        if query_index
          print_current_request = true

          if colorized_output
            line.insert(query_index + query.length, RESET_COLOR)
            line.insert(query_index, RED)
          end
        end

        current_request_lines << line

      end

      if print_current_request
          current_request_lines.each do |current_request_line|
          begin
            $stdout.puts current_request_line

          # Handle case where output pipe is closed before writing is completed.
          rescue Errno::EPIPE
            exit(74)
          end
        end
      end

    end

  end
end
