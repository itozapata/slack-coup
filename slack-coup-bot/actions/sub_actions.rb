require 'actions/action'

module SlackCoupBot
	module Actions
		class SubAction < Action
			attr_reader :prompt

			def initialize(player, *params, prompt: nil)
				super(player)
				@prompt = prompt
			end

			def ==(other)
				other.class == self.class && other.player == player
			end
		end

		class GainCoins < SubAction
			def initialize(player, count = nil)
				super(player)
				@count = count
			end

			def public_message(coins)
				"#{player} has received #{coins} coin(s)"
			end

			def evaluate(count = nil)
				@count ||= count
				@player.gain_coins @count
			end
		end

		class LoseCoins < SubAction
			def initialize(player, count = nil)
				super(player)
				@count = count
			end

			def evaluate(count = nil)
				@count ||= count
				@player.lose_coins @count
			end

			def public_message(coins)
				"#{player} has lost #{coins} coins"
			end
		end

		class PickUp < SubAction
			def initialize(player, count = nil)
				super(player)
				@count = count
			end

			def evaluate(count = nil)
				@count ||= (count.is_a?(Enumerable) ? count.count : count)
				(1..@count).collect do
					@player.gain_card
				end
			end

			def public_message(cards)
				"#{player} picked up #{cards.count} card(s)"
			end

			def private_message(cards)
				"You picked up the #{cards} card(s)"
			end
		end

		class Flip < SubAction
			def validate(*cards)
				if cards.count != 1
					raise ValidationError, "You must flip one card only."
				end
				card = cards.first
				if ! player.has_cards? card
					raise ValidationError, "You do not have the #{card} card."
				end
			end

			def evaluate(card)
				player.flip_card card
			end

			def public_message(card)
				"#{player} revealed the #{card} card!"
			end
		end

		class Return < SubAction
			attr_reader :cards

			def initialize(player, cards, prompt: nil)
				super(player, prompt: prompt)
				if cards.is_a? Number
					@cards = Array.new(cards)
				else
					@cards = cards
				end
			end

			def validate(*cards)
				cards.each do |card|
					if ! player.has_cards? card
						raise ValidationError, "You do not have the #{card} card"
					end
				end
			end

			def evaluate(*cards)
				@cards = cards if @cards.empty?
				@cards.collect do |card|
					@player.lose_card card
				end
			end

			def public_message(cards)
				"#{player} returend #{cards.count} card(s) to the deck"
			end

			def private_message(cards)
				"You returned the #{cards} card(s) to the deck"
			end

			def ==(other)
				super(other) && other.cards.count == cards.count
			end
		end
	end
end