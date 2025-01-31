/* ncount.cpp by Jason Lai based on code by Natasa Przulj  */
/* Modified to put variables on heap rather than stack  (to be able to process huge networks) by Oleksii */
/* Modified to use bit vectors (8-times less memory) in adjacency matrix by Wayne Hayes, 16 May 2009 */
/* Modified to use maps (sparse) for adjacency matrix by Wayne Hayes, 16 May 2009 */
/* suggested g++-3.4 compile flags: -O3 -funroll-loops     */

/* Usage: ncount <input graph> <output prefix>
 * Counts graphlets and graphlet degrees (called node classes here)
 *
 * Basic algorithm: Brute force enumeration of 3-5 node connected subgraphs
 *   With some overlap that needs to be factored out later.
 *
 * Process is:
 *   Pick node A, pick a node B adj to A, pick a node C adj to B, pick a
 *   node D adj to C, pick a node E adj to D. And each node can only
 *   appear once in the subgraph.
 *
 *   Use a separate process for graphlets containing the claw, by picking
 *   a center node and then picking the rest.
 *
 *   Examine the edges between them to determine which graphlet the
 *   subgraph corresponds to. Classify each node in the graphlet and add
 *   it to the count for that graphlet type.
 *
 *   At the end, divide out the overcount and print out how many
 *   graphlets touch at the same node class/type.
 */

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <string>
#include <assert.h>
#include <map> /* STL ordered dictionary class */
#include <vector>

namespace GraphCrunch
{
    // #define PATH_MAX 256 //Oleksii

    /* These lookup tables were generated by analyzing sample graphs representing
     * each graphlet, and then adjusting the table sizes for perfect hashing.
     */

    /* Lookup table for graphlets. Calculated by:
     * [(sum of (degree % 4 for node/neighbors))/2][edge count/2]-4
     * Special handling needed for X23 and X25
     */
    const char gtable[][8] =
        {{-1, -1, 10, -1, -1, 8}, {-1, 11, -1, -1, 15, 14, 12}, {17, 19, -1, 16, 18, 20}, {-1, -1, 23, 24, -1, 21}, {-1, -1, 26, 25}, {-1, -1, -1, -1, -1, -1, 27}, {28}};

    /* Lookup table for nodes by [graphlet][sum of degrees of node/neighbors] */
    const char ntable[][21] =
        {{-1, -1, -1, 0, 1}, {-1, -1, -1, -1, -1, -1, 2}, {-1, -1, -1, 3, -1, 4}, {-1, -1, -1, -1, 5, -1, 6}, {-1, -1, -1, -1, -1, -1, 7}, {-1, -1, -1, -1, 8, -1, -1, 9, 10}, {-1, -1, -1, -1, -1, -1, -1, -1, 11, -1, 12}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 13}, {-1, -1, -1, 14, -1, 15, 16}, {-1, -1, -1, 17, 18, -1, 19, 20}, {-1, -1, -1, -1, -1, 21, -1, -1, 22}, {-1, -1, -1, -1, 23, -1, -1, -1, 24, 25}, {-1, -1, -1, 26, -1, -1, 27, 28, -1, 29}, {-1, -1, -1, -1, -1, 30, -1, -1, 31, -1, 32}, {-1, -1, -1, -1, -1, -1, 33}, {-1, -1, -1, -1, 34, -1, 35, 36, 37}, {-1, -1, -1, -1, -1, 38, -1, -1, -1, 39, -1, 40, 41}, {-1, -1, -1, -1, -1, -1, -1, -1, 42, -1, -1, -1, 43}, {-1, -1, -1, -1, 44, -1, -1, -1, 45, -1, 46, 47}, {-1, -1, -1, -1, -1, -1, -1, -1, 48, 49}, {-1, -1, -1, -1, -1, -1, -1, 50, 51, -1, 52}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 53, -1, -1, -1, 54}, {-1, -1, -1, -1, -1, 55, -1, -1, -1, -1, -1, -1, -1, 56, 57}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, 58, -1, -1, 59, -1, 60}, {-1, -1, -1, -1, -1, -1, -1, -1, 61, -1, -1, 62, 63}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 64, -1, -1, -1, 65, -1, 66}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 67, -1, -1, 68}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 69, -1, -1, 70}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 71}};

    /* times counted per graphlet type */
    const int overcount[] = {2, 6, 2, 6, 8, 4, 12, 24, 2, 2, 24, 2, 4, 4, 10, 4,
                             4, 8, 8, 12, 14, 12, 12, 20, 28, 36, 48, 72, 120};

    /* graphlet types corresponding to each node type */
    int ntype2gtype[] = {0, 0, 1, 2, 2, 3, 3, 4, 5, 5, 5, 6, 6, 7, 8, 8, 8, 9, 9,
                         9, 9, 10, 10, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 14, 15, 15, 15, 15,
                         16, 16, 16, 16, 17, 17, 18, 18, 18, 18, 19, 19, 20, 20, 20, 21, 21, 22, 22,
                         22, 23, 23, 23, 24, 24, 24, 25, 25, 25, 26, 26, 27, 27, 28};

    /* klcount: ratio of number of nodes of this type to number of graphlets */
    int klcount[] = {2, 1, 3, 2, 2, 3, 1, 4, 1, 2, 1, 2, 2, 4, 2, 2, 1, 1, 2, 1,
                     1, 4, 1, 2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 5, 1, 1, 2, 1, 1, 2,
                     1, 1, 4, 1, 1, 1, 1, 2, 3, 2, 2, 1, 2, 3, 2, 1, 3, 1, 2, 2,
                     1, 1, 2, 2, 1, 2, 2, 4, 1, 2, 3, 5};

    enum {P3_A, P3_B, C3_A, P4_A, P4_B, CLAW_A, CLAW_B, C4_A, FLOW_A, FLOW_B,
          FLOW_C, DIAM_A, DIAM_B, K4_A, P5_A, P5_B, P5_C,
          X10_A, X10_B, X10_C, X10_D, X11_A, X11_B, X12_A, X12_B, X12_C, X13_A,
          X13_B, X13_C, X13_D, X14_A, X14_B, X14_C, C5_A, X16_A, X16_B, X16_C,
          X16_D, X17_A, X17_B, X17_C, X17_D, X18_A, X18_B, X19_A, X19_B, X19_C,
          X19_D, X20_A, X20_B, X21_A, X21_B, X21_C, X22_A, X22_B, X23_A, X23_B,
          X23_C, X24_A, X24_B, X24_C, X25_A, X25_B, X25_C, X26_A, X26_B, X26_C,
          X27_A, X27_B, X28_A, X28_B, K5_A};

    const char *cnames[] = {"P3_A [end]", "P3_B [mid]", "C3_A", "P4_A [end]",
                            "P4_B [mid]", "CLAW_A [outer]", "CLAW_B [center]", "C4_A", "FLOW_A [stem]",
                            "FLOW_B [petals]", "FLOW_C [center]", "DIAM_A [deg2]", "DIAM_B [deg3]",
                            "K4_A", "P5_A", "P5_B", "P5_C", "X10_A", "X10_B", "X10_C", "X10_D", "X11_A",
                            "X11_B", "X12_A", "X12_B", "X12_C", "X13_A", "X13_B", "X13_C", "X13_D",
                            "X14_A", "X14_B", "X14_C", "C5_A", "X16_A", "X16_B", "X16_C", "X16_D",
                            "X17_A", "X17_B", "X17_C", "X17_D", "X18_A", "X18_B", "X19_A", "X19_B",
                            "X19_C", "X19_D", "X20_A", "X20_B", "X21_A", "X21_B", "X21_C", "X22_A",
                            "X22_B", "X23_A", "X23_B", "X23_C", "X24_A", "X24_B", "X24_C", "X25_A",
                            "X25_B", "X25_C", "X26_A", "X26_B", "X26_C", "X27_A", "X27_B", "X28_A",
                            "X28_B", "K5_A"};

    typedef long long int64;

    struct temp_data /* linked list of edges */
    {
        struct temp_data *next;
        int dst;
    };

/* Handy macros; for details see the definition of edges_for */
#define DEGREE(x) (edges_for[x + 1] - edges_for[x])
#define foreach_adj(x, y) for (x = edges_for[y]; x != edges_for[y + 1]; x++)

    void die(char *msg)
    {
        fprintf(stderr, "ERROR: %s\n", msg);
        exit(1);
    }

    std::vector<std::vector<unsigned>> count(FILE *f)
    {
        int V;
        int E;
        int E_undir;
        int i;
        int j;

        fscanf(f, "%d", &V);
        fscanf(f, "%d", &E_undir);
        E = E_undir * 2;
        V++; // nodes are numbered from 1 to V

        assert(E_undir >= 0);

        struct temp_data **heads = new temp_data *[V]; // Oleksii
        struct temp_data *links = new temp_data[E];    // Oleksii
        for (i = 0; i < V; i++)
            heads[i] = NULL;

        struct temp_data *link;

        /* allocate some space for the adjacency matrix */
        char **adjmat = new char *[V]; // Oleksii
/* Use a bit vector to store each row of the adjancency matrix, so
 * that each edge takes up only one bit.
 */
#define Connect(i, j) (adjmat[i][(j) / 8] |= 1 << ((j) % 8))
#define Connected(i, j) (adjmat[i][(j) / 8] & (1 << ((j) % 8)))
        for (i = 0; i < V; i++)
        {
            /* calloc zeroes the memory for us */
            adjmat[i] = (char *)calloc(V / 8 + 1, sizeof(char));
            if (!adjmat[i])
            {
                perror("calloc");
                exit(1);
            }

            Connect(i, i); /* optimization hack */
        }

        /* First stores edges in linked lists by node (vertex) so we know how many
         * edges there are for each node, then copy to an array for efficiency.
         */

        /* add data to linked list for intermediate storage */
        for (i = 0; i < E_undir; i++)
        {
            int src = -1;
            int dst = -1;
            fscanf(f, "%d %d", &src, &dst);
            assert(src < V && dst < V);

            if (src < 0 || dst < 0)
            {
                fprintf(stderr, "Error: node numbers must be greater than zero.\n");
                exit(1);
            }

            if (src == dst)
                continue; /* ignore self-loops */

            /* See if edge is already in list */
            int bad = 0;
            for (link = heads[src]; link; link = link->next)
            {
                if (link->dst == dst)
                {
                    bad = 1; /* don't allow parallel edges */
                    break;
                }
            }
            if (bad)
                continue;

            struct temp_data *ntemp1 = &links[i * 2];
            struct temp_data *ntemp2 = &links[i * 2 + 1];

            /* Add to front of node's linked list */
            ntemp1->next = heads[src];
            ntemp1->dst = dst;
            ntemp2->next = heads[dst];
            ntemp2->dst = src;
            heads[src] = ntemp1;
            heads[dst] = ntemp2;

            Connect(src, dst);
            Connect(dst, src);
        }

        /* The edges[] array stores edges by node sequentially, so the last edge
        of node n is followed by the first edge of n+1. edges_for[] stores
        a pointer to the first edge of a node. */

        int **edges_for = new int *[V + 1]; // Oleksii
        int *edges = new int[E * 2 + 1];    // Oleksii

        int *edge_last = &edges[0];

        for (i = 0; i < V; i++)
        {
            edges_for[i] = edge_last;
            for (link = heads[i]; link; link = link->next)
            {
                *edge_last = link->dst;
                edge_last++;
            }
        }
        edges_for[i] = edge_last;

        int64 gcount[29] = {};
        int64 *ncount[72];

        /* allocate space for node type counts */
        for (i = 0; i < 72; i++)
        {
            ncount[i] = (int64 *)calloc(V, sizeof(int64));
            if (!ncount[i])
            {
                perror("calloc");
                exit(1);
            }
        }

        /* start counting */

        int *pb, *pc, *pd, *pe;
        int a, b, c, d, e, x;

        for (a = 0; a < V; a++)
        {

            foreach_adj(pb, a)
            {
                b = *pb;
                if (b == a)
                    continue;

                foreach_adj(pc, b)
                {
                    c = *pc;
                    if (c == a || c == b)
                        continue;

                    /* count adjacent edges */
                    int deg3_a = 0, deg3_b = 0, deg3_c = 0;

                    // The "!!" is a double negation, which maps any non-zero integer to 1
                    x = !!Connected(a, b);
                    deg3_a += x;
                    deg3_b += x;
                    x = !!Connected(a, c);
                    deg3_a += x;
                    deg3_c += x;
                    x = !!Connected(b, c);
                    deg3_b += x;
                    deg3_c += x;

                    if (deg3_a == 1)
                    {
                        gcount[0]++; /* path */
                        ncount[P3_A][a]++;
                        ncount[P3_B][b]++;
                        ncount[P3_A][c]++;

                        // look for claws
                        if (DEGREE(b) > 2)
                            foreach_adj(pd, b)
                            {
                                d = *pd;
                                if (Connected(a, d) + Connected(c, d) == 0)
                                {
                                    // look for X11
                                    if (DEGREE(b) > 3)
                                        foreach_adj(pe, b)
                                        {
                                            e = *pe;
                                            if (Connected(a, e) + Connected(c, e) + Connected(d, e) == 0)
                                            {
                                                gcount[10]++; /* X11 */
                                                ncount[X11_A][a]++;
                                                ncount[X11_B][b]++;
                                                ncount[X11_A][c]++;
                                                ncount[X11_A][d]++;
                                                ncount[X11_A][e]++;
                                            }
                                        }

                                    gcount[3]++; /* Claw! */
                                    ncount[CLAW_A][a]++;
                                    ncount[CLAW_B][b]++;
                                    ncount[CLAW_A][c]++;
                                    ncount[CLAW_A][d]++;
                                }
                            }
                    }
                    else
                    {
                        gcount[1]++; /* triangle */
                        ncount[C3_A][a]++;
                        ncount[C3_A][b]++;
                        ncount[C3_A][c]++;
                    }

                    foreach_adj(pd, c)
                    {
                        d = *pd;
                        if (d == a || d == b || d == c)
                        {
                            continue;
                        }

                        /* classify most 4-node graphlets (excluding some claws) */

                        int deg4_a = deg3_a, deg4_b = deg3_b, deg4_c = deg3_c, deg4_d = 0;

                        x = !!Connected(a, d);
                        deg4_d += x;
                        deg4_a += x;
                        x = !!Connected(b, d);
                        deg4_d += x;
                        deg4_b += x;
                        x = !!Connected(c, d);
                        deg4_d += x;
                        deg4_c += x;

                        int num_edges = deg4_a + deg4_b + deg4_c + deg4_d;

                        if (num_edges == 6)
                        {
                            gcount[2]++; /* P4 */
                            ncount[P4_A][a]++;
                            ncount[P4_B][b]++;
                            ncount[P4_B][c]++;
                            ncount[P4_A][d]++;

                            foreach_adj(pe, b) /* look for X10 */
                            {
                                e = *pe;
                                if (Connected(a, e) + Connected(c, e) + Connected(d, e) == 0)
                                {
                                    gcount[9]++; /* X10 */
                                    ncount[X10_B][a]++;
                                    ncount[X10_D][b]++;
                                    ncount[X10_C][c]++;
                                    ncount[X10_A][d]++;
                                    ncount[X10_B][e]++;
                                }
                            }
                        }
                        else if (num_edges == 10)
                        {
                            gcount[6]++; /* Diamond */
                            ncount[deg4_a == 3 ? DIAM_B : DIAM_A][a]++;
                            ncount[deg4_b == 3 ? DIAM_B : DIAM_A][b]++;
                            ncount[deg4_c == 3 ? DIAM_B : DIAM_A][c]++;
                            ncount[deg4_d == 3 ? DIAM_B : DIAM_A][d]++;
                        }
                        else if (num_edges == 12)
                        {
                            gcount[7]++; /* K4 */
                            ncount[K4_A][a]++;
                            ncount[K4_A][b]++;
                            ncount[K4_A][c]++;
                            ncount[K4_A][d]++;
                        }
                        else if (num_edges == 8) /* C4 or Flower */
                        {
                            if (deg4_b == 3 || deg4_c == 3)
                            {
                                gcount[5]++; /* Flower */
                                if (deg4_b == 3)
                                {
                                    ncount[FLOW_A][a]++;
                                    ncount[FLOW_C][b]++;
                                    ncount[FLOW_B][c]++;
                                    ncount[FLOW_B][d]++;

                                    // only do this for half the cases, to reduce overcount
                                    foreach_adj(pe, b)
                                    {
                                        e = *pe;
                                        if (Connected(a, e) + Connected(c, e) + Connected(d, e) == 0)
                                        {
                                            gcount[13]++; /* X14 */
                                            ncount[X14_A][a]++;
                                            ncount[X14_C][b]++;
                                            ncount[X14_B][c]++;
                                            ncount[X14_B][d]++;
                                            ncount[X14_A][e]++;
                                        }
                                    }
                                }
                                else
                                {
                                    ncount[FLOW_B][a]++;
                                    ncount[FLOW_B][b]++;
                                    ncount[FLOW_C][c]++;
                                    ncount[FLOW_A][d]++;
                                }
                            }
                            else
                            {
                                gcount[4]++; /* C4 */
                                ncount[C4_A][a]++;
                                ncount[C4_A][b]++;
                                ncount[C4_A][c]++;
                                ncount[C4_A][d]++;
                            }
                        }

                        /* classify most 5-node graphlets */
                        foreach_adj(pe, d)
                        {
                            e = *pe;
                            if (e == a || e == b || e == c || e == d)
                            {
                                continue;
                            }

                            int deg5_a = deg4_a, deg5_b = deg4_b, deg5_c = deg4_c,
                                deg5_d = deg4_d, deg5_e = 0;

                            x = !!Connected(e, a);
                            deg5_e += x;
                            deg5_a += x;
                            x = !!Connected(e, b);
                            deg5_e += x;
                            deg5_b += x;
                            x = !!Connected(e, c);
                            deg5_e += x;
                            deg5_c += x;
                            x = !!Connected(e, d);
                            deg5_e += x;
                            deg5_d += x;

                            /* add degrees of node and neighbors to find each ndeg */
                            int ndeg_a = deg5_a;
                            int ndeg_b = deg5_b;
                            int ndeg_c = deg5_c;
                            int ndeg_d = deg5_d;
                            int ndeg_e = deg5_e;
                            if (Connected(a, b))
                            {
                                ndeg_a += deg5_b;
                                ndeg_b += deg5_a;
                            }
                            if (Connected(a, c))
                            {
                                ndeg_a += deg5_c;
                                ndeg_c += deg5_a;
                            }
                            if (Connected(a, d))
                            {
                                ndeg_a += deg5_d;
                                ndeg_d += deg5_a;
                            }
                            if (Connected(a, e))
                            {
                                ndeg_a += deg5_e;
                                ndeg_e += deg5_a;
                            }
                            if (Connected(b, c))
                            {
                                ndeg_b += deg5_c;
                                ndeg_c += deg5_b;
                            }
                            if (Connected(b, d))
                            {
                                ndeg_b += deg5_d;
                                ndeg_d += deg5_b;
                            }
                            if (Connected(b, e))
                            {
                                ndeg_b += deg5_e;
                                ndeg_e += deg5_b;
                            }
                            if (Connected(c, d))
                            {
                                ndeg_c += deg5_d;
                                ndeg_d += deg5_c;
                            }
                            if (Connected(c, e))
                            {
                                ndeg_c += deg5_e;
                                ndeg_e += deg5_c;
                            }
                            if (Connected(d, e))
                            {
                                ndeg_d += deg5_e;
                                ndeg_e += deg5_d;
                            }

                            // note that (x%4 + y%4) is not the same as (x+y)%4
                            int hash = (ndeg_a % 4 + ndeg_b % 4 + ndeg_c % 4 + ndeg_d % 4 + ndeg_e % 4);
                            int deg_total = deg5_a + deg5_b + deg5_c + deg5_d + deg5_e;
                            int gtype = gtable[deg_total / 2 - 4][hash / 2];

                            /* not caught by table */
                            if (deg_total == 14 && hash == 6)
                                gtype = (ndeg_a > 12 || ndeg_a == 5) ? 22 : 24;

                            assert(gtype > 7 && gtype < 29);

                            gcount[gtype]++;

                            ncount[(int)ntable[gtype][ndeg_a]][a]++;
                            ncount[(int)ntable[gtype][ndeg_b]][b]++;
                            ncount[(int)ntable[gtype][ndeg_c]][c]++;
                            ncount[(int)ntable[gtype][ndeg_d]][d]++;
                            ncount[(int)ntable[gtype][ndeg_e]][e]++;
                        }
                    }
                }
            }
        }

        /* output */
        std::vector<std::vector<unsigned>> gdvs;

        for (j = 1; j < V; j++)
        {
            std::vector<unsigned> gdv;

            gdv.push_back(DEGREE(j));

            for (i = 0; i < 72; i++)
            {
                gdv.push_back((unsigned)ncount[i][j] / overcount[ntype2gtype[i]]);
            }
            gdvs.push_back(gdv);
        }

        return gdvs;
    }

    std::vector<std::vector<unsigned>> graphcrunch(std::string in_file_str)
    {
        const char *in_file = in_file_str.c_str();

        FILE *fp = fopen(in_file, "r");
        if (!fp)
        {
            perror(in_file);
            exit(1);
        }

        std::vector<std::vector<unsigned>> gdvs = count(fp);

        fclose(fp);

        return gdvs;
    }

}
