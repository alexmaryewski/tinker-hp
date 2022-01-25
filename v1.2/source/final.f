c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine final  --  final actions before program exit  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "final" performs any final program actions, prints a status
c     message, and then pauses if necessary to avoid closing the
c     execution window
c
c
      subroutine final
      use analyz
      use angle
      use atmlst
      use atmtyp
      use atoms
      use charge
      use couple
      use dcdmod
      use deriv
      use disp
      use divcon
      use domdec
      use fft
      use freeze
      use group
      use inform
      use iounit
      use kopbnd
      use langevin
      use moldyn
      use molcul
      use mpole
      use neigh
      use pme
      use polar
      use polpot
      use uprior
      use vdw
      implicit none
c
c     check all modules, then shared memory segments
c
c     module "analyz"
c 
      if (allocated(aesum)) deallocate (aesum)
      if (allocated(aem)) deallocate (aem)
      if (allocated(aep)) deallocate (aep)
      if (allocated(aev)) deallocate (aev)
      if (allocated(aeb)) deallocate (aeb)
      if (allocated(aea)) deallocate (aea)
      if (allocated(aeba)) deallocate (aeba)
      if (allocated(aub)) deallocate (aub)
      if (allocated(aeaa)) deallocate (aeaa)
      if (allocated(aeopb)) deallocate (aeopb)
      if (allocated(aeopd)) deallocate (aeopd)
      if (allocated(aeid)) deallocate (aeid)
      if (allocated(aeit)) deallocate (aeit)
      if (allocated(aet)) deallocate (aet)
      if (allocated(aept)) deallocate (aept)
      if (allocated(aebt)) deallocate (aebt)
      if (allocated(aett)) deallocate (aett)
      if (allocated(aeg)) deallocate (aeg)
      if (allocated(aex)) deallocate (aex)
      if (allocated(aec)) deallocate (aec)
      if (allocated(aeat)) deallocate (aeat)
      if (allocated(aer)) deallocate (aer)
      if (allocated(aedsp)) deallocate (aedsp)
      if (allocated(aect)) deallocate (aect)
c
c     module "angle"
c
      if (allocated(angleloc)) deallocate (angleloc)
c
c     module "atmlst"
c
      if (allocated(bndglob)) deallocate (bndglob)
      if (allocated(angleglob)) deallocate (angleglob)
      if (allocated(torsglob)) deallocate (torsglob)
      if (allocated(bitorsglob)) deallocate (bitorsglob)
      if (allocated(strbndglob)) deallocate (strbndglob)
      if (allocated(ureyglob)) deallocate (ureyglob)
      if (allocated(angangglob)) deallocate (angangglob)
      if (allocated(opbendglob)) deallocate (opbendglob)
      if (allocated(opdistglob)) deallocate (opdistglob)
      if (allocated(impropglob)) deallocate (impropglob)
      if (allocated(imptorglob)) deallocate (imptorglob)
      if (allocated(pitorsglob)) deallocate (pitorsglob)
      if (allocated(strtorglob)) deallocate (strtorglob)
      if (allocated(angtorglob)) deallocate (angtorglob)
      if (allocated(tortorglob)) deallocate (tortorglob)
      if (allocated(vdwglob)) deallocate (vdwglob)
      if (allocated(poleglob)) deallocate (poleglob)
      if (allocated(polerecglob)) deallocate (polerecglob)
      if (allocated(dispglob)) deallocate (dispglob)
      if (allocated(disprecglob)) deallocate (disprecglob)
      if (allocated(chgglob)) deallocate (chgglob)
      if (allocated(chgrecglob)) deallocate (chgrecglob)
      if (allocated(molculeglob)) deallocate (molculeglob)
      if (allocated(npfixglob)) deallocate (npfixglob)
      if (allocated(ndfixglob)) deallocate (ndfixglob)
      if (allocated(nafixglob)) deallocate (nafixglob)
      if (allocated(ntfixglob)) deallocate (ntfixglob)
      if (allocated(ngfixglob)) deallocate (ngfixglob)
      if (allocated(nchirglob)) deallocate (nchirglob)
      if (allocated(ratglob)) deallocate (ratglob)
      if (allocated(chgglobnl)) deallocate (chgglobnl)
      if (allocated(vdwglobnl)) deallocate (vdwglobnl)
      if (allocated(poleglobnl)) deallocate (poleglobnl)
      if (allocated(dispglobnl)) deallocate (dispglobnl)
c
c     module "atmtyp"
c
      if (allocated(tag)) deallocate (tag)
      if (allocated(name)) deallocate (name)
c
c     module "atoms"
c
      if (allocated(type)) deallocate (type)
      if (allocated(x)) deallocate (x)
      if (allocated(y)) deallocate (y)
      if (allocated(z)) deallocate (z)
      if (allocated(xold)) deallocate (xold)
      if (allocated(yold)) deallocate (yold)
      if (allocated(zold)) deallocate (zold)
c
c     module "charge"
c
      if (allocated(chgloc)) deallocate (chgloc)
      if (allocated(chglocnl)) deallocate (chglocnl)
      if (allocated(chgrecloc)) deallocate (chgrecloc)
c
c     module "couple"
c
      if (allocated(n12)) deallocate (n12)
      if (allocated(i12)) deallocate (i12)
c
c     module "dcdmod"
c
      if (allocated(titlesdcd)) deallocate (titlesdcd)
c
c     module "deriv"
c
      if (allocated(desum)) deallocate (desum)
      if (allocated(deb)) deallocate (deb)
      if (allocated(dea)) deallocate (dea)
      if (allocated(deba)) deallocate (deba)
      if (allocated(deub)) deallocate (deub)
      if (allocated(deaa)) deallocate (deaa)
      if (allocated(deopb)) deallocate (deopb)
      if (allocated(deopd)) deallocate (deopd)
      if (allocated(deid)) deallocate (deid)
      if (allocated(det)) deallocate (det)
      if (allocated(dept)) deallocate (dept)
      if (allocated(deit)) deallocate (deit)
      if (allocated(deat)) deallocate (deat)
      if (allocated(debt)) deallocate (debt)
      if (allocated(dett)) deallocate (dett)
      if (allocated(dev)) deallocate (dev)
      if (allocated(dec)) deallocate (dec)
      if (allocated(dem)) deallocate (dem)
      if (allocated(dep)) deallocate (dep)
      if (allocated(deg)) deallocate (deg)
      if (allocated(der)) deallocate (der)
      if (allocated(dect)) deallocate (dect)
      if (allocated(dedsp)) deallocate (dedsp)
      if (allocated(dedsprec)) deallocate (dedsprec)
      if (allocated(decrec)) deallocate (decrec)
      if (allocated(demrec)) deallocate (demrec)
      if (allocated(deprec)) deallocate (deprec)
      if (allocated(debond)) deallocate (debond)
      if (allocated(desave)) deallocate (desave)
      if (allocated(desmd)) deallocate (desmd)
c
c     module "disp"
c
      if (allocated(displocnl)) deallocate (displocnl)
      if (allocated(disprecloc)) deallocate (disprecloc)
c
c     module "divcon"
c
      if (allocated(grplst)) deallocate (grplst)
      if (allocated(atmofst)) deallocate (atmofst)
      if (allocated(kofst)) deallocate (kofst)
      if (allocated(npergrp)) deallocate (npergrp)
      if (allocated(knblist)) deallocate (knblist)
      if (allocated(point)) deallocate (point)
      if (allocated(klst)) deallocate (klst)
      if (allocated(zmat)) deallocate (zmat)
      if (allocated(means)) deallocate (means)
      if (allocated(oldmeans)) deallocate (oldmeans)
      if (allocated(ytab)) deallocate (ytab)
c
c     module "domdec"
c
      if (allocated(domlen)) deallocate (domlen)
      if (allocated(domlenrec)) deallocate (domlenrec)
      if (allocated(domlenpole)) deallocate (domlenpole)
      if (allocated(domlenpolerec)) deallocate (domlenpolerec)
      if (allocated(p_recep1)) deallocate (p_recep1)
      if (allocated(p_recep2)) deallocate (p_recep2)
      if (allocated(p_send1)) deallocate (p_send1)
      if (allocated(p_send2)) deallocate (p_send2)
      if (allocated(p_recepshort1)) deallocate (p_recepshort1)
      if (allocated(p_recepshort2)) deallocate (p_recepshort2)
      if (allocated(p_sendshort1)) deallocate (p_sendshort1)
      if (allocated(p_sendshort2)) deallocate (p_sendshort2)
      if (allocated(pneig_recep)) deallocate (pneig_recep)
      if (allocated(pneig_send)) deallocate (pneig_send)
      if (allocated(precdir_recep)) deallocate (precdir_recep)
      if (allocated(precdir_send)) deallocate (precdir_send)
      if (allocated(precdir_recep1)) deallocate (precdir_recep1)
      if (allocated(precdir_send1)) deallocate (precdir_send1)
      if (allocated(precdir_recep2)) deallocate (precdir_recep2)
      if (allocated(precdir_send2)) deallocate (precdir_send2)
      if (allocated(pbig_recep)) deallocate (pbig_recep)
      if (allocated(pbig_send)) deallocate (pbig_send)
      if (allocated(pbigshort_recep)) deallocate (pbigshort_recep)
      if (allocated(pbigshort_send)) deallocate (pbigshort_send)
      if (allocated(loc)) deallocate (loc)
      if (allocated(glob)) deallocate (glob)
      if (allocated(locrec)) deallocate (locrec)
      if (allocated(globrec)) deallocate (globrec)
      if (allocated(prec_recep)) deallocate (prec_recep)
      if (allocated(prec_send)) deallocate (prec_send)
      if (allocated(repartrec)) deallocate (repartrec)
      if (allocated(repart)) deallocate (repart)
      if (allocated(bufbeg)) deallocate (bufbeg)
      if (allocated(bufbegpole)) deallocate (bufbegpole)
      if (allocated(bufbegrec)) deallocate (bufbegrec)
      if (allocated(buflen1)) deallocate (buflen1)
      if (allocated(buflen2)) deallocate (buflen2)
      if (allocated(bufbeg1)) deallocate (bufbeg1)
      if (allocated(bufbeg2)) deallocate (bufbeg2)
      if (allocated(buf1)) deallocate (buf1)
      if (allocated(buf2)) deallocate (buf2)
      if (allocated(zbegproc)) deallocate (zbegproc)
      if (allocated(zendproc)) deallocate (zendproc)
      if (allocated(ybegproc)) deallocate (ybegproc)
      if (allocated(yendproc)) deallocate (yendproc)
      if (allocated(xbegproc)) deallocate (xbegproc)
      if (allocated(xendproc)) deallocate (xendproc)
c
c     module "fft"
c
      if (allocated(istart1)) deallocate (istart1)
      if (allocated(iend1)) deallocate (iend1)
      if (allocated(jstart1)) deallocate (jstart1)
      if (allocated(jend1)) deallocate (jend1)
      if (allocated(kstart1)) deallocate (kstart1)
      if (allocated(kend1)) deallocate (kend1)
      if (allocated(isize1)) deallocate (isize1)
      if (allocated(jsize1)) deallocate (jsize1)
      if (allocated(ksize1)) deallocate (ksize1)
      if (allocated(istart2)) deallocate (istart2)
      if (allocated(iend2)) deallocate (iend2)
      if (allocated(jstart2)) deallocate (jstart2)
      if (allocated(jend2)) deallocate (jend2)
      if (allocated(kstart2)) deallocate (kstart2)
      if (allocated(kend2)) deallocate (kend2)
      if (allocated(isize2)) deallocate (isize2)
      if (allocated(jsize2)) deallocate (jsize2)
      if (allocated(ksize2)) deallocate (ksize2)
c
c     module "freeze"
c
      if (allocated(buflenrat1)) deallocate (buflenrat1)
      if (allocated(buflenrat2)) deallocate (buflenrat2)
      if (allocated(bufbegrat1)) deallocate (bufbegrat1)
      if (allocated(bufbegrat2)) deallocate (bufbegrat2)
      if (allocated(bufrat1)) deallocate (bufrat1)
      if (allocated(bufrat2)) deallocate (bufrat2)
c
c     module "group"
c
      if (allocated(kgrp)) deallocate (kgrp)
      if (allocated(grplist)) deallocate (grplist)
      if (allocated(igrp)) deallocate (igrp)
      if (allocated(grpmass)) deallocate (grpmass)
      if (allocated(wgrp)) deallocate (wgrp)
c
c     module "kopbnd"
c
      if (allocated(jopb)) deallocate (jopb)
c
c     module "langevin"
c
      if (allocated(Rn)) deallocate (Rn)
c
c     module "moldyn"
c
      if (allocated(v)) deallocate (v)
      if (allocated(a)) deallocate (a)
      if (allocated(aalt)) deallocate (aalt)
      if (allocated(aalt2)) deallocate (aalt2)
c
c     module "neigh"
c
      if (allocated(nvlst)) deallocate (nvlst)
      if (allocated(vlst)) deallocate (vlst)
      if (allocated(nelst)) deallocate (nelst)
      if (allocated(elst)) deallocate (elst)
      if (allocated(nshortvlst)) deallocate (nshortvlst)
      if (allocated(shortvlst)) deallocate (shortvlst)
      if (allocated(nshortelst)) deallocate (nshortelst)
      if (allocated(shortelst)) deallocate (shortelst)
      if (allocated(ineignl)) deallocate (ineignl)
      if (allocated(neigcell)) deallocate (neigcell)
      if (allocated(numneigcell)) deallocate (numneigcell)
      if (allocated(repartcell)) deallocate (repartcell)
      if (allocated(cell_len)) deallocate (cell_len)
      if (allocated(indcell)) deallocate (indcell)
      if (allocated(bufbegcell)) deallocate (bufbegcell)
      if (allocated(xbegcell)) deallocate (xbegcell)
      if (allocated(ybegcell)) deallocate (ybegcell)
      if (allocated(zbegcell)) deallocate (zbegcell)
      if (allocated(xendcell)) deallocate (xendcell)
      if (allocated(yendcell)) deallocate (yendcell)
      if (allocated(zendcell)) deallocate (zendcell)
c
c     module "mpole"
c
      if (allocated(poleloc)) deallocate (poleloc)
      if (allocated(polelocnl)) deallocate (polelocnl)
      if (allocated(polerecloc)) deallocate (polerecloc)
      if (allocated(zaxis)) deallocate (zaxis)
      if (allocated(yaxis)) deallocate (yaxis)
      if (allocated(xaxis)) deallocate (xaxis)
      if (allocated(rpole)) deallocate (rpole)

c
c     module "pme"
c
      if (allocated(thetai1)) deallocate (thetai1)
      if (allocated(thetai2)) deallocate (thetai2)
      if (allocated(thetai3)) deallocate (thetai3)
      if (allocated(qgridin_2d)) deallocate (qgridin_2d)
      if (allocated(qgridout_2d)) deallocate (qgridout_2d)
      if (allocated(qgrid2in_2d)) deallocate (qgrid2in_2d)
      if (allocated(qgrid2out_2d)) deallocate (qgrid2out_2d)
      if (allocated(qfac_2d)) deallocate (qfac_2d)
      if (allocated(cphirec)) deallocate (cphirec)
      if (allocated(fphirec)) deallocate (fphirec)
      if (allocated(igrid)) deallocate (igrid)
c
c     module "polar"
c
      if (allocated(uind)) deallocate (uind)
      if (allocated(uinp)) deallocate (uinp)
c
c     module "polpot"
c
      if (allocated(residue)) deallocate (residue)
      if (allocated(munp)) deallocate (munp)
      if (allocated(efres)) deallocate (efres)
c
c     module "uprior"
c
      if (allocated(udalt)) deallocate (udalt)
      if (allocated(upalt)) deallocate (upalt)
      if (allocated(udshortalt)) deallocate (udshortalt)
      if (allocated(upshortalt)) deallocate (upshortalt)
c
c     module "vdw"
c
      if (allocated(vdwlocnl)) deallocate (vdwlocnl)
c
c     "attach" related arrays
c
      call dealloc_shared_attach
c
c     "active" related arrays
c
      call dealloc_shared_active
c
c     "bonds" related arrays
c
      call dealloc_shared_bond
c
c     "angles" related arrays
c
      call dealloc_shared_angles
c
c     "torsions" related arrays
c
      call dealloc_shared_torsions
c
c     "bitors" related arrays
c
      call dealloc_shared_bitors
c
c     "katom" related arrays
c
      call dealloc_shared_katom
c
c     "molecule" related arrays
c
      call dealloc_shared_mol
c
c     "kangang" related arrays
c
      call dealloc_shared_angang
c
c     "kopbend" related arrays
c
      call dealloc_shared_opbend
c
c     "kopdist" related arrays
c
      call dealloc_shared_opdist
c
c     "kcharge" related arrays
c
      call dealloc_shared_chg
c
c     "kvdw" related arrays
c
      call dealloc_shared_vdw
c
c     "kmpole" related arrays
c
      call dealloc_shared_mpole
c
c     "kpolar" related arrays
c
      call dealloc_shared_polar
c
c     "kchgflx" related arrays
c
      call dealloc_shared_chgflx
c
c     "krepel" related arrays
c
      call dealloc_shared_rep
c
c     "kchgtrn" related arrays
c
      call dealloc_shared_chgct
c
c     "kdisp" related arrays
c
      call dealloc_shared_disp
c
c     "kgeom" related arrays
c
      call dealloc_shared_geom
c
c     "mutant" related arrays
c
      call dealloc_shared_mutate
c
c     print a final status message before exiting TINKER-HP
c
      if (rank.eq.0) write (iout,10)
   10 format (/,' TINKER-HP is Exiting following Normal Termination')
c
c     may need a pause to avoid closing the execution window
c
      if (holdup) then
         read (input,20)
   20    format ()
      end if
      return
      end
