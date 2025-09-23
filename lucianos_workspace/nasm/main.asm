%include "abi.asm"

include io, lib

namespace simple_list
private
	namespace list_node
	private
		struct list_node
			var value, next
		end
	public
		function create, value
			sizeof list_node
			execute malloc
			var self
			assign self
			load value
			assign ; self->value
			load 0
			assign ; self->next
			return self
		end
	end
	struct simple_list
		var value, next
	end
public
	function create
		sizeof simple_list
		execute malloc
		var self
		assign self
		load 0
		assign ; self->head
		load 0
		assign ; self->tail
		return self
	end
	function append, self, value
		execute list_node.create
		var node
		assign node
		load value
		assign ; node->value
		if
			load ; self->tail
		then
			load node
			assign ; self->tail->next
		else
			load node
			assign ; self->head
		end
		load node
		assign ; self->tail
	end
end

function main
	execute simple_list.create
	var list0
	assign list0
	block
		var index
		load 0
		assign index
		while
			load index
			less_than 100
		do
			execute simple_list.append list0, index
			load index
			add 1
		end
	end
	block
		var node
		load ; list0->head
		while
			load node
		do
			lib.print_int ; node->value
			load ; node->next
			assign node
		end
	end
end

%include "abi.asm"