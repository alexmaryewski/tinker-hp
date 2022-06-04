c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ##########################################################################
c     ##                                                                      ##
c     ##  subroutine erepel1  --  Pauli repulsion energy & first derivatives  ##
c     ##                                                                      ##
c     ##########################################################################
c
c
c     "erepel1" calculates the Pauli repulsion energy and first derivatives
c
c     literature reference:
c
c     J. A. Rackers and J. W. Ponder, "Classical Pauli Repulsion:
c     An Anisotropic, Atomic Multipole Model", Journal of Chemical
c     Physics, 150, 084104 (2019)
c
c
      subroutine erepel1
      implicit none
c
c
c     choose the method for summing over pairwise interactions
c
      call erepel1c
      return
      end
c
c
c     ######################################################################################
c     ##                                                                                  ##
c     ##  subroutine erepel1c  --  Pauli repulsion energy and first derivatives via list  ##
c     ##                                                                                  ##
c     ######################################################################################
c
c
c     "erepel1c" calculates the Pauli repulsion energy and first derivatives
c     using a neighbor list
c
c
      subroutine erepel1c
      use atoms
      use atmlst
      use bound
      use couple
      use cutoff
      use deriv
      use domdec
      use energi
      use group
      use inform
      use mpole
      use mutant
      use neigh
      use potent
      use repel
      use reppot
      use shunt
      use usage
      use virial
      implicit none
      integer i,j,iipole,iglob,kglob,nnelst
      integer ii,kkk,kbis,kkpole
      integer ix,iy,iz
      real*8 e,fgrp
      real*8 eterm,de
      real*8 xi,yi,zi
      real*8 xr,yr,zr
      real*8 xix,yix,zix
      real*8 xiy,yiy,ziy
      real*8 xiz,yiz,ziz
      real*8 r,r2,r3,r4,r5
      real*8 rr1,rr3,rr5
      real*8 rr7,rr9,rr11
      real*8 ci,dix,diy,diz
      real*8 qixx,qixy,qixz
      real*8 qiyy,qiyz,qizz
      real*8 ck,dkx,dky,dkz
      real*8 qkxx,qkxy,qkxz
      real*8 qkyy,qkyz,qkzz
      real*8 dir,dkr,dik,qik
      real*8 qix,qiy,qiz,qir
      real*8 qkx,qky,qkz,qkr
      real*8 diqk,dkqi,qiqk
      real*8 dirx,diry,dirz
      real*8 dkrx,dkry,dkrz
      real*8 dikx,diky,dikz
      real*8 qirx,qiry,qirz
      real*8 qkrx,qkry,qkrz
      real*8 qikx,qiky,qikz
      real*8 qixk,qiyk,qizk
      real*8 qkxi,qkyi,qkzi
      real*8 qikrx,qikry,qikrz
      real*8 qkirx,qkiry,qkirz
      real*8 diqkx,diqky,diqkz
      real*8 dkqix,dkqiy,dkqiz
      real*8 diqkrx,diqkry,diqkrz
      real*8 dkqirx,dkqiry,dkqirz
      real*8 dqikx,dqiky,dqikz
      real*8 term1,term2,term3
      real*8 term4,term5,term6
      real*8 sizi,sizk,sizik
      real*8 vali,valk
      real*8 dmpi,dmpk
      real*8 frcx,frcy,frcz
      real*8 term,soft,dsoft
      real*8 taper,dtaper
      real*8 vxx,vyy,vzz
      real*8 vxy,vxz,vyz
      real*8 ttri(3),ttrk(3)
      real*8 fix(3),fiy(3),fiz(3)
      real*8 dmpik(11)
      real*8 s,ds,repshortcut2,facts,factds
      real*8, allocatable :: rscale(:)
      real*8, allocatable :: ter(:,:)
      logical testcut,shortrange,longrange,fullrange
      logical proceed,usei
      logical muti,mutk,mutik
      character*11 mode
      character*80 :: RoutineName
      shortrange = use_repulsshort
      longrange  = use_repulslong
      fullrange  = .not.(shortrange.or.longrange)

      if (shortrange) then 
         RoutineName = 'erepel3short3c'
         mode        = 'SHORTREPULS'
      else if (longrange) then
         RoutineName = 'erepel3long3c'
         mode        = 'REPULS'
      else
         RoutineName = 'erepel3c'
         mode        = 'REPULS'
      endif
c
c
c     zero out the Pauli repulsion energy and derivatives
c
      er = 0.0d0
      der = 0d0
c
c     check the sign of multipole components at chiral sites
c
      call chkpole(.false.)
c
c     rotate the multipole components into the global frame
c
      call rotpole
c
c     perform dynamic allocation of some local arrays
c
      allocate (rscale(n))
      allocate (ter(3,nbloc))
c
c     initialize connected atom scaling and torque arrays
c
      rscale = 1.0d0
      ter = 0.0d0
c
c     set the coefficients for the switching function
c
      call switch (mode)
      repshortcut2 = (repshortcut-shortheal)**2
c
c
      do ii = 1, npolelocnl
         iipole = poleglobnl(ii)
         iglob = ipole(iipole)
         muti = mut(iglob)
         i = loc(iglob)
         xi = x(iglob)
         yi = y(iglob)
         zi = z(iglob)
         sizi = sizpr(iglob)
         dmpi = dmppr(iglob)
         vali = elepr(iglob)
         ci = rpole(1,iipole)
         dix = rpole(2,iipole)
         diy = rpole(3,iipole)
         diz = rpole(4,iipole)
         qixx = rpole(5,iipole)
         qixy = rpole(6,iipole)
         qixz = rpole(7,iipole)
         qiyy = rpole(9,iipole)
         qiyz = rpole(10,iipole)
         qizz = rpole(13,iipole)
         usei = use(iglob)
c
c     set exclusion coefficients for connected atoms
c
         do j = 1, n12(iglob)
            rscale(i12(j,iglob)) = r2scale
         end do
         do j = 1, n13(iglob)
            rscale(i13(j,iglob)) = r3scale
         end do
         do j = 1, n14(iglob)
            rscale(i14(j,iglob)) = r4scale
         end do
         do j = 1, n15(iglob)
            rscale(i15(j,iglob)) = r5scale
         end do
c
c     evaluate all sites within the cutoff distance
c
         if (shortrange) then
           nnelst = nshortelst(ii)
         else
           nnelst = nelst(ii)
         end if
         do kkk = 1, nnelst
            if (shortrange) then
              kkpole = shortelst(kkk,ii)
            else
              kkpole = elst(kkk,ii)
            end if
            kglob = ipole(kkpole)
            kbis = loc(kglob)
            mutk = mut(kglob)
            proceed = (usei .or. use(kglob))
            if (use_group)  call groups (fgrp,iglob,kglob,0,0,0,0)
            if (proceed) then
               xr = x(kglob) - xi
               yr = y(kglob) - yi
               zr = z(kglob) - zi
               if (use_bounds)  call image (xr,yr,zr)
               r2 = xr*xr + yr* yr + zr*zr
               testcut = merge(r2 .le. off2.and.r2.ge.repshortcut2,
     &                         r2 .le. off2,
     &                         longrange
     &                        )
               if (testcut) then
                  r = sqrt(r2)
                  sizk = sizpr(kglob)
                  dmpk = dmppr(kglob)
                  valk = elepr(kglob)
                  ck = rpole(1,kkpole)
                  dkx = rpole(2,kkpole)
                  dky = rpole(3,kkpole)
                  dkz = rpole(4,kkpole)
                  qkxx = rpole(5,kkpole)
                  qkxy = rpole(6,kkpole)
                  qkxz = rpole(7,kkpole)
                  qkyy = rpole(9,kkpole)
                  qkyz = rpole(10,kkpole)
                  qkzz = rpole(13,kkpole)
c
c     intermediates involving moments and separation distance
c
                  dir = dix*xr + diy*yr + diz*zr
                  qix = qixx*xr + qixy*yr + qixz*zr
                  qiy = qixy*xr + qiyy*yr + qiyz*zr
                  qiz = qixz*xr + qiyz*yr + qizz*zr
                  qir = qix*xr + qiy*yr + qiz*zr
                  dkr = dkx*xr + dky*yr + dkz*zr
                  qkx = qkxx*xr + qkxy*yr + qkxz*zr
                  qky = qkxy*xr + qkyy*yr + qkyz*zr
                  qkz = qkxz*xr + qkyz*yr + qkzz*zr
                  qkr = qkx*xr + qky*yr + qkz*zr
                  dik = dix*dkx + diy*dky + diz*dkz
                  qik = qix*qkx + qiy*qky + qiz*qkz
                  diqk = dix*qkx + diy*qky + diz*qkz
                  dkqi = dkx*qix + dky*qiy + dkz*qiz
                  qiqk = 2.0d0*(qixy*qkxy+qixz*qkxz+qiyz*qkyz)
     &                      + qixx*qkxx + qiyy*qkyy + qizz*qkzz
c
c     additional intermediates involving moments and distance
c
                  dirx = diy*zr - diz*yr
                  diry = diz*xr - dix*zr
                  dirz = dix*yr - diy*xr
                  dkrx = dky*zr - dkz*yr
                  dkry = dkz*xr - dkx*zr
                  dkrz = dkx*yr - dky*xr
                  dikx = diy*dkz - diz*dky
                  diky = diz*dkx - dix*dkz
                  dikz = dix*dky - diy*dkx
                  qirx = qiz*yr - qiy*zr
                  qiry = qix*zr - qiz*xr
                  qirz = qiy*xr - qix*yr
                  qkrx = qkz*yr - qky*zr
                  qkry = qkx*zr - qkz*xr
                  qkrz = qky*xr - qkx*yr
                  qikx = qky*qiz - qkz*qiy
                  qiky = qkz*qix - qkx*qiz
                  qikz = qkx*qiy - qky*qix
                  qixk = qixx*qkx + qixy*qky + qixz*qkz
                  qiyk = qixy*qkx + qiyy*qky + qiyz*qkz
                  qizk = qixz*qkx + qiyz*qky + qizz*qkz
                  qkxi = qkxx*qix + qkxy*qiy + qkxz*qiz
                  qkyi = qkxy*qix + qkyy*qiy + qkyz*qiz
                  qkzi = qkxz*qix + qkyz*qiy + qkzz*qiz
                  qikrx = qizk*yr - qiyk*zr
                  qikry = qixk*zr - qizk*xr
                  qikrz = qiyk*xr - qixk*yr
                  qkirx = qkzi*yr - qkyi*zr
                  qkiry = qkxi*zr - qkzi*xr
                  qkirz = qkyi*xr - qkxi*yr
                  diqkx = dix*qkxx + diy*qkxy + diz*qkxz
                  diqky = dix*qkxy + diy*qkyy + diz*qkyz
                  diqkz = dix*qkxz + diy*qkyz + diz*qkzz
                  dkqix = dkx*qixx + dky*qixy + dkz*qixz
                  dkqiy = dkx*qixy + dky*qiyy + dkz*qiyz
                  dkqiz = dkx*qixz + dky*qiyz + dkz*qizz
                  diqkrx = diqkz*yr - diqky*zr
                  diqkry = diqkx*zr - diqkz*xr
                  diqkrz = diqky*xr - diqkx*yr
                  dkqirx = dkqiz*yr - dkqiy*zr
                  dkqiry = dkqix*zr - dkqiz*xr
                  dkqirz = dkqiy*xr - dkqix*yr
                  dqikx = diy*qkz - diz*qky + dky*qiz - dkz*qiy
     &                    - 2.0d0*(qixy*qkxz+qiyy*qkyz+qiyz*qkzz
     &                            -qixz*qkxy-qiyz*qkyy-qizz*qkyz)
                  dqiky = diz*qkx - dix*qkz + dkz*qix - dkx*qiz
     &                    - 2.0d0*(qixz*qkxx+qiyz*qkxy+qizz*qkxz
     &                            -qixx*qkxz-qixy*qkyz-qixz*qkzz)
                  dqikz = dix*qky - diy*qkx + dkx*qiy - dky*qix
     &                    - 2.0d0*(qixx*qkxy+qixy*qkyy+qixz*qkyz
     &                            -qixy*qkxx-qiyy*qkxy-qiyz*qkxz)
c
c     get reciprocal distance terms for this interaction
c
                  rr1 = 1.0d0 / r
                  rr3 = rr1 / r2
                  rr5 = 3.0d0 * rr3 / r2
                  rr7 = 5.0d0 * rr5 / r2
                  rr9 = 7.0d0 * rr7 / r2
                  rr11 = 9.0d0 * rr9 / r2
c
c     get damping coefficients for the Pauli repulsion energy
c
                  call damprep (r,r2,rr1,rr3,rr5,rr7,rr9,rr11,
     &                             11,dmpi,dmpk,dmpik)                  
c
c     calculate intermediate terms needed for the energy
c
                  term1 = vali*valk
                  term2 = valk*dir - vali*dkr + dik
                  term3 = vali*qkr + valk*qir - dir*dkr
     &                       + 2.0d0*(dkqi-diqk+qiqk)
                  term4 = dir*qkr - dkr*qir - 4.0d0*qik
                  term5 = qir*qkr
                  eterm = term1*dmpik(1) + term2*dmpik(3)
     &                       + term3*dmpik(5) + term4*dmpik(7)
     &                       + term5*dmpik(9)
c
c     compute the Pauli repulsion energy for this interaction
c
                  sizik = sizi * sizk * rscale(kglob)
                  e = sizik * eterm * rr1
c
c     calculate intermediate terms for force and torque
c
                  de = term1*dmpik(3) + term2*dmpik(5)
     &                    + term3*dmpik(7) + term4*dmpik(9)
     &                    + term5*dmpik(11)
                  
                  term1 = -valk*dmpik(3) + dkr*dmpik(5)
     &                       - qkr*dmpik(7)
                  term2 = vali*dmpik(3) + dir*dmpik(5)
     &                       + qir*dmpik(7)
                  term3 = 2.0d0 * dmpik(5)
                  term4 = 2.0d0 * (-valk*dmpik(5) + dkr*dmpik(7)
     &                                - qkr*dmpik(9))
                  term5 = 2.0d0 * (-vali*dmpik(5) - dir*dmpik(7)
     &                                - qir*dmpik(9))
                  term6 = 4.0d0 * dmpik(7)
c     
c     compute the force components for this interaction
c     
                  frcx = de*xr + term1*dix + term2*dkx
     &                      + term3*(diqkx-dkqix) + term4*qix
     &                      + term5*qkx + term6*(qixk+qkxi)
                  frcy = de*yr + term1*diy + term2*dky
     &                      + term3*(diqky-dkqiy) + term4*qiy
     &                      + term5*qky + term6*(qiyk+qkyi)
                  frcz = de*zr + term1*diz + term2*dkz
     &                      + term3*(diqkz-dkqiz) + term4*qiz
     &                      + term5*qkz + term6*(qizk+qkzi)
                  frcx = frcx*rr1 + eterm*rr3*xr
                  frcy = frcy*rr1 + eterm*rr3*yr
                  frcz = frcz*rr1 + eterm*rr3*zr
                  frcx = sizik * frcx
                  frcy = sizik * frcy
                  frcz = sizik * frcz
c
c     compute the torque components for this interaction
c
                  ttri(1) = -dmpik(3)*dikx + term1*dirx
     &                         + term3*(dqikx+dkqirx)
     &                         - term4*qirx - term6*(qikrx+qikx)
                  ttri(2) = -dmpik(3)*diky + term1*diry
     &                         + term3*(dqiky+dkqiry)
     &                         - term4*qiry - term6*(qikry+qiky)
                  ttri(3) = -dmpik(3)*dikz + term1*dirz
     &                         + term3*(dqikz+dkqirz)
     &                         - term4*qirz - term6*(qikrz+qikz)
                  ttrk(1) = dmpik(3)*dikx + term2*dkrx
     &                         - term3*(dqikx+diqkrx)
     &                         - term5*qkrx - term6*(qkirx-qikx)
                  ttrk(2) = dmpik(3)*diky + term2*dkry
     &                         - term3*(dqiky+diqkry)
     &                         - term5*qkry - term6*(qkiry-qiky)
                  ttrk(3) = dmpik(3)*dikz + term2*dkrz
     &                         - term3*(dqikz+diqkrz)
     &                         - term5*qkrz - term6*(qkirz-qikz)
                  ttri(1) = sizik * ttri(1) * rr1
                  ttri(2) = sizik * ttri(2) * rr1
                  ttri(3) = sizik * ttri(3) * rr1
                  ttrk(1) = sizik * ttrk(1) * rr1
                  ttrk(2) = sizik * ttrk(2) * rr1
                  ttrk(3) = sizik * ttrk(3) * rr1
c
c     scale the interaction based on its group membership
c
                  if (use_group) then
                     e = fgrp * e
                     frcx = fgrp * frcx
                     frcy = fgrp * frcy
                     frcz = fgrp * frcz
                     do j = 1, 3
                        ttri(j) = fgrp * ttri(j)
                        ttrk(j) = fgrp * ttrk(j)
                     end do
                  end if
c
c     set lambda scaling for decoupling or annihilation
c
                  mutik = .false.
                  if (muti .or. mutk) then
                     if (vcouple .eq. 1) then
                        mutik = .true.
                     else if (.not.muti .or. .not.mutk) then
                        mutik = .true.
                     end if
                  end if
c
c     get energy and force via soft core lambda scaling
c
                  if (mutik) then
                     term = 1.0d0 - vlambda + r2
                     soft = vlambda * r / sqrt(term)
                     dsoft = soft * (rr1-r/term)
                     dsoft = dsoft * rr1 * e
                     frcx = frcx*soft - dsoft*xr
                     frcy = frcy*soft - dsoft*yr
                     frcz = frcz*soft - dsoft*zr
                     do j = 1, 3
                        ttri(j) = ttri(j) * soft
                        ttrk(j) = ttrk(j) * soft
                     end do
                     e = soft * e
                  end if
c
c
c     use energy switching if near the cutoff distance
c
                  if(longrange.or.fullrange) then
                    if (r2 .gt. cut2) then
                       r3 = r2 * r
                       r4 = r2 * r2
                       r5 = r2 * r3
                       taper = c5*r5 + c4*r4 + c3*r3
     &                            + c2*r2 + c1*r + c0
                       dtaper = 5.0d0*c5*r4 + 4.0d0*c4*r3
     &                             + 3.0d0*c3*r2 + 2.0d0*c2*r + c1
                       dtaper = dtaper * e * rr1
                       e = e * taper
                       frcx = frcx*taper - dtaper*xr
                       frcy = frcy*taper - dtaper*yr
                       frcz = frcz*taper - dtaper*zr
                       do j = 1, 3
                          ttri(j) = ttri(j) * taper
                          ttrk(j) = ttrk(j) * taper
                       end do
                    end if
                  end if
c
c     use energy switching if close the cutoff distance (at short range)
c
                  if(shortrange .or. longrange)
     &               call switch_respa(r,repshortcut,shortheal,s,ds)

                  if(shortrange) then
                     facts =          s
                     factds =        -ds
                  else if(longrange) then
                     facts  = 1.0d0 - s
                     factds =       ds
                  else
                     facts  = 1.0d0
                     factds = 0.0d0
                  endif

                  frcx = frcx*facts + factds*xr
                  frcy = frcy*facts + factds*yr
                  frcz = frcz*facts + factds*zr
                  do j = 1, 3
                     ttri(j) = ttri(j) * facts
                     ttrk(j) = ttrk(j) * facts
                  end do
                  e  = e  * facts
c
c     increment the overall Pauli repulsion energy component
c
                  er = er + e
c
c     increment force-based gradient and torque on first site
c
                  der(1,i) = der(1,i) + frcx
                  der(2,i) = der(2,i) + frcy
                  der(3,i) = der(3,i) + frcz
                  ter(1,i) = ter(1,i) + ttri(1)
                  ter(2,i) = ter(2,i) + ttri(2)
                  ter(3,i) = ter(3,i) + ttri(3)
c
c     increment force-based gradient and torque on second site
c
                  der(1,kbis) = der(1,kbis) - frcx
                  der(2,kbis) = der(2,kbis) - frcy
                  der(3,kbis) = der(3,kbis) - frcz
                  ter(1,kbis) = ter(1,kbis) + ttrk(1)
                  ter(2,kbis) = ter(2,kbis) + ttrk(2)
                  ter(3,kbis) = ter(3,kbis) + ttrk(3)
c
c     increment the virial due to pairwise Cartesian forces
c
                  vxx = -xr * frcx
                  vxy = -0.5d0 * (yr*frcx+xr*frcy)
                  vxz = -0.5d0 * (zr*frcx+xr*frcz)
                  vyy = -yr * frcy
                  vyz = -0.5d0 * (zr*frcy+yr*frcz)
                  vzz = -zr * frcz
                  vir(1,1) = vir(1,1) + vxx
                  vir(2,1) = vir(2,1) + vxy
                  vir(3,1) = vir(3,1) + vxz
                  vir(1,2) = vir(1,2) + vxy
                  vir(2,2) = vir(2,2) + vyy
                  vir(3,2) = vir(3,2) + vyz
                  vir(1,3) = vir(1,3) + vxz
                  vir(2,3) = vir(2,3) + vyz
                  vir(3,3) = vir(3,3) + vzz
               end if
            end if
         end do
c
c     reset exclusion coefficients for connected atoms
c
         do j = 1, n12(iglob)
            rscale(i12(j,iglob)) = 1.0d0
         end do
         do j = 1, n13(iglob)
            rscale(i13(j,iglob)) = 1.0d0
         end do
         do j = 1, n14(iglob)
            rscale(i14(j,iglob)) = 1.0d0
         end do
         do j = 1, n15(iglob)
            rscale(i15(j,iglob)) = 1.0d0
         end do
      end do
c
c
      do ii = 1, npolelocnl
         iipole = poleglobnl(ii)
         iglob = ipole(iipole)
         i = loc(iglob)
         call torque (iipole,ter(1,i),fix,fiy,fiz,der)
         iz = zaxis(iipole)
         ix = xaxis(iipole)
         iy = abs(yaxis(iipole))
         if (iz .eq. 0)  iz = iglob
         if (ix .eq. 0)  ix = iglob
         if (iy .eq. 0)  iy = iglob
         xiz = x(iz) - x(iglob)
         yiz = y(iz) - y(iglob)
         ziz = z(iz) - z(iglob)
         xix = x(ix) - x(iglob)
         yix = y(ix) - y(iglob)
         zix = z(ix) - z(iglob)
         xiy = x(iy) - x(iglob)
         yiy = y(iy) - y(iglob)
         ziy = z(iy) - z(iglob)
         vxx = xix*fix(1) + xiy*fiy(1) + xiz*fiz(1)
         vxy = 0.5d0 * (yix*fix(1) + yiy*fiy(1) + yiz*fiz(1)
     &                    + xix*fix(2) + xiy*fiy(2) + xiz*fiz(2))
         vxz = 0.5d0 * (zix*fix(1) + ziy*fiy(1) + ziz*fiz(1)
     &                    + xix*fix(3) + xiy*fiy(3) + xiz*fiz(3)) 
         vyy = yix*fix(2) + yiy*fiy(2) + yiz*fiz(2)
         vyz = 0.5d0 * (zix*fix(2) + ziy*fiy(2) + ziz*fiz(2)
     &                    + yix*fix(3) + yiy*fiy(3) + yiz*fiz(3))
         vzz = zix*fix(3) + ziy*fiy(3) + ziz*fiz(3)
         vir(1,1) = vir(1,1) + vxx
         vir(2,1) = vir(2,1) + vxy
         vir(3,1) = vir(3,1) + vxz
         vir(1,2) = vir(1,2) + vxy
         vir(2,2) = vir(2,2) + vyy
         vir(3,2) = vir(3,2) + vyz
         vir(1,3) = vir(1,3) + vxz
         vir(2,3) = vir(2,3) + vyz
         vir(3,3) = vir(3,3) + vzz
      end do
c
c     perform deallocation of some local arrays
c
      deallocate (rscale)
      deallocate (ter)
      return
      end
