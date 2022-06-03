
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
#include "tinker_precision.h"
      subroutine baoabrespa1(istep,dt)
      use atmtyp
      use atomsMirror
      use cutoff
      use domdec
      use deriv
      use energi
      use freeze
      use inform
      use mdstuf1
      use moldyn
      use mpi
      use timestat
      use units
      use usage
      use utilgpu
      use utils
      use virial
      implicit none
      integer i,j,iglob
      integer istep
      real(r_p) dt,dt_2
      real(r_p) dta,dta_2,dta2
      real*8    time0,time1
c
c     set some time values for the dynamics integration
c
      dt_2  = 0.5_re_p * dt
      dta   = dt / dinter
      dta_2 = 0.5_re_p * dta
c      
      dta2  = dta / dshort
c
c     store the current atom positions, then find half-step
c     velocities via BAOAB recursion
c
      call integrate_vel(a,dt_2)
c
      if (use_rattle) call rattle2(dt_2)
c
c     find intermediate-evolving velocities and positions via BAOAB recursion
c
      call baoabrespaint1(ealt,viralt,dta,dta2)
c
c     Reassign the particules that have changed of domain
c
c     -> real space
c      call reassignrespa(.false.,nalt,nalt)
c
c     -> reciprocal space
      call reassignpme(.false.)
c
c     communicate positions
c
c     call commposrespa(.false.)
      call commposrec
c
c
      call reinitnl(istep)
c
      call mechanicsteprespa1(istep,2)

      call allocsteprespa(.false.)
c
c     rebuild the neighbor lists
c
      if (use_list) call nblist(istep)
c
      if (.not.ftot_l) then
         call prmem_requestm(derivs,3,nbloc,async=.true.)
         call set_to_zero1m(derivs,3*nbloc,rec_queue)
      end if
c
c     get the slow-evolving potential energy and atomic forces
c
      call gradslow (epot,derivs)
c
c     communicate some forces
c
      call comm_forces( derivs,cNBond )
c
c     MPI : get total energy
c
      call reduceen(epot)
c
c     make half-step temperature and pressure corrections
c
c     call temper2 (temp)
c     call pressure2 (epot,temp)
c
c     use Newton's second law to get the slow accelerations;
c     find full-step velocities using BAOAB recursion
c
      call integrate_vel(derivs,a,dt_2)
c
c     Debug print information
c
      if (deb_Energy) call info_energy(rank)
      if (deb_Force)  call info_forces(cNBond)
      if (deb_Atom)   call info_minmax_pva
c
c     find the constraint-corrected full-step velocities
c
      if (use_rattle)  call rattle2 (dt)
c
c     total potential and virial from sum of fast and slow parts
c
      if (calc_e.or.use_virial) then
!$acc serial default(present) present(epot,ealt) async
         epot = epot + ealt
         do i = 1,3; do j = 1,3
            vir(j,i) = vir(j,i) + viralt(j,i)
         end do; end do
!$acc end serial
         call chk_energy_fluct(epot,ealt,abort)
      end if
c
c     make full-step temperature and pressure corrections
c
      call temper   (dt,eksum,ekin,temp)
      call pressure (dt,ekin,pres,stress,istep)
      call pressure2 (epot,temp)
c
c     total energy is sum of kinetic and potential energies
c
      if (calc_e) then
!$acc serial present(etot,eksum,epot) async
         etot = eksum + epot
!$acc end serial
      end if

      ! Fatal Instructions
      if(abort)       call emergency_save
      if(abort)       call fatal
c
c     compute statistics and save trajectory for this step
c
      call mdsave (istep,dt,epot)
      call mdrestgpu (istep)
      call mdstat (istep,dt,etot,epot,eksum,temp,pres)
      end
c
c     subroutine baoabrespaint1 : 
c     find intermediate-evolving velocities and positions via BAOAB recursion
c
      subroutine baoabrespaint1(ealt,viralt,dta,dta2)
      use atmtyp
      use atomsMirror
      use cutoff
      use deriv
      use domdec
      use deriv
      use energi
      use freeze
      use inform
      use mdstuf1 ,only: derivs,ealt2,viralt2
      use moldyn
      use timestat
      use units
      use usage
      use utils
      use utilgpu
      use virial
      use mpi
      implicit none
      integer i,j,k,iglob
      real(r_p) dta,dta_2,dta2
      real(r_p) ealt
      real(r_p) viralt(3,3)
      real*8 time0,time1

      dta_2 = 0.5_re_p * dta
c
c     initialize virial from fast-evolving potential energy terms
c
      if (use_virial) call zero_virial(viralt)

      do stepint = 1, nalt
         call integrate_vel(aalt,dta_2)
c
         if (use_rattle)  call rattle2 (dta_2)
c
c     find fast-evolving velocities and positions via BAOAB recursion
c
         call baoabrespafast1(ealt2,viralt2,dta2)
c
c       Reassign the particules that have changed of domain
c
c       -> real space
c       call reassignrespa(.false.,nalt,nalt)
c
c      communicate positions
c
c        call commposshort(.false.)
c
         call mechanicsteprespa1(-1,1)
         call allocsteprespa(.false.)
c
         if (.not.ftot_l) then
            call prmem_requestm(derivs,3,nbloc,async=.true.)
            call set_to_zero1m (derivs,3*nbloc,rec_queue)
         end if
c
c     get the fast-evolving potential energy and atomic forces
c
         call gradint(ealt,derivs)
c
c     communicate forces
c
         call comm_forces( derivs,cSNBond )
c
c     MPI : get total energy
c
         call reduceen(ealt)
c
c     Debug print information
c
         if (deb_Energy) call info_energy(rank)
         if (deb_Force)  call info_forces(cSNBond)
         if (deb_Atom)   call info_minmax_pva
         if (abort)      call emergency_save
         if (abort)      call fatal
c
c     use Newton's second law to get fast-evolving accelerations;
c     update fast-evolving velocities using the BAOAB recursion
c
         call integrate_vel(derivs,aalt,dta_2)

         if (use_rattle)  call rattle2 (dta)
c
c     increment average virial from fast-evolving potential terms
c
         if (calc_e.or.use_virial) then
!$acc serial async default(present) present(ealt,ealt2)
            ealt = ealt + ealt2
            do i = 1,3; do j = 1,3
            viralt(j,i) = viralt(j,i)+ ( viralt2(j,i)+vir(j,i) )/dinter
            end do; end do
!$acc end serial
         end if
      end do
      end
c
c     subroutine baoabrespafast1 : 
c     find fast-evolving velocities and positions via BAOAB recursion
c
      subroutine baoabrespafast1(ealt,viralt,dta)
      use atmtyp
      use atomsMirror
      use bath
      use cutoff
      use domdec
      use deriv
      use energi
      use freeze
      use inform
      use langevin
      use mdstuf1  ,only: derivs
      use moldyn
      use random_mod
      use timestat
      use units
      use utils
      use utilgpu
      use usage
      use virial
      use mpi
      implicit none
      integer i,j,k,iglob
      real(r_p) dta,dta_2
      real(8) time0,time1
      real(r_p) a1,a2
      real(r_p) ealt,viralt(3,3)
c
c     set time values and coefficients for BAOAB integration
c
      a1 = exp(-gamma*dta)
      a2 = sqrt((1-a1**2)*boltzmann*kelvin)
      dta_2 = 0.5_re_p * dta
c
c     initialize virial from fast-evolving potential energy terms
c
      if (use_virial) call zero_virial(viralt)

      do stepfast = 1, nalt2
         call integrate_vel(aalt2,dta_2)
c
         if (use_rattle) then
            call rattle2 (dta_2)
            call save_atoms_pos
         end if
c
         call integrate_pos(dta_2)
c
         if (use_rattle) then
            call rattle(dta_2)
            call rattle2(dta_2) !TODO Ask L about this call
         end if
c
c     compute random part
c
         call prmem_request(Rn,3,nloc+1,async=.true.)
#ifdef _OPENACC
         call normalgpu(Rn(1,1),3*nloc)
#endif
         if (host_rand_platform) then
            call normalvec(Rn,3*nloc)
!$acc update device(Rn) async
         end if

!$acc parallel loop collapse(2) async default(present)
         do i = 1, nloc; do j = 1, 3
            iglob = glob(i)
            if (use(iglob)) then
               v(j,iglob) = a1*v(j,iglob) + 
     &         a2*real(Rn(j,i),r_p)/sqrt(mass(iglob))
            end if
         end do; end do
c
         if (use_rattle) then
            call rattle2(dta)
            call save_atoms_pos
         end if
c
         call integrate_pos(dta_2)
c
c        Reassign the particules that have changed of domain
c        -> real space
         call reassignrespa(stepfast,nalt2)
c
c        communicate positions
c
         call commposrespa(stepfast.ne.nalt2)
c
         if (.not.ftot_l) then
            call prmem_requestm(derivs,3,nbloc,async=.true.)
            call set_to_zero1m (derivs,3*nbloc,rec_queue)
         end if
c
         if (stepfast.eq.nalt2) call mechanicsteprespa1(-1,0)
         if (stepfast.eq.nalt2) call allocsteprespa(.true.)
c
c     get the fast-evolving potential energy and atomic forces
c
        call gradfast(ealt,derivs)
c
c       communicate forces
c
        call comm_forces( derivs,cBond )
c
c       MPI : get total energy
c
        call reduceen(ealt)
c
c     aMD/GaMD contributions
c
        call aMD (derivs,ealt)
c
c     Debug print information
c
        if (deb_Energy) call info_energy(rank)
        if (deb_Force)  call info_forces(cBond)
        if (deb_Atom)   call info_minmax_pva
        if (abort)      call emergency_save
        if( abort)      call fatal
c
c     use Newton's second law to get fast-evolving accelerations;
c     update fast-evolving velocities using the BAOAB recursion
c
        call integrate_vel(derivs,aalt2,dta_2)
c
        if (use_rattle)  call rattle2 (dta_2)
c
c     increment average virial from fast-evolving potential terms
c
        if (use_virial) then
!$acc parallel loop collapse(2) async default(present)
           do i = 1,3; do j = 1,3
             viralt(j,i) = viralt(j,i) + vir(j,i)/dshort
           end do; end do
        end if
      end do
      end
