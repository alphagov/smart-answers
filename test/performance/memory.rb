# lazy hack from Robert Klemme

module Memory
  # sizes are guessed, I was too lazy to look
  # them up and then they are also platform
  # dependent
  REF_SIZE = 4 # ?
  OBJ_OVERHEAD = 4 # ?
  FIXNUM_SIZE = 4 # ?

  # informational output from analysis
  MemoryInfo = Struct.new :roots, :objects, :bytes, :loops

  def self.analyze(*roots)
    an = Analyzer.new
    an.roots = roots
    an.analyze
  end

  class Analyzer
    attr_accessor :roots
    attr_reader :result

    def analyze
      @result = MemoryInfo.new roots, 0, 0, 0
      @objs = {}

      queue = roots.dup

      until queue.empty?
        obj = queue.shift

        case obj
        # special treatment for some types
        # some are certainly missing from this
        when IO
          visit(obj)
        when String
          visit(obj) { @result.bytes += obj.size }
        when Fixnum
          @result.bytes += FIXNUM_SIZE
        when Array
          visit(obj) do
            @result.bytes += obj.size * REF_SIZE
            queue.concat(obj)
          end
        when Hash
          visit(obj) do
            @result.bytes += obj.size * REF_SIZE * 2
            obj.each {|k, v| queue.push(k).push(v)}
          end
        when Enumerable
          visit(obj) do
            obj.each do |o|
              @result.bytes += REF_SIZE
              queue.push(o)
            end
          end
        else
          visit(obj) do
            obj.instance_variables.each do |var|
              @result.bytes += REF_SIZE
              queue.push(obj.instance_variable_get(var))
            end
          end
        end
      end

      @result
    end

  private
    def visit(obj)
      id = obj.object_id

      if @objs.has_key? id
        @result.loops += 1
        false
      else
        @objs[id] = true
        @result.bytes += OBJ_OVERHEAD
        @result.objects += 1
        yield obj if block_given?
        true
      end
    end
  end
end
