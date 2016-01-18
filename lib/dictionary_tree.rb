class DictionaryTree
  attr_reader :root

  def initialize(dictionary = nil)
    @root = LetterNode.new(nil, nil, [], nil, 0)
    build_tree(dictionary) if dictionary
  end

  def build_tree(dictionary)
    dictionary.each do |word, definition|
      insert_word(word, definition)
    end
  end

  def definition_of(word)
    if node = find_node(word)
      node.definition
    else
      puts "Not in dictionary"
    end
  end

  def width(node = @root, depths = Hash.new(0))
    return if node.children.empty?
    node.children.each do |child|
      depths[child.depth] += 1
      width(child, depths)
    end
    depths.max_by { |k,v| v}[1]
  end

  def find_node(word, node = @root)
    return node if word.empty?
    next_node = node.children.find { |child| child.letter == word[0] }
    return false unless next_node
    find_node(word[1..-1], next_node)
  end

  def insert_word(word, definition)
    node = @root
    word.chars.each do |letter|
      if next_node = node.children.find { |node| node.letter == letter }
        node = next_node
      elsif
        next_node = LetterNode.new(letter)
        next_node.children = []
        next_node.parent = node
        next_node.depth = node.depth + 1
        node.children << next_node
        node = next_node
      end
    end
    node.definition = definition
  end

  def remove_word(word)
    node = find_node(word)
    return false unless node
    if !node.children.empty?
      return node.definition = nil
    end
    until node.parent.definition || node.parent.children.size > 1 || node.parent == @root
      node = node.parent
    end
    node.parent.children.delete(node)
  end

  def depth(node = @root)
    node.children.map do |child|
      [child.depth, depth(child)]
    end.flatten.compact.max
  end

  def num_letters(node = @root)
    node.children.inject(0) do |sum, child|
      sum += 1 + num_letters(child)
    end
  end

  def num_words(node = @root)
    node.children.inject(0) do |sum, child|
      sum += 1 if child.definition
      sum += num_words(child)
    end
  end
end

