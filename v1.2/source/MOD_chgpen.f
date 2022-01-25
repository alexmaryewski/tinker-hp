c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ##################################################################
c     ##                                                              ##
c     ##  module chgpen  --  charge penetration in current structure  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     ncp       total number of charge penetration sites in system
c     pcore     number of core electrons at each multipole site
c     pval      number of valence electrons at each multipole site
c     pval0     original number of valence electrons at each multipole site for chglx
c     palpha    charge penetration damping at each multipole site
c     winpcore  window corresponding to pcore array
c     winpval   window corresponding to pval array
c     winpalpha window corresponding to palpha array
c
c
      module chgpen
      implicit none
      integer ncp
      real*8, pointer :: pcore(:)
      real*8, pointer :: pval(:)
      real*8, pointer :: pval0(:)
      real*8, pointer :: palpha(:)
      integer :: winpcore,winpval,winpval0,winpalpha
      save
      end
