require 'spec_helper'

describe Heroku::Executor do
  context "missing argument" do
    subject { lambda { Heroku::Executor.run } }
    it { should raise_error ArgumentError }
  end
  context "command does not exist" do
    subject { lambda { Heroku::Executor.run "executor_spec.rb" } }
    it { should raise_error Heroku::Commander::Errors::CommandError, /The command `executor_spec.rb` failed with exit status \d+./ }
  end
  context "command exists" do
    subject { lambda { Heroku::Executor.run "ls -1" } }
    it { should_not raise_error }
    its(:call) { should include "Gemfile" }
  end
  context "line-by-line" do
    it "yields" do
      lines = []
      Heroku::Executor.run "ls -1" do |line|
        lines << line
      end
      lines.should include "Gemfile"
    end
  end
end

