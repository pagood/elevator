module Main
	def self.entrance
		Thread.new do
			elevator = ElevatorFactory.get_instance
			elevator.button_call(1,true)
			elevator.go_to 10
		end

		Thread.new do
			sleep(3)
			elevator = ElevatorFactory.get_instance
			elevator.button_call(5,true)
		end
	end
end