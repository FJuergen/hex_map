class_name PriorityQueue

extends Object


var _entries: Dictionary = {}


func poll():
	var highest = _entries.keys().min()
	var ret = 	_entries[highest].pop_front()
	if _entries[highest].is_empty():
		_entries.erase(highest)
	return ret


func append(object, priority):
	if !_entries.has(priority):
		_entries[priority] = []
	if _entries[priority] == null:
		_entries[priority] = []
	if _entries[priority].has(object):
		return
	_entries[priority].append(object)


func is_empty():
	return _entries.is_empty()
