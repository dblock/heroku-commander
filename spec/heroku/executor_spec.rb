require 'spec_helper'

describe Heroku::Executor do
  context "missing argument" do
    subject { lambda { Heroku::Executor.run } }
    it { should raise_error ArgumentError }
  end
  context "command does not exist" do
    subject { lambda { Heroku::Executor.run "executor_spec.rb" } }
    it { should raise_error Heroku::Commander::Errors::CommandError, /The command `executor_spec.rb`(.*)failed with exit status \d+./ }
  end
  context "command does not return exit status" do
    before do
      PTY.stub(:spawn).and_raise("foobar!")
      Process::Status.any_instance.stub(:exitstatus).and_return(nil)
    end
    subject { lambda { Heroku::Executor.run "executor_spec.rb" } }
    it { should raise_error Heroku::Commander::Errors::CommandError, /The command `executor_spec.rb` failed without reporting an exit status./ }
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
    it "doesn't yield nil lines" do
      r = double(IO)
      r.stub(:sync=)
      r.stub(:eof).and_return(false, false, false, true)
      r.stub(:readline).and_return("line1", nil, "rc=0")
      Process.stub(:wait)
      PTY.stub(:spawn).and_yield(r, nil, 42)
      Heroku::Executor.run("foobar").should == [ "line1", nil, "rc=0" ]
    end
  end
  context "logger" do
    it "logs command" do
      logger = Logger.new($stdout)
      logger.should_receive(:debug).at_least(2).times
      Heroku::Executor.run "ls -1", { :logger => logger }
    end
  end
end

