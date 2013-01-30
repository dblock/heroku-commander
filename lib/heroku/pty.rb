if ! defined? PTY::ChildExited
  module PTY
    class ChildExited < StandardError
      # missing on JRuby
    end
  end
end