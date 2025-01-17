c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ###################################################################################
c     ##                                                                               ##
c     ##  subroutine baoabrespa1  --  baoab r-RESPA1 Langevin molecular dynamics step  ##
c     ##                                                                               ##
c     ###################################################################################
c
c
c     "baoabrespa1" performs a single multiple time step molecular dynamics
c     step using the reversible reference system propagation algorithm
c     (r-RESPA) via a BAOAB core with the potential split into fast-
c     intermediate and slow-evolving portions
c
c     literature references:
c
c     Pushing the Limits of Multiple-Time-Step Strategies 
c     wfor Polarizable Point Dipole Molecular Dynamics
c     L Lagardère, F Aviat, JP Piquemal
c     The journal of physical chemistry letters 10, 2593-2599
c
c     Efficient molecular dynamics using geodesic integration 
c     and solvent-solute splitting B. Leimkuhler and C. Matthews,
c     Proceedings of the Royal Society A, 472: 20160138, 2016
c
c     D. D. Humphreys, R. A. Friesner and B. J. Berne, "A Multiple-
c     Time-Step Molecular Dynamics Algorithm for Macromolecules",
c     Journal of Physical Chemistry, 98, 6885-6892 (1994)
c
c     X. Qian and T. Schlick, "Efficient Multiple-Time-Step Integrators
c     with Distance-Based Force Splitting for Particle-Mesh-Ewald
c     Molecular Dynamics Simulations", Journal of Chemical Physics,
c     115, 4019-4029 (2001)
c
c     Ruhong Zhou, Edward Harder, Huafeng Xu and B. J. Berne, 
c     "Efficient multiple time step method for use with Ewald and 
c     particle mesh Ewald for large biomolecular systems", 
c     J. Chem. Phys. 115, 2348-2358 (2001)
c
c
      subroutine baoabrespa1(istep,dt)
      use atmtyp
      use atoms
      use cutoff
      use domdec
      use freeze
      use moldyn
      use timestat
      use units
      use usage
      use virial
      use mpi
      implicit none
      integer i,j,iglob
      integer istep
      real*8 dt,dt_2
      real*8 dta,dta_2,dta2
      real*8 epot,etot
      real*8 eksum
      real*8 temp,pres
      real*8 ealt
      real*8 ekin(3,3)
      real*8 stress(3,3)
      real*8 viralt(3,3)
      real*8 time0,time1
      real*8, allocatable :: derivs(:,:)
      time0 = mpi_wtime()
c
c     set some time values for the dynamics integration
c
      dt_2 = 0.5d0 * dt
      dta = dt / dinter
      dta_2 = 0.5d0 * dta
c      
      dta2 = dta / dshort
c
c     store the current atom positions, then find half-step
c     velocities via BAOAB recursion
c
      do i = 1, nloc
         iglob = glob(i)
         if (use(iglob)) then
            do j = 1, 3
               v(j,iglob) = v(j,iglob) + a(j,iglob)*dt_2
            end do
         end if
      end do
c
      if (use_rattle) call rattle2(dt_2)
      time1 = mpi_wtime()
      timeinte = timeinte + time1-time0 
c
c     find intermediate-evolving velocities and positions via BAOAB recursion
c
      call baoabrespaint1(ealt,viralt,dta,dta2,istep)
c
c     Reassign the particules that have changed of domain
c
c     -> reciprocal space
c
      time0 = mpi_wtime()
      call reassignpme(.false.)
      time1 = mpi_wtime()
      timereneig = timereneig + time1 - time0
c
c     communicate positions
c
      time0 = mpi_wtime()
      call commposrec
      time1 = mpi_wtime()
      timecommpos = timecommpos + time1 - time0
c
      time0 = mpi_wtime()
      call reinitnl(istep)
      time1 = mpi_wtime()
      timeinte = timeinte + time1-time0
c
      time0 = mpi_wtime()
      call mechanicsteprespa1(istep,2)
      time1 = mpi_wtime()
      timeparam = timeparam + time1 - time0

      time0 = mpi_wtime()
      call allocsteprespa(.false.)
      time1 = mpi_wtime()
      timeinte = timeinte + time1 - time0
c
c     rebuild the neighbor lists
c
      time0 = mpi_wtime()
      if (use_list) call nblist(istep)
      time1 = mpi_wtime()
      timenl = timenl + time1 - time0
c
      time0 = mpi_wtime()
      allocate (derivs(3,nbloc))
      derivs = 0d0
      time1 = mpi_wtime()
      timeinte = timeinte + time1-time0
c
c     get the slow-evolving potential energy and atomic forces
c
      time0 = mpi_wtime()
      call gradslow1 (epot,derivs)
      time1 = mpi_wtime()
      timegrad = timegrad + time1 - time0
c
c     communicate some forces
c
      time0 = mpi_wtime()
      call commforcesrespa1(derivs,2)
      time1 = mpi_wtime()
      timecommforces = timecommforces + time1-time0
c
c     MPI : get total energy
c
      time0 = mpi_wtime()
      call reduceen(epot)
      time1 = mpi_wtime()
      timered = timered + time1 - time0
c
c     make half-step temperature and pressure corrections
c
      time0 = mpi_wtime()
      call temper2 (temp)
      time1 = mpi_wtime()
      timetp = timetp + time1-time0
c
c     use Newton's second law to get the slow accelerations;
c     find full-step velocities using BAOAB recursion
c
      time0 = mpi_wtime()
      do i = 1, nloc
         iglob = glob(i)
         if (use(iglob)) then
            do j = 1, 3
               a(j,iglob) = -convert * derivs(j,i) / mass(iglob)
               v(j,iglob) = v(j,iglob) + a(j,iglob)*dt_2
            end do
         end if
      end do
c
c     find the constraint-corrected full-step velocities
c
      if (use_rattle)  call rattle2 (dt)
c
c     total potential and virial from sum of fast and slow parts
c
      epot = epot + ealt
      do i = 1, 3
         do j = 1, 3
            vir(j,i) = vir(j,i) + viralt(j,i)
         end do
      end do
      time1 = mpi_wtime()
      timeinte = timeinte + time1-time0
c
c     make full-step temperature and pressure corrections
c
      time0 = mpi_wtime()
      call temper (dt,eksum,ekin,temp)
      call pressure (dt,ekin,pres,stress,istep)
      call pressure2 (epot,temp)
      time1 = mpi_wtime()
      timetp = timetp + time1-time0
c
c     total energy is sum of kinetic and potential energies
c
      time0 = mpi_wtime()
      etot = eksum + epot
c
c     compute statistics and save trajectory for this step
c
      call mdstat (istep,dt,etot,epot,eksum,temp,pres)
      call mdsave (istep,dt,epot,derivs)
      call mdrest (istep)
      time1 = mpi_wtime()
      timeinte = timeinte + time1-time0
c
c     perform deallocation of some local arrays
c
      deallocate (derivs)
      return
      end
c
c     subroutine baoabrespaint1 : 
c     find intermediate-evolving velocities and positions via BAOAB recursion
c
      subroutine baoabrespaint1(ealt,viralt,dta,dta2,istep)
      use atmtyp
      use atoms
      use cutoff
      use deriv
      use domdec
      use freeze
      use moldyn
      use timestat
      use units
      use usage
      use virial
      use mpi
      implicit none
      integer i,j,k,iglob
      integer istep
      real*8 dta,dta_2,dta2
      real*8 ealt,ealt2
      real*8 time0,time1
      real*8, allocatable :: derivs(:,:)
      real*8 viralt(3,3),viralt2(3,3)
      time0 = mpi_wtime()
      dta_2 = 0.5d0 * dta
c
c     initialize virial from fast-evolving potential energy terms
c
      do i = 1, 3
         do j = 1, 3
            viralt(j,i) = 0.0d0
         end do
      end do
      time1 = mpi_wtime()
      timeinte = timeinte + time1-time0 

      do k = 1, nalt
        time0 = mpi_wtime()
        do i = 1, nloc
           iglob = glob(i)
           if (use(iglob)) then
              do j = 1, 3
                 v(j,iglob) = v(j,iglob) + aalt(j,iglob)*dta_2
              end do
           end if
        end do
c
        if (use_rattle)  call rattle2 (dta_2)
        time1 = mpi_wtime()
        timeinte = timeinte + time1-time0 
c
c
c     find fast-evolving velocities and positions via BAOAB recursion
c
        call baoabrespafast1(ealt2,viralt2,dta2,istep)
c
        time0 = mpi_wtime()
        call mechanicsteprespa1(-1,1)
        time1 = mpi_wtime()
        timeparam = timeparam + time1 - time0

        time0 = mpi_wtime()
        call allocsteprespa(.false.)
c
        allocate (derivs(3,nbloc))
        derivs = 0d0

        if (allocated(desave)) deallocate (desave)
        allocate (desave(3,nbloc))
        time1 = mpi_wtime()
        timeinte = timeinte + time1 - time0
c
c     get the fast-evolving potential energy and atomic forces
c
        time0 = mpi_wtime()
        call gradint1(ealt,derivs)
        time1 = mpi_wtime()
        timegrad = timegrad + time1 - time0
c
c      communicate forces
c
        time0 = mpi_wtime()
        call commforcesrespa1(derivs,1)
        time1 = mpi_wtime()
        timecommforces = timecommforces + time1-time0
c
c      MPI : get total energy
c
        time0 = mpi_wtime()
        call reduceen(ealt)
        time1 = mpi_wtime()
        timered = timered + time1 - time0
c
c     use Newton's second law to get fast-evolving accelerations;
c     update fast-evolving velocities using the BAOAB recursion
c
        time0 = mpi_wtime()
        do i = 1, nloc
           iglob = glob(i)
           if (use(iglob)) then
              do j = 1, 3
                 aalt(j,iglob) = -convert *
     $              derivs(j,i) / mass(iglob)
                 v(j,iglob) = v(j,iglob) + aalt(j,iglob)*dta_2
              end do
           end if
        end do
        deallocate (derivs)
        if (use_rattle)  call rattle2 (dta)
c
c     increment average virial from fast-evolving potential terms
c
        ealt = ealt + ealt2
        do i = 1, 3
           do j = 1, 3
              viralt(j,i) = viralt(j,i) + (viralt2(j,i) 
     $         + vir(j,i))/dinter
           end do
        end do
        time1 = mpi_wtime()
        timeinte = timeinte + time1-time0
      end do
      return
      end
c
c     subroutine baoabrespafast1 : 
c     find fast-evolving velocities and positions via BAOAB recursion
c
      subroutine baoabrespafast1(ealt,viralt,dta,istep)
      use atmtyp
      use atoms
      use bath
      use cutoff
      use domdec
      use freeze
      use langevin
      use moldyn
      use timestat
      use units
      use usage
      use virial
      use mpi
      implicit none
      integer i,j,k,iglob
      integer istep
      real*8 dta,dta_2
      real*8 ealt
      real*8 time0,time1
      real*8, allocatable :: derivs(:,:)
      real*8 viralt(3,3)
      real*8 a1,a2,normal
      time0 = mpi_wtime()
c
c     set time values and coefficients for BAOAB integration
c
      a1 = exp(-gamma*dta)
      a2 = sqrt((1-a1**2)*boltzmann*kelvin)

      dta_2 = 0.5d0 * dta
c
c     initialize virial from fast-evolving potential energy terms
c
      do i = 1, 3
         do j = 1, 3
            viralt(j,i) = 0.0d0
         end do
      end do
      time1 = mpi_wtime()
      timeinte = timeinte + time1-time0 

      do k = 1, nalt2
        time0 = mpi_wtime()
        do i = 1, nloc
           iglob = glob(i)
           if (use(iglob)) then
              do j = 1, 3
                 v(j,iglob) = v(j,iglob) + aalt2(j,iglob)*dta_2
              end do
           end if
        end do
c
        if (use_rattle)  call rattle2 (dta_2)
c
        do i = 1, nloc
          iglob = glob(i)
          if (use(iglob)) then
            xold(iglob) = x(iglob)
            yold(iglob) = y(iglob)
            zold(iglob) = z(iglob)
            x(iglob) = x(iglob) + v(1,iglob)*dta_2
            y(iglob) = y(iglob) + v(2,iglob)*dta_2
            z(iglob) = z(iglob) + v(3,iglob)*dta_2
          end if
        end do
c
        if (use_rattle) call rattle(dta_2)
        if (use_rattle) call rattle2(dta_2)
c
c     compute random part
c
        deallocate (Rn)
        allocate (Rn(3,nloc))
        do i = 1, nloc
          do j = 1, 3
            Rn(j,i) = normal()
          end do
        end do
        do i = 1, nloc
           iglob = glob(i)
           if (use(iglob)) then
              do j = 1, 3
                 v(j,iglob) = a1*v(j,iglob) + 
     $              a2*Rn(j,i)/sqrt(mass(iglob))
              end do
           end if
        end do
c
        if (use_rattle) call rattle2(dta)
c
        do i = 1, nloc
          iglob = glob(i)
          if (use(iglob)) then
            xold(iglob) = x(iglob)
            yold(iglob) = y(iglob)
            zold(iglob) = z(iglob)
            x(iglob) = x(iglob) + v(1,iglob)*dta_2
            y(iglob) = y(iglob) + v(2,iglob)*dta_2
            z(iglob) = z(iglob) + v(3,iglob)*dta_2
          end if
        end do
        time1 = mpi_wtime()
        timeinte = timeinte + time1-time0 
c
c       Reassign the particules that have changed of domain
c
c       -> real space
c
        time0 = mpi_wtime()
        call reassignrespa(k,nalt2)
        time1 = mpi_wtime()
        timereneig = timereneig + time1 - time0
c
c       communicate positions
c
        time0 = mpi_wtime()
        call commposrespa(k.ne.nalt2)
        time1 = mpi_wtime()
        timecommpos = timecommpos + time1 - time0
c
        time0 = mpi_wtime()
        allocate (derivs(3,nbloc))
        derivs = 0d0
        time1 = mpi_wtime()
        timeinte = timeinte + time1-time0
c
        time0 = mpi_wtime()
        if (k.eq.nalt2) call mechanicsteprespa1(-1,0)
        time1 = mpi_wtime()
        timeparam = timeparam + time1 - time0
        time0 = mpi_wtime()
        if (k.eq.nalt2) call allocsteprespa(.true.)
        time1 = mpi_wtime()
        timeinte = timeinte + time1 - time0
c
c     get the fast-evolving potential energy and atomic forces
c
        time0 = mpi_wtime()
        call gradfast1(ealt,derivs)
        time1 = mpi_wtime()
        timegrad = timegrad + time1 - time0
c
c       communicate forces
c
        time0 = mpi_wtime()
        call commforcesrespa1(derivs,0)
        time1 = mpi_wtime()
        timecommforces = timecommforces + time1-time0
c
c       MPI : get total energy
c
        time0 = mpi_wtime()
        call reduceen(ealt)
        time1 = mpi_wtime()
        timered = timered + time1 - time0
c
c     use Newton's second law to get fast-evolving accelerations;
c     update fast-evolving velocities using the BAOAB recursion
c
        time0 = mpi_wtime()
        do i = 1, nloc
           iglob = glob(i)
           if (use(iglob)) then
              do j = 1, 3
                 aalt2(j,iglob) = -convert *
     $              derivs(j,i) / mass(iglob)
                 v(j,iglob) = v(j,iglob) + aalt2(j,iglob)*dta_2
              end do
           end if
        end do
        deallocate (derivs)
c
        if (use_rattle)  call rattle2 (dta_2)
c
c     increment average virial from fast-evolving potential terms
c
        do i = 1, 3
           do j = 1, 3
              viralt(j,i) = viralt(j,i) + vir(j,i)/dshort
           end do
        end do
        time1 = mpi_wtime()
        timeinte = timeinte + time1 - time0
      end do
      return
      end
