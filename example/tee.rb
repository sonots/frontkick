require 'frontkick'
require 'stringio'

class TeeIO
  def initialize(io)
    @io = io
    @string_io = StringIO.new
  end

  def write(str)
    @io.write str
    @string_io.write str
  end

  def string
    @string_io.string
  end
end

$stdout.sync = true
$stderr.sync = true
result = Frontkick.exec(["ls"], out: TeeIO.new($stdout), err: TeeIO.new($stderr))
puts '=== result.stdout ==='
puts result.stdout.string
puts '=== result.stderr ==='
puts result.stderr.string
