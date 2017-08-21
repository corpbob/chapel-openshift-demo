const n = 4;
var vec = 1..n;
var blockSize = 2;

var A: [vec, vec] real;
var B: [vec, vec] real;
var C: [vec, vec] real;

coforall loc in Locales {
  on loc {
    var i = loc.id/2;
    var j = loc.id%2;
    var istart = i*blockSize;
    var iend = istart + blockSize;
    var jstart = j*blockSize;
    var jend = jstart + blockSize;

    for (r,s) in {istart + 1..iend, jstart + 1..jend} {
      writeln('istart = ' + istart + ', iend=' + iend + ', jstart=' + jstart + ',jend=' + jend);
      B(r,s) = r+s;
      A(r,s) = 2*r + s;
    }
  }
}

writeln("A=");
writeln(A);
writeln("B=");
writeln(B);


coforall loc in Locales {
  on loc {
    var i = loc.id/2;
    var j= loc.id%2;
    var istart = i*blockSize;
    var iend = istart + blockSize;
    var jstart = j*blockSize;
    var jend = jstart + blockSize;
    var r = { istart + 1..iend, jstart + 1..jend };
    var Z: [1..2,1..2] real;
    ref W = C[r].reindex( { 1..2,1..2 });
      
    coforall k in 0..1 {
      var U=get_block_matrix(A[vec,vec],i,k,blockSize);
      var V=get_block_matrix(B[vec,vec],k,j,blockSize);
      var P = mat_mul(U,V);
      coforall (s,t) in { 1..2,1..2 } {
        if loc.id == 1 {
          writeln("i,j=", s+i, ",", t+j);
        }
        W(s,t) += P(s,t); 
      }
    }
  }
}

proc get_block_matrix(A: [?D], i:int, j:int , blockSize:int) {
  var r = { i*blockSize+1 .. i*blockSize +  blockSize, j*blockSize + 1 .. j*blockSize + blockSize };
  return A[r]; 
}

proc mat_mul(A: [?D1], B: [?D2]) {
  var D3 = { 1..2, 1..2 };
  var C: [D3] real;
  var AA = A.reindex({1..2,1..2});
  var BB = B.reindex({1..2,1..2});

  for row in 1..2 {
    for col in 1..2 {
      var sum:real = 0;
      for k in 1..2 {
         sum += AA(row,k) * BB(k,col);
      }
      C(row,col) = sum;
    }
  }
  return C;
}

writeln('C=');
writeln(C[vec,vec]);


