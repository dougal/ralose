require 'optparse'

module RaLoSe
  class Command

    RED         = "\e[31m".freeze
    RESET_COLOR = "\e[0m".freeze

    # [a9c56d04-d706-49ae-b0a2-e7636c650d5e]
    REQUEST_ID_RE = /\[[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\]/.freeze

    def initialize
      @colorized_output = true
      @case_insensitive = false

      parse_options

      @current_request_id    = nil
      @current_request_lines = []
      @print_current_request = false

      @query = ARGV.shift
    end

    def self.run!
      new.run!
    end

    def run!
      # Pipe handling based on: https://www.jstorimer.com/blogs/workingwithcode/7766125-writing-ruby-scripts-that-respect-pipelines

      # Read from file passed in ARGV, or STDIN.
      ARGF.each_line do |line|

        request_id = line[REQUEST_ID_RE]

        if request_id.nil?
          next
        end

        if request_id != @current_request_id
          print_current_request

          @current_request_id    = request_id
          @current_request_lines = []
          @print_current_request = false
        end

        if @case_insensitive
          query_index = line.downcase.index(@query.downcase)
        else
          query_index = line.index(@query)
        end

        if query_index
          @print_current_request = true

          if @colorized_output
            # TODO: Highlight multiple matches on a single line.
            line.insert(query_index + @query.length, RESET_COLOR)
            line.insert(query_index, RED)
          end
        end

        @current_request_lines << line

      end

      print_current_request

    end

    private

    def print_current_request
      if !@print_current_request
        return
      end

      @current_request_lines.each do |line|
        print_line(line)
      end

      # TODO: Print newlines above the 2nd request onwards?
      print_line("\n\n")
    end

    def print_line(line)
      begin
        $stdout.puts line

      # Handle case where output pipe is closed before writing is completed.
      rescue Errno::EPIPE
        exit(74)
      end
    end

    def parse_options
      OptionParser.new do |options|
        # This banner is the first line of the help documentation.
        options.banner = "Usage: ralose [options] [files]\n\n" \
          "Prints out all lines for a Rails request where one line in that request " \
          "matches the passed search string."

        # Separator just adds a new line with the specified text.
        options.separator ""
        options.separator "Specific options:"

        options.on("-i", "Perform case insensitive matching. By default, ralose is case sensitive.") do |be_case_insensitive|
          @case_insensitive = be_case_insensitive
        end

        options.on("--no-color", "Disable colorized output") do |use_color|
          @colorized_output = use_color
        end

        # on_tail says that this option should appear at the bottom of
        # the options list.
        options.on_tail("-h", "--help", "You're looking at it!") do
          $stderr.puts options
          exit 1
        end
      end.parse!
    end

  end
end
