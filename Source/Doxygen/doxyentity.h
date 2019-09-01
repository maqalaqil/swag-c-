/* -----------------------------------------------------------------------------
 * This file is part of alaqil, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * doxyentity.h
 *
 * Part of the Doxygen comment translation module of alaqil.
 * ----------------------------------------------------------------------------- */

#ifndef DOXYGENENTITY_H_
#define DOXYGENENTITY_H_

#include <string>
#include <list>


class DoxygenEntity;

typedef std::list<DoxygenEntity> DoxygenEntityList;
typedef DoxygenEntityList::iterator DoxygenEntityListIt;
typedef DoxygenEntityList::const_iterator DoxygenEntityListCIt;


/*
 * Structure to represent a doxygen comment entry
 */
class DoxygenEntity {
public:
  std::string typeOfEntity;
  std::string data;
  bool isLeaf;
  DoxygenEntityList entityList;

  DoxygenEntity(const std::string &typeEnt);
  DoxygenEntity(const std::string &typeEnt, const std::string &param1);
  DoxygenEntity(const std::string &typeEnt, const DoxygenEntityList &entList);

  void printEntity(int level) const;
};

#endif
