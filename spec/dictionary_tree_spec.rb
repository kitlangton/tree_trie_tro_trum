require 'spec_helper'
require 'letter_node'
require 'dictionary_tree'


describe DictionaryTree do

  let(:word_apple) { ['apple', 'Fruit and software'] }
  let(:word_a) { ['a', 'Quite possibly the shortest word ever'] }
  let(:word_at) { ['at', 'Location in a place or position'] }
  let(:word_attribute) { ['attribute', 'Quality or characteristic of something'] }
  let(:word_cat) { ['cat', 'A feline animal'] }
  let(:word_catch) { ['catch', 'Are ya gonna throw me something?'] }
  let(:word_zebra) { ['zebra', 'Do not think this if you hear hoofbeats'] }

  let(:word_dictionary) do
    [
      word_apple,
      word_a,
      word_at,
      word_attribute,
      word_cat,
      word_catch,
      word_zebra
    ]
  end

  let(:dictionary_tree) { DictionaryTree.new }
  let(:prepopulated_tree) { DictionaryTree.new(word_dictionary) }


  # ----------------------------------------
  # #initialize
  # ----------------------------------------

  describe '#initialize' do

    it 'returns an instance of DictionaryTree' do
      expect(dictionary_tree).to be_an_instance_of(DictionaryTree)
    end


    it 'takes a 2 dimensional array of dictionary entries as a parameter' do
      expect { prepopulated_tree }.to_not raise_error
    end


    it 'creates a root node with a letter value of nil' do
      expect(dictionary_tree.root.letter).to be_nil
    end


    it 'builds the tree when an array is passed' do
      expect(prepopulated_tree.definition_of('attribute')).to eq(word_attribute[1])
    end
  end


  # ----------------------------------------
  # #num_letters
  # ----------------------------------------


  describe '#num_letters' do

    it 'is not a setter method' do
      expect { dictionary_tree.num_letters = 5 }.to raise_error(NoMethodError)
    end


    it 'returns the number of letters currently in the tree' do
      # Note: The "Splat" operator * effectively separates the array
      #    so the single array ["foo","bar"] becomes two separate
      #    strings "foo","bar"
      dictionary_tree.insert_word(*word_cat)
      expect(dictionary_tree.num_letters).to eq(3)
    end


    it 'does not count shared letters from overlapping words' do
      # Note: The "Splat" operator * effectively separates the array
      #    so the single array ["foo","bar"] becomes two separate
      #    strings "foo","bar"
      dictionary_tree.insert_word(*word_cat)
      expect do
        dictionary_tree.insert_word(*word_catch)
      end.to change(dictionary_tree, :num_letters).by(2)
    end
  end


  # ----------------------------------------
  # #num_words
  # ----------------------------------------


  describe '#num_words' do

    it 'raises an error when attempting to assign a value' do
      expect { dictionary_tree.num_words = 5 }.to raise_error(NoMethodError)
    end


    it 'returns the number of words currently in the tree' do
      expect(prepopulated_tree.num_words).to eq(word_dictionary.length)
    end
  end


  # ----------------------------------------
  # #root
  # ----------------------------------------


  describe '#root' do

    it 'returns a LetterNode' do
      expect(dictionary_tree.root).to be_a(LetterNode)
    end


    it 'always has a letter with a value of nil' do
      expect(prepopulated_tree.root.letter).to be_nil
    end


    it 'has a parent value of nil' do
      expect(prepopulated_tree.root.parent).to be_nil
    end
  end


  # ----------------------------------------
  # #insert_word
  # ----------------------------------------


  describe '#insert_word' do

    it 'accepts a word for the first and a definition second parameter' do
      expect { dictionary_tree.insert_word('word', 'definition') }.to_not raise_error
    end


    it 'raises an error when no word is provided' do
      expect { dictionary_tree.insert_word }.to raise_error(ArgumentError)
    end


    it 'raises an error when no definition is provided' do
      expect { dictionary_tree.insert_word('foo') }.to raise_error(ArgumentError)
    end


    it 'does not set the letter of the root node' do
      dictionary_tree.insert_word(*word_apple)
      expect(dictionary_tree.root.letter).to be_nil
    end
  end


  # ----------------------------------------
  # Word insertion
  # ----------------------------------------


  describe 'Word insertion' do

    before do
      dictionary_tree
    end


    it 'increments the tree word count' do
      # Note: The "Splat" operator * effectively separates the array
      #    so the single array ["foo","bar"] becomes two separate
      #    strings "foo","bar"
      expect do
        dictionary_tree.insert_word(*word_apple)
      end.to change(dictionary_tree, :num_words).by(1)
    end


    context 'after inserting a word' do

      before do
        dictionary_tree.insert_word(*word_apple)
      end


      it 'sets the tree letter count the word length' do
        expect(dictionary_tree.num_letters).to eq(5)
      end


      it 'sets the depth of the tree to the word length' do
        expect(dictionary_tree.depth).to eq(5)
      end
    end


    context 'with a short word already inserted' do

      before do
        # Note: The "Splat" operator * effectively separates the array
        #    so the single array ["foo","bar"] becomes two separate
        #    strings "foo","bar"
        dictionary_tree.insert_word(*word_cat)
      end


      describe 'the new word does not overlap the existing word' do

        it 'increments letter count by all letters' do
          expect do
            dictionary_tree.insert_word(*word_apple)
          end.to change(dictionary_tree, :num_letters).by(5)
        end


        it 'sets the depth of the tree to the longest existing word' do
          dictionary_tree.insert_word(*word_apple)
          expect(dictionary_tree.depth).to eq(5)
        end
      end


      describe 'the new word overlaps existing words partially' do

        it 'increments letter count only by the unshared letters' do
          expect do
            dictionary_tree.insert_word(*word_catch)
          end.to change(dictionary_tree, :num_letters).by(2)
        end


        it 'sets the depth of the tree to the longest existing word' do
          dictionary_tree.insert_word(*word_catch)
          expect(dictionary_tree.depth).to eq(5)
        end
      end
    end


    context "with a longer word already inserted" do

      before do
        # Note: The "Splat" operator * effectively separates the array
        #    so the single array ["foo","bar"] becomes two separate
        #    strings "foo","bar"
        dictionary_tree.insert_word(*word_catch)
      end


      describe 'the new word is contained within the existing one' do

        it 'does not increment the letter count' do
          expect do
            dictionary_tree.insert_word(*word_cat)
          end.to change(dictionary_tree, :num_letters).by(0)
        end


        it 'does increment the word count' do
          expect do
            dictionary_tree.insert_word(*word_cat)
          end.to change(dictionary_tree, :num_words).by(1)
        end


        it 'does not change the tree depth' do
          expect do
            dictionary_tree.insert_word(*word_cat)
          end.to change(dictionary_tree, :depth).by(0)
        end
      end
    end
  end




  # ----------------------------------------
  # #definition_of
  # ----------------------------------------


  describe '#definition_of' do


    it 'takes the string name of the word as a parameter' do
      expect { prepopulated_tree.definition_of('cat') }.to_not raise_error
    end


    context 'the word exists' do

      it 'returns the definition of the word' do
        expect(prepopulated_tree.definition_of('apple')).to eq(word_apple[1])
      end
    end


    context 'the word does not exist' do

      it 'returns nil' do
        expect(prepopulated_tree.definition_of('nope')).to be_nil
      end
    end
  end


  # ----------------------------------------
  # Defining a word
  # ----------------------------------------


  describe 'Defining a word' do

    before do
      dictionary_tree.insert_word(*word_at)
    end


    it 'stores the definition on the last node of a word' do
      node = dictionary_tree.root.children.first.children.first
      expect(node.definition).to eq( word_at[1] )
    end


    it 'does not store the definition on any other node in the word' do
      node = dictionary_tree.root.children.first
      expect(node.definition).to be_nil
    end
  end


  # ----------------------------------------
  # #remove_word
  # ----------------------------------------


  describe '#remove_word' do


    it 'takes the string name of the word as a parameter' do
      expect { prepopulated_tree.remove_word('cat') }.to_not raise_error
    end


    context 'the word exists' do

      it 'removes the word from the tree' do
        prepopulated_tree.remove_word('apple')
        expect(prepopulated_tree.definition_of('apple')).to be_nil
      end
    end


    context 'the word does not exist' do

      it 'does not raise an error' do
        expect { prepopulated_tree.remove_word('oops') }.to_not raise_error
      end
    end
  end


  # ----------------------------------------
  # Word removal
  # ----------------------------------------


  describe 'Word removal' do

    before do
      prepopulated_tree
    end


    context 'the word exists' do

      it 'decreases the word count of the tree by 1' do
        expect do
          prepopulated_tree.remove_word('cat')
        end.to change(prepopulated_tree, :num_words).by(-1)
      end


      it 'removes the definition of the word' do
        prepopulated_tree.remove_word('at')
        expect(prepopulated_tree.definition_of('at')).to be_nil
      end


      context 'the word does not overlap other words' do

        it 'decreases the letter count by the length of the word' do
          expect do
            prepopulated_tree.remove_word('zebra')
          end.to change(prepopulated_tree, :num_letters).by(-5)
        end
      end


      context 'the word partially overlaps another word' do

        it 'decreases the letter count by the unshared letters' do
          expect do
            prepopulated_tree.remove_word('catch')
          end.to change(prepopulated_tree, :num_letters).by(-2)
        end


        it 'does not remove the definition of the word it overlaps' do
          prepopulated_tree.remove_word('catch')
          expect(prepopulated_tree.definition_of('cat')).to eq(word_cat[1])
        end


        it 'removes the definition of the word' do
          prepopulated_tree.remove_word('catch')
          expect(prepopulated_tree.definition_of('catch')).to be_nil
        end
      end


      context 'the word is completely overlapped by another word' do

        it 'does not decrease the letter count' do
          expect do
            prepopulated_tree.remove_word('cat')
          end.to change(prepopulated_tree, :num_letters).by(0)
        end


        it 'removes the definition of the word' do
          prepopulated_tree.remove_word('cat')
          expect(prepopulated_tree.definition_of('cat')).to be_nil
        end


        it 'does not remove the definition of the overlapping word' do
          prepopulated_tree.remove_word('cat')
          expect(prepopulated_tree.definition_of('catch')).to eq(word_catch[1])
        end
      end
    end


    context 'the word does not exist in the tree' do

      it 'does not decrease the word count' do
        expect do
          prepopulated_tree.remove_word('oops')
        end.to change(prepopulated_tree, :num_words).by(0)
      end


      it 'does not decrease the letter count' do
        expect do
          prepopulated_tree.remove_word('oops')
        end.to change(prepopulated_tree, :num_letters).by(0)
      end
    end
  end


  # ----------------------------------------
  # #depth
  # ----------------------------------------


  describe '#depth' do

    it 'returns the maximum depth of the tree' do
      dictionary_tree.insert_word(*word_cat)
      expect(dictionary_tree.depth).to eq(3)
    end

    it 'returns the correct depth after a word has been inserted' do
      dictionary_tree.insert_word(*word_attribute)
      expect(dictionary_tree.depth).to eq(9)
    end


    it 'returns the correct depth after a word has been removed' do
      prepopulated_tree.remove_word('attribute')
      expect(prepopulated_tree.depth).to eq(5)
    end
  end


  # ----------------------------------------
  # EXTRA CREDIT!
  # ----------------------------------------
  # Uncomment and make the tests pass
  # to earn extra credit
  #


  # ----------------------------------------
  # #width
  # ----------------------------------------


  describe '#width' do

    before do
      [
        'aardvark', 'absolute', 'acute',
        'ball', 'beach', 'bot',
        'cab', 'cool', 'cup'
      ].each do |word|
        dictionary_tree.insert_word(word, 'Definitions are cool!')
      end
    end

    it 'returns the maximum width of the tree' do
      expect(dictionary_tree.width).to eq(9)
    end


    it 'returns the correct width after a word has been inserted' do
      dictionary_tree.insert_word('add', 'Definition is a plus')
      expect(dictionary_tree.width).to eq(10)
    end


    # Couldn't get this one to pass

    it 'returns the correct width even after a word has been removed' do
      dictionary_tree.remove_word('aardvark')
      expect(dictionary_tree.width).to eq(8)
    end
  end
end

