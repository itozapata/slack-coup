require 'play_actions'
require 'targeted_actions'
require 'reactions'

class Card
	@@card_classes = []

	class << self
		attr_reader :actions
		attr_reader :blocks

		@actions = [Block]
		@blocks = []

		def actions(*actions)
			@actions = actions
		end

		def blocks(*actions)
			@blocks = actions
		end

	  def actors(action)
	  	action = action.class unless action.is_a? Class
	    @@card_classes ||= ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
	    @@card_classes.select do |klass|
	    	klass.actions.include? action
	    end
	  end

	  def blockers(action)
	  	action = action.class unless action.is_a? Class
	    @@card_classes ||= ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
	    @@card_classes.select do |klass|
	    	klass.blocks.include? action
	    end
	  end
	end

	def initialize
		@flipped = false
	end

	def flip
		@flipped = true
		self
	end

	def flipped?
		@flipped
	end

	def hide
		@flipped = false
		self
	end

	def ==(other)
		other.class == self.class
	end

	def to_s
		self.class.name
	end
end

class Ambassador < Card
	actions Exchange
	blocks Steal
end

class Assassin < Card
	actions Assassinate
end

class Captain < Card
	actions Steal
	blocks Steal
end

class Contessa < Card
	blocks Assassinate
end

class Duke < Card
	actions Tax
	blocks ForeignAid
end