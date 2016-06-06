enum Direct{
	ACROSS='A',
	DOWN='D'
};
struct Ship{
	int x,y,length;
	int direct;
};
struct Ship* getNewGameShips();
int getFirePosition();