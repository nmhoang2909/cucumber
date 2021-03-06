require 'cucumber/cucumber_expressions/cucumber_expression'
require 'cucumber/cucumber_expressions/regular_expression'
require 'cucumber/cucumber_expressions/transform_lookup'
require 'json'

module Cucumber
  module CucumberExpressions
    describe 'examples.txt' do
      def match(expression_text, text)
        expression = expression_text =~ /\/(.*)\// ?
          RegularExpression.new(Regexp.new($1), TransformLookup.new) :
          CucumberExpression.new(expression_text, [], TransformLookup.new)

        arguments = expression.match(text)
        return nil if arguments.nil?
        arguments.map { |arg| arg.transformed_value }
      end

      File.open(File.expand_path("../../../../examples.txt", __FILE__), "r:utf-8") do |io|
        chunks = io.read.split(/^---/m)
        chunks.each do |chunk|
          expression_text, text, expected_args = *chunk.strip.split(/\n/m)
          it "Works with: #{expression_text}" do
            expect( match(expression_text, text).to_json ).to eq(expected_args)
          end
        end
      end
    end
  end
end
