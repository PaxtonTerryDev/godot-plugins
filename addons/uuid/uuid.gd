class_name UUID
extends RefCounted

## A utility class for generating UUID version 4 (random) identifiers
## Usage: var uuid = UUIDGenerator.generate()

## Generates a random UUID v4 string
## Returns a string in the format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
## where x is a random hexadecimal digit and y is one of 8, 9, A, or B
static func generate() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var uuid = ""
	
	# Generate 16 random bytes
	for i in range(16):
		var byte = rng.randi_range(0, 255)
		
		# Set version (4) and variant bits according to RFC 4122
		if i == 6:
			# Version 4: set the four most significant bits to 0100
			byte = (byte & 0x0F) | 0x40
		elif i == 8:
			# Variant: set the two most significant bits to 10
			byte = (byte & 0x3F) | 0x80
		
		# Convert byte to hex string
		var hex = "%02x" % byte
		uuid += hex
		
		# Add hyphens at the appropriate positions
		if i == 3 or i == 5 or i == 7 or i == 9:
			uuid += "-"
	
	return uuid


## Generates a compact UUID without hyphens
static func generate_compact() -> String:
	return generate().replace("-", "")


## Validates if a string is a properly formatted UUID
static func is_valid(uuid_string: String) -> bool:
	# Check length with hyphens
	if uuid_string.length() != 36:
		return false
	
	# Check format: 8-4-4-4-12
	var parts = uuid_string.split("-")
	if parts.size() != 5:
		return false
	
	if parts[0].length() != 8 or parts[1].length() != 4 or \
	   parts[2].length() != 4 or parts[3].length() != 4 or \
	   parts[4].length() != 12:
		return false
	
	# Check if all characters are valid hexadecimal
	var valid_chars = "0123456789abcdefABCDEF"
	for part in parts:
		for c in part:
			if not c in valid_chars:
				return false
	
	return true
