from collections import deque


class Span:
	
	DEFAULT_CAPACITY = 5

	def __init__(self, capacity = DEFAULT_CAPACITY):
		
		self.capacity = capacity
		self.container  = deque(maxlen = capacity)


	""" The capacity of the span """
	def capacity(self):
		return self.capacity


	""" Returns True if a string line is contained in this span """
	def contains(self, line):
		for l in deque:
			if l == line:
				return True

		return False


	""" Returns True if string line is the next in the span """
	def has_next(self, line):
		return line == self.container[0]


	""" Append a new line at end of the span """
	def append(self, line):
		self.container.append(line)

	
	""" Remove the next line from the span and return it """
	def pop(self):
		return self.container.popleft()


	""" Fill the span with lines from file """
	def from_file(self, fd):
		n = max(self.capacity - len(self.container), 0)

		while n:
			n -= 1

			line = fd.readline()

			if line == "":
				break

			self.container.append(line)

