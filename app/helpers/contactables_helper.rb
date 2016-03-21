# coding: utf-8
module ContactablesHelper
  include ElphConfig
	def new_or_edit object
		object.persisted? ? 'bearbeiten' : 'neu'
	end
	def sexes_with_labels
	  Hash[*(['bitte wählen','männlich','weiblich','neutral']).zip(Elph[:sex_kinds].dup.unshift('')).flatten]
	end
end
