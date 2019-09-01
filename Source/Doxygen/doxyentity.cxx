/* -----------------------------------------------------------------------------
 * This file is part of alaqil, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * doxyentity.cxx
 *
 * Part of the Doxygen comment translation module of alaqil.
 * ----------------------------------------------------------------------------- */

#include "doxyentity.h"
#include <iostream>

using std::cout;

DoxygenEntity::DoxygenEntity(const std::string &typeEnt):typeOfEntity(typeEnt), isLeaf(true) {
}


/* Basic node for commands that have
 * only 1 item after them
 * example: \b word
 * OR holding a std::string
 */
DoxygenEntity::DoxygenEntity(const std::string &typeEnt, const std::string &param1) : typeOfEntity(typeEnt), data(param1), isLeaf(true) {
}


/* Nonterminal node
 * contains
 */
DoxygenEntity::DoxygenEntity(const std::string &typeEnt, const DoxygenEntityList &entList) : typeOfEntity(typeEnt), isLeaf(false), entityList(entList) {
}


void DoxygenEntity::printEntity(int level) const {

  int thisLevel = level;

  if (isLeaf) {
    for (int i = 0; i < thisLevel; i++) {
      cout << "\t";
    }

    cout << "Node Leaf Command: '" << typeOfEntity << "',  ";

    if (!data.empty()) {
      cout << "Node Data: '" << data << "'";
    }
    cout << std::endl;

  } else {

    for (int i = 0; i < thisLevel; i++) {
      cout << "\t";
    }

    cout << "Node Command: '" << typeOfEntity << "'" << std::endl;

    thisLevel++;

    for (DoxygenEntityListCIt p = entityList.begin(); p != entityList.end(); p++) {
      p->printEntity(thisLevel);
    }
  }
}
