/*

  Create a file with this name, 'javascriptfragments.swg', in your working
  directory and add all the %fragments you want to take precedence
  over the default ones defined by alaqil.

  For example, if you add:
  
  %fragment(alaqil_AsVal_frag(int),"header") {
   alaqilINTERNINLINE int
   alaqil_AsVal(int)(PyObject *obj, int *val)
   { 
     <your code here>;
   }
  }
  
  this will replace the code used to retrieve an integer value for all
  the typemaps that need it, including:
  
    int, std::vector<int>, std::list<std::pair<int,int> >, etc.

    
*/
