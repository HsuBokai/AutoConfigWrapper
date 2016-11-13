#include <stdio.h>

#include "class.h"

int main(){
	fprintf(stdout, "hello world!\n");
	
	Class* obj = new_Class();
	delete_Class(obj);

	//fprintf(stdout, "%16p\n", obj->_begin);
	fprintf(stdout, "%d\n", obj->push(obj, 'a'));
}
