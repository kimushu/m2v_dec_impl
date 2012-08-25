#!/usr/bin/env ruby

d = []
reloc = nil
add = 0
open("mem_init.mk").each_line {|line|
	if(reloc)
		if(!(line =~ /^#{reloc}_RELOC_INPUT_FLAG/))
			d << "#{reloc}_RELOC_INPUT_FLAG := --relocate-input=$(#{reloc}_START)\n"
			add += 1
		end
		reloc = nil
	end
	d << line
	next if !(line =~ /(\$\(MEM_\d+\))_START :=/)
	reloc = $1
}

if(add > 0)
	open("mem_init.mk", "w").write(d.join(""))
end

