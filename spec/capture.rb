require 'stringio'
require 'ostruct'

# Source: http://alphahydrae.com/2013/09/capturing-output-in-pure-ruby/
class Capture
  def self.capture(&block)
    orig_stdout, orig_stderr = STDOUT, STDERR

    # redirect output to StringIO objects
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr

    result = block.call

    # restore normal output
    $stdout, $stderr = orig_stdout, orig_stderr

    OpenStruct.new result: result, stdout: stdout.string, stderr: stderr.string
  end

  def self.argv(items)
    old_argv = ARGV.clone
    ARGV.replace items
    yield
  ensure
    ARGV.replace old_argv
  end
end
