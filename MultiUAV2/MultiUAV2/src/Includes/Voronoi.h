//
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
//	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
//	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
//	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
//	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
//	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
//	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
//
//
#ifndef VORONOI_H
#define VORONOI_H

using namespace std;

#ifndef NULL
#define NULL 0
#endif
#define DELETED -2


int scomp(const void *vps1,const void *vps2);


class Voronoi
{
public:		//constructors
	Voronoi();

public:

	int triangulate;
	int sorted;
	int plot;
	int debug;

	struct	Freenode	{
		struct	Freenode	*nextfree;
	};
	struct	Freelist	{
		struct	Freenode	*head;
		int			nodesize;
	};

	float xmin;
	float xmax;
	float ymin;
	float ymax;
	float deltax;
	float deltay;


	struct Point	{
		float x,y;
	};
	int iClosestNode(Voronoi::Point ptPosition);

	/* structure used both for sites and for vertices */
	struct Site	{
		struct	Point	coord;
		int		sitenbr;
		int		refcnt;
	};


	struct	Site	*sites;
	int		nsites;
	int		siteidx;
	int		sqrt_nsites;
	int		nvertices;
	struct 	Freelist sfl;
	struct	Site	*bottomsite;


	struct Edge	{
		float		a,b,c;
		struct	Site 	*ep[2];
		struct	Site	*reg[2];
		int		edgenbr;
	};
	#define le 0
	#define re 1
	int nedges;
	struct	Freelist efl;


	struct Halfedge {
		struct Halfedge	*ELleft, *ELright;
		struct Edge	*ELedge;
		int		ELrefcnt;
		char		ELpm;
		struct	Site	*vertex;
		float		ystar;
		struct	Halfedge *PQnext;
	};

	struct   Freelist	hfl;
	struct	Halfedge *ELleftend, *ELrightend;
	int 	ELhashsize;
	struct	Halfedge **ELhash;


	int PQhashsize;
	struct	Halfedge *PQhash;
	int PQcount;
	int PQmin;

//****** FUNCTIONS **********
	// edgelist.c
	int ntry;
	int totalsearch;
	void ELinitialize();
	struct Halfedge* HEcreate(struct Edge *e, int pm);
	void ELinsert(struct Halfedge *lb, struct Halfedge *newEdge);
	struct Halfedge* ELgethash(int b);
	struct Halfedge* ELleftbnd(struct Point *p);
	void ELdelete(struct Halfedge *he);
	struct Halfedge* ELright(struct Halfedge *he);
	struct Halfedge* ELleft(struct Halfedge *he);
	struct Site* leftreg(struct Halfedge *he);
	struct Site* rightreg(struct Halfedge *he);

	// geometry.c
	void geominit();
	struct Edge* bisect(struct	Site *s1,struct	Site *s2);
	struct Site* intersect(struct Halfedge *el1, struct Halfedge *el2);
	int right_of(struct Halfedge *el, struct Point *p);
	float dist(struct Site *s,struct Site *t);
	float dist(struct Point *ppPoint,struct Site *s);
	float dist(struct Point *pptPoint1,struct Point *pptPoint2);
	void endpoint(struct Edge *e, int	lr, struct Site *s);
	void makevertex(struct Site *v);
	void deref(struct	Site *v);
	void ref(struct Site *v);


	// heap.c
	void PQinsert(struct Halfedge *he, struct Site *v, float offset);
	void PQdelete(struct Halfedge *he);
	int PQbucket(struct Halfedge *he);
	int PQempty();
	struct Point PQ_min();
	struct Halfedge * PQextractmin();
	void PQinitialize();


	// main.c
//	int scomp(struct Point *s1,struct Point *s2);
	struct Site* (*next)(Voronoi*);
//	struct Site* (Voronoi::*next)();
	struct Site* nextone();
	struct Site* readone();
	void readsites();
	void readCATAsites(CThreatVector* vthrThreatVector); // read in and sort sites from CATA


	// memory.c
	int total_alloc;
	void freeinit(struct	Freelist *fl, int	size);
	char * getfree(struct	Freelist *fl);
	void makefree(struct Freenode *curr,struct Freelist *fl);
	char * myalloc(unsigned n);


	// output.c
	void openpl();
	void line(double dX0,double dY0,double dX1,double dY1);
	void circle(double dX,double dY,double dRange);
	void range(float pxmin, float pymin, float pxmax, float pymax);
	float pxmin;
	float pxmax;
	float pymin;
	float pymax;
	float cradius;
	void out_bisector(struct Edge *e);
	void out_ep(struct Edge *e);
	void out_vertex(struct Site *v);
	void out_site(struct Site *s);
	void out_triple(struct Site *s1, struct Site *s2, struct Site *s3);
	FILE* fpOut;
	void plotinit(int iPlotID,int iNumThreatsPlanned);
	int clip_line(struct Edge *e);

	// voronoi.c
//	void voronoi(int triangulate, struct Site *(*nextsite)());
	void voronoi(int triangulate, struct Site *(*nextsite)(Voronoi*));

	CNodeVector* pnodesGetNodes(){return(&nodevNodes);};
	double Voronoi::dDist(CNode *pndeNode1,CNode *pndeNode2);
	int iClosestNode(CNode *pndeNode,double* pdClosestDistance);
protected:
	CNodeVector nodevNodes;


};	//class Voronoi

struct Voronoi::Site* nextoneG(Voronoi* ThisPointer);
struct Voronoi::Site* readoneG(Voronoi* ThisPointer);


#endif	//VORONOI_H