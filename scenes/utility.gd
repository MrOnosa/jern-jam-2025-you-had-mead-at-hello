extends Node


enum Draggable_Items { VOID, NATURAL_BEE_HIVE, MAN_MADE_BEE_HIVE, HONEY_EXTRACTOR, FOOD_GRADE_BUCKET} 
func draggable_items_dictionary() -> Dictionary[Draggable_Items, Dictionary]:
	return { 
	Draggable_Items.VOID: {
		"Name": "Void", 
		"Cost": 0, 
		"Text": "Never shoulda shown up 🐛"
		},
	Draggable_Items.NATURAL_BEE_HIVE: {
		"Name": "Natural Bee Hive", 
		"Cost": 100, 
		"Text": "A natural beehive is cheap but is has a limited maximum population. Consider it a nucleaus bee hive containing everything a beekeeper needs to get started."
		},
	Draggable_Items.MAN_MADE_BEE_HIVE: {
		"Name": "Human Made Bee Hive", 
		"Cost": 300, 
		"Text": "A hand crafted beehive can hold a lot more bees. More bees means more honeycombs. This comes with everything a beekeeper needs to grow their apiary."

		},
	Draggable_Items.HONEY_EXTRACTOR: {
		"Name": "Honey Extractor", 
		"Cost": 200, 
		"Text": "This machine extract raw honey and beeswax from from honeycombs. The honey and beeswax can be sold, or the honey can be processed further."

		},
	Draggable_Items.FOOD_GRADE_BUCKET: {
		"Name": "Food Grade Bucket", 
		"Cost": 200, 
		"Text": "Used to make mead. Add 3 (three) units of honey to the bucket for fermentation. It will yield 2 (two) units of mead."
		}
	}

# Found at https://www.reddit.com/r/godot/comments/9iw4ie/comment/mdy16ln/
func add_commas_to_number(input_number : int) -> String:
	var number_as_string : String = str(input_number)
	var output_string : String = ""
	var last_index : int = number_as_string.length() - 1
	#For each digit in the number...
	for index in range(number_as_string.length()):
		#add that digit to the output string, and then...
		output_string = output_string + number_as_string.substr(index,1)
		#if the index is at the thousandths, millions, billionths place, etc.
		#i.e. where you would put a comma, then insert a comma after that digit.
		if (last_index - index) % 3 == 0 and index != last_index:
			output_string = output_string + ","
	return output_string
