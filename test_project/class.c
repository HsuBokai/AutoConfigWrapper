#include <stdio.h>
#include <stdlib.h> // malloc

#include "class.h"

struct _Private {
	char _readBuf[READ_BUF_SIZE];
	char* _begin;
};

static int push(Class* obj, const char c)
{
	return -1;
}

static int peep(const Class* obj, char* c)
{
	return 0;
}


Class* new_Class() {
	Class* obj = (Class*) malloc(sizeof(Class));
	//obj->_begin = obj->_readBuf;
	//*(obj->_begin) = 0;
	obj->push = push;
	obj->peep = peep;
	return obj;
}

void delete_Class(Class* obj) {
	free(obj);
	obj = NULL;
}

