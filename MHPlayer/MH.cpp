extern "C"{
#include <stdlib.h>
#include "MH.h"
Ship* getNewGameShips(){
	static Ship ships[5]=
	{
		{0,0,5,ACROSS},
		{0,1,4,ACROSS},
		{0,2,3,ACROSS},
		{0,3,3,ACROSS},
		{0,4,2,ACROSS}
	};
	return ships;
}
int getFirePosition(){
	int x=rand()%10;
	int y=rand()%10;
	return x<<16&y;
}
}