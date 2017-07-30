class ElevatorFactory
	attr_accessor :up_queue, :down_queue, :current_floor, :current_queue

	def self.get_instance
		@@instance ||= ElevatorFactory.new
	end

	def initialize 
		@up_queue = []
		@down_queue = []
		@current_floor = 1
		@current_queue = nil
		@is_running = false
		@mutex = Mutex.new
		#TODO
	end

	def go_to floor
		@mutex.synchronize do
			if current_queue.nil? 
				@current_queue = (floor > @current_floor ? @up_queue  : @down_queue) 
			end
			@current_queue.push floor and run if ((floor < @current_floor && @current_queue.equal?(@down_queue)) || 
																					(floor > @current_floor && @current_queue.equal?(@up_queue)))
		end
	end

	#direction true:up ,false: down
	def button_call floor, direction
		@mutex.synchronize do
			if @current_queue.nil? 
				@current_queue = floor > current_floor ? @up_queue : @down_queue
				@current_queue.push floor
				run 
				return  
			end
			if (direction == true &&  @current_queue.equal?(@down_queue)) || (direction == false &&  @current_queue.equal?(@up_queue))
				if direction
					@down_queue.min > floor ? @down_queue.push(floor) : @up_queue.push(floor)
				else
					@up_queue.max < floor ? @up_queue.push(floor) : @down_queue.push(floor)
				end
			else
				if direction
					floor > @current_floor ? @current_queue.push(floor) : @down_queue.push(floor)
				else
					floor < @current_floor ? @current_queue.push(floor) : @up_queue.push(floor)
				end
			end 
			run 
		end
	end

	def stop 
		puts '到达'
		# sleep 2 
	end

	#called by go_to or button_call
	def run
		@mutex.synchronize { return if is_running? } 
		puts '启动'
		while @current_queue.present? 
			#TODO
			while @current_floor != next_stop
				sleep 1
				@current_floor = @current_queue.equal?(@down_queue) ? (@current_floor - 1) : (@current_floor + 1)
				screen
			end
			stop 
			@mutex.synchronize do 
				@current_queue.delete next_stop
				@current_queue = @current_queue.any? ? @current_queue : (@up_queue.any? ? @up_queue : (@down_queue.any? ? @down_queue : nil))
			end
		end
		# @current_queue = nil
		puts '退出循环'
	end

	def next_stop
		@current_queue.equal?(@down_queue) ? @current_queue.max : @current_queue.min
	end

	def is_running?
		@current_queue.present?
	end

	def screen
		puts '电梯' + (@current_queue.equal?(@down_queue) ? '下行' : '上行') if @current_queue
		puts '现在楼层:' + @current_floor.to_s
		puts "上queue:#{@up_queue}"
		puts "下queue:#{@down_queue}"
	end
end