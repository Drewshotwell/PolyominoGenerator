# PolyominoGenerator
 
[Polyominoes](https://en.wikipedia.org/wiki/Polyomino) are, essentially, a group of blocks connected orthogonally. The most popular instance of polyominoes is found in the game Tetris, where the main pieces are called "tetriminoes," an idiosyncratic alias for "tetromino," the polyomino with order $n = 4$. In my time playing Tetris, I've been interested in understanding why the total number of tetriminoes was 7, a seemingly odd (pun intended) number for the cardinality of an otherwise innocuous looking set. This program is a result of wanting to know more not only about the set of tetriminoes, but about the set of any group of polyominoes in general.

Instead of looking for a single function that would return the cardinality of a set of any given order, this program actually contructs a linked list of a polyomino objects, (denoted ```PieceSet``` in the program).

To begin, we start with a rectagular grid where we will generate a set of a candidate pieces that may be qualified to enter the set. For order $n$, it seems initially we need size $n^2$ to allow for every piece to fit. However, for any order, the one piece that will take up the largest amount of space in both horizontal and vertical directions is the "L" piece, where it's width is $floor(n/2)$ and height $floor(n/2) + 1$. Therefore, since every other piece takes up more vertical space, stretching into the total length of $n$, up until the "I" piece taking up the entire length of $n$, we only need a $floor(n/2)$ by $n$ rectangular grid to house all our candidate pieces.

![][grid]

The candidate pieces are made by generating all ```combinations``` of $n$ blocks placed in the grid. There are two main tests to see if a given candidate piece in this set is to be added to the final set: 1) that it is connected, and 2) that it is unique. By connected it is meant that every segment is orthogonally adjeacent to at least one other (solved by the function ```stepPathRecursively```), and by unique it is meant that every piece cannot be transformed in any way (beside reflection) to match any other piece already in the generated piece set.

[grid]: MaximumGridSizePoly.jpg