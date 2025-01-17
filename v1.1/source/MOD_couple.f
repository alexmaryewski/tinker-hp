c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     #################################################################
c     ##                                                             ##
c     ##  module couple  --  near-neighbor atom connectivity lists   ##
c     ##                                                             ##
c     #################################################################
c
c
c     maxn13   maximum number of atoms 1-3 connected to an atom
c     maxn14   maximum number of atoms 1-4 connected to an atom
c     maxn15   maximum number of atoms 1-5 connected to an atom
c
c     n12      number of atoms directly bonded to each atom
c     i12      atom numbers of atoms 1-2 connected to each atom
c     n13      number of atoms in a 1-3 relation to each atom
c     i13      atom numbers of atoms 1-3 connected to each atom
c     n14      number of atoms in a 1-4 relation to each atom
c     i14      atom numbers of atoms 1-4 connected to each atom
c     n15      number of atoms in a 1-5 relation to each atom
c     i15      atom numbers of atoms 1-5 connected to each atom
c
c
      module couple
      use sizes
      implicit none
      integer maxn13,maxn14,maxn15
      parameter (maxn13=3*maxvalue)
      parameter (maxn14=3*maxvalue)
      parameter (maxn15=3*maxvalue)
      integer, pointer :: n12(:),i12(:,:),n13(:),i13(:,:)
      integer, pointer ::  n14(:),i14(:,:),n15(:),i15(:,:)
      save
      end
