# frozen_string_literal: true

require "diff/lcs"
require "diff/lcs/hunk"

module TTY
  module File
    class Differ
      # Create a Differ
      #
      # @api public
      def initialize(format: :unified, context_lines: 3)
        @format = format
        @context_lines = context_lines
      end

      # Find character difference between two strings
      #
      # @return [String]
      #   the difference between content or empty if no
      #   difference found
      #
      # @api public
      def call(string_a, string_b)
        string_a_lines = convert_to_lines(string_a)
        string_b_lines = convert_to_lines(string_b)
        diffs = Diff::LCS.diff(string_a_lines, string_b_lines)
        return "" if diffs.empty?

        hunks = extract_hunks(diffs, string_a_lines, string_b_lines)
        format_hunks(hunks)
      end

      # Diff add char
      #
      # @api public
      def add_char
        case @format
        when :old
          ">"
        when :unified
          "+"
        else
          "*"
        end
      end

      # Diff delete char
      #
      # @api public
      def delete_char
        case @format
        when :old
          "<"
        when :unified
          "-"
        else
          "*"
        end
      end

      private

      # @api private
      def convert_to_lines(string)
        string.split(/\n/).map(&:chomp)
      end

      # @api private
      def extract_hunks(diffs, string_a_lines, string_b_lines)
        file_length_difference = 0

        diffs.map do |piece|
          hunk = Diff::LCS::Hunk.new(string_a_lines, string_b_lines, piece,
                                     @context_lines, file_length_difference)
          file_length_difference = hunk.file_length_difference
          hunk
        end
      end

      # @api private
      def format_hunks(hunks)
        output = []
        hunks.each_cons(2) do |prev_hunk, current_hunk|
          begin
            if current_hunk.overlaps?(prev_hunk)
              current_hunk.unshift(prev_hunk)
            else
              output << prev_hunk.diff(@format).to_s
            end
          ensure
            output << "\n"
          end
        end
        output << hunks.last.diff(@format) << "\n" if hunks.last
        output.join
      end
    end # Differ
  end # File
end # TTY
