c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ##############################################################
c     ##                                                          ##
c     ##  rgddyn.i  --  velocities and momenta for rigid body MD  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     xcmo    x-component from each atom to center of rigid body
c     ycmo    y-component from each atom to center of rigid body
c     zcmo    z-component from each atom to center of rigid body
c     vcm     current translational velocity of each rigid body
c     wcm     current angular velocity of each rigid body
c     lm      current angular momentum of each rigid body
c     vc      half-step translational velocity for kinetic energy
c     wc      half-step angular velocity for kinetic energy
c     linear  logical flag to mark group as linear or nonlinear
c
c
      real*8 xcmo,ycmo,zcmo
      real*8 vcm,wcm
      real*8 lm,vc,wc
      logical linear
c      common /rgddyn/ xcmo(maxatm),ycmo(maxatm),zcmo(maxatm),
c     &                vcm(3,maxgrp),wcm(3,maxgrp),lm(3,maxgrp),
c     &                vc(3,maxgrp),wc(3,maxgrp),linear(maxgrp)
      common /rgddyn/ vcm(3,maxgrp),wcm(3,maxgrp),lm(3,maxgrp),
     &                vc(3,maxgrp),wc(3,maxgrp),linear(maxgrp)
