function push_cache_to_arr()
{
	if ("del" == state) {
		for (i = 1; i <= cache_num; ++i) {
			d_arr[++d_num] = cache[i];
		}
	} else {
		for (i = 1; i <= cache_num; ++i) {
			a_arr[++a_num] = cache[i];
		}
	}
	is_cache = 0;
	cache_num = 0;
}
BEGIN{
	line = 0;
	del_line = 0;
	add_line = 0;
	offset = 0;
	d_num = 0;
	a_num = 0;
	state = "del";
	is_cache = 0;
	cache_num = 0;
}
/^[^<>-]/{
	push_cache_to_arr();
	offset = 0;
	n = split($0, range, /[adc]/);
	if (2 != n) {
		printf("error !!\n");
		exit -1;
	}
	n = split(range[1], d_range, ",");
	m = split(range[2], a_range, ",");
	del_line = d_range[1];
	add_line = a_range[1];
	if (0 != match($0, /a/)) {
		state = "add";
		line = add_line;
	} else {
		state = "del";
		line = del_line;
	}
}
/^-/{
	push_cache_to_arr();
	offset = 0;
	state = "add";
	line = add_line;
}
/^[<>]/{
	value = line + offset;
	if (0 != match(substr($0,2), /^[ \t]*$/)) {
		if (1 == is_cache) {
			cache[++cache_num] = value;
		} else if ("del" == state) {
			d_arr[++d_num] = value;
		} else if ("add" == state) {
			a_arr[++a_num] = value;
		} else {
			printf("error !!\n");
			exit -1;
		}
	} else {
		is_cache = 1;
		cache_num = 0;
	}
	offset++;
}
END{
	push_cache_to_arr();
	for (i = d_num; 1 <= i; --i) {
		printf("%d ", d_arr[i]);
	}
	printf("\n");
	for (i = a_num; 1 <= i; --i) {
		printf("%d ", a_arr[i]);
	}
	printf("\n");
}
