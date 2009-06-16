def to_nodes(hash)
  roots = hash.keys
  nodes = []
  for root in roots
    child_hash = hash[root]
    children = to_nodes(child_hash)
    nodes << Node.new(root, children)
  end
  nodes
end

class Node
  attr_accessor :name, :children

  def initialize(name, children = [])
    @children = children
    @name = name
  end

  def has_child?(some_node)
    return @children.include?(some_node)
  end

  def to_s
    @name
  end

  def inspect
    to_s
  end
end

class Graph 
  def initialize(root)
    @root = root
  end

  def inspect
    @root.inspect
  end

  def to_s
    @root.to_s
  end
    
  def traverse(type, &block)
    if type == :depth_first
      traverse_depth_first(@root, block)
    elsif type == :breadth_first
      traverse_breadth_first(@root, block)
    else
      raise "unknown type #{type}"
    end
  end

  private 

  def traverse_depth_first(node, block)
    unless node.nil?
      block.call(node)
      for child in node.children
        traverse_depth_first child, block
      end
    end
  end
  
  def traverse_breadth_first(node, block)
    queue = [node]
    while not queue.empty?
      parent = queue.shift
      yield parent
      for child in cursor.children
        queue << child
      end
    end
  end      
end
    
