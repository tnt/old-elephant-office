# coding: utf-8
require 'koelner_phonetic_encoder'

class String
	def phonetic_codes
		self.split.map {|i| i.phonetic_code}.join ''
	end
end