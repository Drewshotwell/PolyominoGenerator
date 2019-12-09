import java.util.LinkedList;
import java.util.Arrays;
import java.util.HashSet;

class Segment {
  int x, y;
  static final int blockWidth = 25;
  Segment(int x, int y) {
    this.x = x;
    this.y = y;
  }
  void drawBlockPt() {
    fill(0, 255, 0);
    rect(blockWidth*x, blockWidth*y, blockWidth, blockWidth);
  }
}

class Piece {
  Segment[] segments;
  Segment center;
  Piece(Segment[] segments){
    this.segments = segments;
    center = segments[0];
  }
  void setCenter(int setIdx) {
    center = segments[setIdx];
    for (Segment otherSegment : segments) {
      if (otherSegment != center) {
        otherSegment.x -= center.x;
        otherSegment.y -= center.y;
      }
    }
    center.x = 0;
    center.y = 0;
  }
  void drawPiece() {
    for (Segment seg : segments)
      seg.drawBlockPt();
  }
  Piece clone(){
    Segment[] sArr = new Segment[segments.length];
    for(int i = 0; i < sArr.length; i++){
      sArr[i] = new Segment(segments[i].x, segments[i].y); 
    }
    return new Piece(sArr);
  }
  Piece rotated(double theta){
    for (Segment s : segments){
      Segment sClone = new Segment(s.x, s.y); // cloned to not affect s.y computation in terms of s.x value
      // Rotation matrix operation 
      s.x = sClone.x*(int)Math.cos(theta) - sClone.y*(int)Math.sin(theta);
      s.y = sClone.x*(int)Math.sin(theta) + sClone.y*(int)Math.cos(theta);
    }
    return this;
  }
  boolean equals(Piece p){
    for (Segment s1 : segments){
      for (Segment s2 : p.segments){
        if (s1.x == s2.x && s1.y == s2.y) break; // stops search for this segment since it's been found
        else if (s2 == p.segments[p.segments.length - 1]) return false; // one segment did not find any coorelate in the other piece
      }
    }
    return true; // made it through the list, so each segment has a correlate
  }
  boolean isConnected() {
    PathFinder finder = new PathFinder(segments);
    finder.stepPathRecursively(this, center);
    return finder.pathConnected();
  }
  boolean isUnique(LinkedList<Piece> list) {
    if (list.size() == 0) return true; // piece is unique if it's the first one
    Piece pClone = clone();
    for (Piece checkPiece : list) { // iterate through the list to compare each piece
      for (int centerIdx = 0; centerIdx < pClone.segments.length; centerIdx++){
        pClone.setCenter(centerIdx);
        for (int rotIdx = 0; rotIdx < 4; rotIdx++){
          if (pClone
                .rotated(rotIdx*Math.PI / 2)
                .equals(checkPiece)) return false;
        }
      }
      pClone = clone();
    }
    return true; // piece is unique if it makes it through the list without having any rotational symmetry with the rest of the pieces
  }
}

class PieceSet {
  LinkedList<Piece> list = new LinkedList<Piece>();
  int setSize = 0;
  Piece shownPiece;
  int shownIdx = 0;
  void addPiece(Piece p){
    list.add(p);
  }
  void setShownPiece(int setIdx){
    shownPiece = list.get(setIdx);
  }
  void incrementShownPiece(){ 
    shownIdx = (shownIdx + 1) % list.size();
    shownPiece = list.get(shownIdx);
  }
  void decrementShownPiece(){ 
    shownIdx -= shownIdx == 0 ? -(list.size() - 1) : 1;
    shownPiece = list.get(shownIdx);
  }
  void drawShownPiece(){
    shownPiece.drawPiece();
  }
  void generatePieces(int n){
    list.clear();
    shownIdx = 0;
    int N = n*(int)Math.round((double)n/2), R = n;
    LinkedList<int[]> combinations = generate(N, R);
    
    for (int[] combination : combinations) {
      Segment[] curPieceSegs = new Segment[n];
      for (int x = 0; x < combination.length; x++){
        curPieceSegs[x] = new Segment(combination[x] % n, (int)Math.floor(combination[x] / n));
      }
      Piece candidate = new Piece(curPieceSegs);
      if (candidate.isConnected()
       && candidate.isUnique(list)){
        candidate.setCenter(0);
        addPiece(candidate);
      }
    }
    setShownPiece(0);
  }
}

class PathFinder {
  HashSet<Segment> compareSet, accumulator;
  PathFinder(Segment[] segments){
    HashSet<Segment> presentSegments = new HashSet<Segment>(); 
    presentSegments.addAll(new LinkedList<Segment>(Arrays.asList(segments)));
    compareSet = presentSegments;
    accumulator = new HashSet<Segment>();
  }
  boolean pathConnected(){
    return compareSet.equals(accumulator);
  }
  void stepPathRecursively(Piece p, Segment s){
    accumulator.add(s);
    for (int rotIdx = 0; rotIdx < 4; rotIdx++){
      for (Segment pSeg : p.segments){
        if (!accumulator.contains(pSeg)
         && pSeg.x == s.x + (int)Math.cos(rotIdx*Math.PI / 2) 
         && pSeg.y == s.y + (int)Math.sin(rotIdx*Math.PI / 2)){
           stepPathRecursively(p, pSeg);
           break;
        }
      }
    }
  }
}

PieceSet pieces;
int order = 4;

void settings() {
  size(400, 400);
}

void setup() {
  pieces = new PieceSet();
  pieces.generatePieces(order);
  frameRate(4);
}

void draw(){
  translate(200, 200);
  background(255);
  fill(0);
  text(String.format("Piece %d out of %d. Order: %d\n"
                   + "Left and Right to change piece.\n"
                   + "Up and Down to change order.", 
    pieces.shownIdx + 1, pieces.list.size(), order), -100, -100);
  pieces.drawShownPiece();
}

void keyPressed(){
  if (key == CODED){
    if (keyCode == RIGHT){
      pieces.incrementShownPiece();
    }
    else if (keyCode == LEFT){
      pieces.decrementShownPiece();
    }
    else if (keyCode == UP){
      pieces.generatePieces(++order);
    }
    else if (keyCode == DOWN){
      pieces.generatePieces(--order);
    }
  }
}

/*
Credit for the next two functions goes to:
  https://www.baeldung.com/java-combinations-algorithm
*/
void helper(LinkedList<int[]> combinations, int data[], int start, int end, int index) {
  if (index == data.length) {
    int[] combination = data.clone();
    combinations.add(combination);
  } else if (start <= end) {
    data[index] = start;
    helper(combinations, data, start + 1, end, index + 1);
    helper(combinations, data, start + 1, end, index);
  }
}

LinkedList<int[]> generate(int n, int r){
  LinkedList<int[]> combinations = new LinkedList<int[]>();
  helper(combinations, new int[r], 0, n-1, 0);
  return combinations;
}
