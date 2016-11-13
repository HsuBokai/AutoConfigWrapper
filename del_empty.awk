function push_cache_to_arr()
{
	for (i = 1; i <= cache_num; ++i) {
		d_arr[++d_num] = cache[i];
		a_arr[++a_num] = add_line_end;
	}
	is_cache = 0;
	cache_num = 0;
}
BEGIN{
	del_line = 0;
	add_line_begin = 0;
	add_line_end = 0;
	offset = 0;
	d_num = 0;
	a_num = 0;
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
	if (0 != match($0, /d/)) {
		del_line = d_range[1];
		add_line_begin = a_range[1];
		add_line_end = a_range[1];
	} else if (0 != match($0, /c/)) {
		del_line = d_range[1];
		add_line_begin = a_range[1] - 1;
		add_line_end = (2 == m) ? a_range[2] : a_range[1];
	}
}
/^-/{
	push_cache_to_arr();
	offset = 0;
}
/^</{
	value = del_line + offset;
	if (0 != match(substr($0,2), /^[ \t]*$/)) {
		if (1 == is_cache) {
			cache[++cache_num] = value;
		} else {
			d_arr[++d_num] = value;
			a_arr[++a_num] = add_line_begin;
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
		printf("%d %d\n", d_arr[i], a_arr[i]);
	}
}
