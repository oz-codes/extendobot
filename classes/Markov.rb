#!/usr/bin/env ruby
class Markov
	def initialize(head, tail)
		@head = head
		@tail = tail
	end
	def asHash 
		return { 'head' => @head, 'tail' => @tail }
	end
end
class Markovin8or
	def initialize (arity=2)
		@chains = []
		@text = ""
		@arity = arity
	end
	def addText(txt)
		@text << txt
	end
	def chain(txt = nil)
		text = ""
		if(txt == nil) #chain what is stored in state
			text = @text
		else #actual text given?
			text = txt
		end
		#puts "markovin #{text}"		
		chains = []
		contents = text
		words = contents.strip.split(/ /)
		for idx in 0..words.count #loop through words
			tail = []
			head = words[idx] #head = current word
			break if head == nil
			next if head == ""
			#puts "idx: #{idx}"
			#print " head: #{head}\n"
			for jdx in 1..@arity-1  #tail is cur+1, cur+2, ..., cur + @arity
				#puts "\tjdx\t|\tjdx+idx\n\t#{jdx}\t|\t#{jdx+idx}"
				twd = words[idx+jdx] #get word at idx+jdx
				#puts "\ttail #{jdx}: #{twd}"
				tail.push(twd)
			end
			#puts "\n pushing markov"
			markov = {:head => head, :tail => tail} #make new Markov instance
			#p markov
			chains.push( markov ) ##push markov onto chain list
		end
		@chains = chains #set chains in state to the generated chains
		return chains
	end
	def mongoize(chains=nil)
		chains = @chains if chains == nil
		heads = chains.map { |v|
			v[:head]
		}
		#puts heads.inspect
		markov = {}
		heads.each { |head|
			if(!markov[head]) 
				markov[head] = []
			end
			tails = chains.select { |v| v[:head] == head }.map { |v| v[:tail] }.flatten
			markov[head] = tails
		}
		mkvs = []
		markov.each_pair { |k,v|
			mkvs.push({:head => k, :tails => v})
		}
		return mkvs
	end
end
