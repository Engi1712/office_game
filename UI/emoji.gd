class_name Emoji

enum symbol_type {
	EMOJI_BASE,
	EMOJI_FULL,
	ZWJ,
	COUNTRY_FIRST,
	TAGS,
	NUMBER,
	NUMBER_VS,
	NONE
}

#static var notdef = "[img]res://Assests/Emoji/notdef.png[/img]"
#static var notdef = "�"
static var notdef = "☐"

static func find_emoji_pic(line: String, cur_font: Font):
	var line_len = line.length()
	var emoji_name: String
	var file_name: String
	
	if line_len == 0:
		return ""
	if line_len == 1 and cur_font.has_char(line.unicode_at(0)):
		return line[0]
	if line_len == 2 and line.unicode_at(1) == 0xFE0E and cur_font.has_char(line.unicode_at(0)):
		return line[0]
	emoji_name = "U+%04X" % line.unicode_at(0)
	for i in range(1, line_len):
		if !(line.unicode_at(i) >= 0x1F3FB and line.unicode_at(i) <= 0x1F3FF):
			emoji_name += "_U+%04X" % line.unicode_at(i)
	file_name = "res://Assests/Emoji/" + emoji_name + ".png"
	if FileAccess.file_exists(file_name):
		return "[img]" + file_name + "[/img]"
	else:
		return notdef

static func is_emoji(code: int):
	if code == 0x203C or \
			code == 0x2049 or \
			code == 0x2122 or \
			code == 0x2139 or \
			(code >= 0x2194 and code <= 0x2199) or \
			code == 0x21A9 or \
			code == 0x21AA or \
			code == 0x231A or \
			code == 0x231B or \
			code == 0x2328 or \
			code == 0x23CF or \
			(code >= 0x23E9 and code <= 0x23FA) or \
			code == 0x24C2 or \
			code == 0x25AA or \
			code == 0x25AB or \
			code == 0x25B6 or \
			code == 0x25C0 or \
			(code >= 0x25FB and code <= 0x2604) or \
			code == 0x260E or \
			code == 0x2611 or \
			code == 0x2614 or \
			code == 0x2615 or \
			code == 0x2618 or \
			code == 0x261D or \
			code == 0x2620 or \
			code == 0x2622 or \
			code == 0x2623 or \
			code == 0x2626 or \
			code == 0x262A or \
			code == 0x262E or \
			code == 0x262F or \
			code == 0x2638 or \
			code == 0x2639 or \
			code == 0x263A or \
			(code >= 0x2648 and code <= 0x2653) or \
			code == 0x2660 or \
			code == 0x2663 or \
			code == 0x2665 or \
			code == 0x2666 or \
			code == 0x2668 or \
			code == 0x267B or \
			code == 0x267F or \
			code == 0x2692 or \
			code == 0x2693 or \
			code == 0x2694 or \
			code == 0x2696 or \
			code == 0x2697 or \
			code == 0x2699 or \
			code == 0x269B or \
			code == 0x269C or \
			code == 0x26A0 or \
			code == 0x26A1 or \
			code == 0x26AA or \
			code == 0x26AB or \
			code == 0x26B0 or \
			code == 0x26B1 or \
			code == 0x26BD or \
			code == 0x26BE or \
			code == 0x26C4 or \
			code == 0x26C5 or \
			code == 0x26C8 or \
			code == 0x26CE or \
			code == 0x26CF or \
			code == 0x26D1 or \
			code == 0x26D3 or \
			code == 0x26D4 or \
			code == 0x26E9 or \
			code == 0x26EA or \
			(code >= 0x26F0 and code <= 0x26F5) or \
			(code == 0x26F7 and code <= 0x26FA) or \
			code == 0x26FD or \
			code == 0x2702 or \
			code == 0x2705 or \
			(code >= 0x2708 and code <= 0x270D) or \
			code == 0x270F or \
			code == 0x2712 or \
			code == 0x2714 or \
			code == 0x2716 or \
			code == 0x271D or \
			code == 0x2721 or \
			code == 0x2728 or \
			code == 0x2733 or \
			code == 0x2734 or \
			code == 0x2744 or \
			code == 0x2747 or \
			code == 0x274C or \
			code == 0x274E or \
			code == 0x2753 or \
			code == 0x2754 or \
			code == 0x2755 or \
			code == 0x2757 or \
			code == 0x2763 or \
			code == 0x2764 or \
			code == 0x2795 or \
			code == 0x2796 or \
			code == 0x2797 or \
			code == 0x27A1 or \
			code == 0x27B0 or \
			code == 0x27BF or \
			code == 0x2934 or \
			code == 0x2935 or \
			code == 0x2B05 or \
			code == 0x2B06 or \
			code == 0x2B07 or \
			code == 0x2B1B or \
			code == 0x2B1C or \
			code == 0x2B50 or \
			code == 0x2B55 or \
			code == 0x3030 or \
			code == 0x303D or \
			code == 0x3297 or \
			code == 0x3299 or \
			code >= 0x10000:
		return true
	else:
		return false

static func parse(line: String, cur_font: Font):
	var res_line = ""
	
	var letter: int
	var emoji_line: String = ""
	var prev_symbol = symbol_type.NONE
	
	for i in range(line.length()):
		letter = line.unicode_at(i)
		if letter >= 0x1F3FB and letter <= 0x1F3FF:
			# Skin colour
			match prev_symbol:
				symbol_type.EMOJI_BASE:
					emoji_line += line[i]
					prev_symbol = symbol_type.EMOJI_FULL
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = ""
					res_line += notdef
					prev_symbol = symbol_type.NONE
				symbol_type.ZWJ, \
				symbol_type.COUNTRY_FIRST, \
				symbol_type.TAGS, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = ""
					res_line += notdef
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = ""
					res_line += notdef
					prev_symbol = symbol_type.NONE
				symbol_type.NONE:
					res_line += notdef
		elif letter == 0xFE0E or letter == 0xFE0F:
			# Type variation
			match prev_symbol:
				symbol_type.EMOJI_BASE:
					emoji_line += line[i]
					prev_symbol = symbol_type.EMOJI_FULL
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.ZWJ, \
				symbol_type.COUNTRY_FIRST, \
				symbol_type.TAGS, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER:
					emoji_line += line[i]
					prev_symbol = symbol_type.NUMBER_VS
				symbol_type.NONE:
					pass
		elif letter == 0x200D:
			# ZWJ
			match prev_symbol:
				symbol_type.EMOJI_BASE, \
				symbol_type.EMOJI_FULL:
					emoji_line += line[i]
					prev_symbol = symbol_type.ZWJ
				symbol_type.ZWJ, \
				symbol_type.COUNTRY_FIRST, \
				symbol_type.TAGS, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NONE:
					pass
		elif letter >= 0x1F1E6 and letter <= 0x1F1FF:
			# Country codes
			match prev_symbol:
				symbol_type.EMOJI_BASE, \
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = line[i]
					prev_symbol = symbol_type.COUNTRY_FIRST
				symbol_type.ZWJ, \
				symbol_type.TAGS, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = line[i]
					prev_symbol = symbol_type.COUNTRY_FIRST
				symbol_type.COUNTRY_FIRST:
					emoji_line += line[i]
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = line[i]
					prev_symbol = symbol_type.COUNTRY_FIRST
				symbol_type.NONE:
					emoji_line = line[i]
					prev_symbol = symbol_type.COUNTRY_FIRST
		elif letter >= 0xE0000 and letter <= 0xE007F:
			# Tags
			match prev_symbol:
				symbol_type.EMOJI_BASE, \
				symbol_type.TAGS:
					emoji_line += line[i]
					if letter == 0xE007F:
						# Tag END
						res_line += find_emoji_pic(emoji_line, cur_font)
						emoji_line = ""
						prev_symbol = symbol_type.NONE
					else:
						prev_symbol = symbol_type.TAGS
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.ZWJ, \
				symbol_type.COUNTRY_FIRST, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NONE:
					pass
		elif letter == 0x20E3:
			# Enclosing keycap
			match prev_symbol:
				symbol_type.EMOJI_BASE, \
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = ""
					res_line += notdef
					prev_symbol = symbol_type.NONE
				symbol_type.ZWJ, \
				symbol_type.COUNTRY_FIRST, \
				symbol_type.TAGS:
					res_line += notdef
					emoji_line = ""
					res_line += notdef
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = ""
					res_line += notdef
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER_VS:
					emoji_line += line[i]
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NONE:
					res_line += notdef
		elif is_emoji(letter):
			# General emojis
			match prev_symbol:
				symbol_type.EMOJI_BASE, \
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = line[i]
					prev_symbol = symbol_type.EMOJI_BASE
				symbol_type.ZWJ:
					emoji_line += line[i]
					prev_symbol = symbol_type.EMOJI_BASE
				symbol_type.COUNTRY_FIRST, \
				symbol_type.TAGS, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = line[i]
					prev_symbol = symbol_type.EMOJI_BASE
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = line[i]
					prev_symbol = symbol_type.EMOJI_BASE
				symbol_type.NONE:
					emoji_line = line[i]
					prev_symbol = symbol_type.EMOJI_BASE
		elif letter == 0x0023 or letter == 0x002a or (letter >= 0x0030 and letter <= 0x0039):
			# Keycaps
			match prev_symbol:
				symbol_type.EMOJI_BASE, \
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = line[i]
					prev_symbol = symbol_type.NUMBER
				symbol_type.ZWJ, \
				symbol_type.COUNTRY_FIRST, \
				symbol_type.TAGS, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = line[i]
					prev_symbol = symbol_type.NUMBER
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = line[i]
					prev_symbol = symbol_type.NUMBER
				symbol_type.NONE:
					emoji_line += line[i]
					prev_symbol = symbol_type.NUMBER
		else:
			# Non-emoji symbols
			match prev_symbol:
				symbol_type.EMOJI_BASE, \
				symbol_type.EMOJI_FULL:
					res_line += find_emoji_pic(emoji_line, cur_font)
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.ZWJ, \
				symbol_type.COUNTRY_FIRST, \
				symbol_type.TAGS, \
				symbol_type.NUMBER_VS:
					res_line += notdef
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NUMBER:
					res_line += emoji_line
					emoji_line = ""
					prev_symbol = symbol_type.NONE
				symbol_type.NONE:
					pass
			if cur_font.has_char(line.unicode_at(i)):
				res_line += line[i]
			else:
				res_line += notdef
	match prev_symbol:
		symbol_type.EMOJI_BASE, \
		symbol_type.EMOJI_FULL:
			res_line += find_emoji_pic(emoji_line, cur_font)
		symbol_type.ZWJ, \
		symbol_type.COUNTRY_FIRST, \
		symbol_type.TAGS, \
		symbol_type.NUMBER_VS:
			res_line += notdef
		symbol_type.NUMBER:
			res_line += emoji_line
		symbol_type.NONE:
			pass
	return res_line
