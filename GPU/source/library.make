#
#
#  #################################################################
#  ##                                                             ##
#  ##  library.make  --  create object library of TINKER modules  ##
#  ##         (Intel Fortran Compiler for Linux Version)          ##
#  ##                                                             ##
#  #################################################################
#
#
#ar -crsv libtinker.a \
echo "****** Making libtinker.a ******"
ar -crs libtinker.a \
MOD_sizes.o \
MOD_tinheader.o \
MOD_action.o \
MOD_analyz.o \
MOD_angang.o \
MOD_angle.o \
MOD_angpot.o \
MOD_argue.o \
MOD_ascii.o \
MOD_atmlst.o \
MOD_atoms.o \
MOD_atmtyp.o \
MOD_bath.o \
MOD_bitor.o \
MOD_bndpot.o \
MOD_bond.o \
MOD_bound.o \
MOD_boxes.o \
MOD_cell.o \
MOD_charge.o \
MOD_chgpot.o \
MOD_chunks.o \
MOD_couple.o \
MOD_cutoff.o \
MOD_deriv.o \
MOD_divcon.o \
MOD_domdec.o \
MOD_energi.o \
MOD_erf.o \
MOD_ewald.o \
MOD_fft.o \
MOD_fields.o \
MOD_files.o \
MOD_freeze.o \
MOD_group.o \
MOD_improp.o \
MOD_imptor.o \
MOD_inform.o \
MOD_inter.o \
MOD_interfaces.o \
MOD_iounit.o \
MOD_kanang.o \
MOD_kangs.o \
MOD_katoms.o \
MOD_kbonds.o \
MOD_kchrge.o \
MOD_keys.o \
MOD_khbond.o \
MOD_kiprop.o \
MOD_kgeoms.o \
MOD_kitors.o \
MOD_kmulti.o \
MOD_kopbnd.o \
MOD_kopdst.o \
MOD_kpitor.o \
MOD_kpolr.o \
MOD_kstbnd.o \
MOD_ksttor.o \
MOD_ktorsn.o \
MOD_ktrtor.o \
MOD_kurybr.o \
MOD_kvdwpr.o \
MOD_kvdws.o \
MOD_langevin.o \
MOD_linmin.o \
MOD_mamd.o \
MOD_math.o \
MOD_merck.o \
MOD_mpole.o \
MOD_mdstuf.o \
MOD_memory.o \
MOD_minima.o \
MOD_molcul.o \
MOD_moldyn.o \
MOD_mplpot.o \
MOD_msmd.o \
MOD_mutant.o \
MOD_neigh.o \
MOD_nvtx.o \
MOD_opbend.o \
MOD_opdist.o \
MOD_output.o \
MOD_params.o \
MOD_pitors.o \
MOD_pme.o \
MOD_polar.o \
MOD_polgrp.o \
MOD_polpot.o \
MOD_potent.o \
MOD_precis.o \
MOD_precompute_polegpu.o \
MOD_ptable.o \
MOD_random.o \
MOD_resdue.o \
MOD_ring.o \
MOD_scales.o \
MOD_shunt.o \
MOD_strbnd.o \
MOD_strtor.o \
MOD_subAtoms.o \
MOD_subDeriv.o \
MOD_subMemory.o \
MOD_subInform.o \
MOD_timestat.o \
MOD_titles.o \
MOD_torpot.o \
MOD_tors.o \
MOD_tortor.o \
MOD_units.o \
MOD_uprior.o \
MOD_urey.o \
MOD_urypot.o \
MOD_usage.o \
MOD_USampling.o \
MOD_utils.o \
MOD_utilcomm.o \
MOD_utilcu.o \
MOD_utilvec.o \
MOD_utilgpu.o \
MOD_virial.o \
MOD_vdw.o \
MOD_vdwpot.o \
MOD_vec.o \
MOD_vec_elec.o \
MOD_vec_vdw.o \
MOD_vec_polar.o \
MOD_vec_mpole.o \
MOD_vec_charge.o \
MOD_vec_list.o \
nblistcu.o \
eljcu.o \
ehal1cu.o \
echargecu.o \
empole1cu.o \
tmatxb_pmecu.o \
epolar1cu.o \
pmestuffcu.o \
cu_nblist.o \
cu_tmatxb_pme.o \
cu_mpole1.o \
cu_CholeskySolver.o \
active.o \
analysis.o \
angles.o \
attach.o \
basefile.o \
beeman.o \
bicubic.o \
baoab.o \
baoabrespa.o \
baoabrespa1.o \
bbk.o \
bitors.o \
bonds.o \
bounds.o \
calendar.o \
chkpole.o \
chkpolegpu.o \
chkring.o \
chkxyz.o \
cholesky.o \
cluster.o \
command.o \
control.o \
cspline.o \
cutoffs.o \
diis.o \
domdecstuff.o \
dcinduce_pme.o \
dcinduce_pmegpu.o \
dcinduce_pme2.o \
dcinduce_pme2gpu.o \
dcinduce_shortreal.o \
dcinduce_shortrealgpu.o \
eamd1.o \
eangang.o \
eangang1.o \
eangang3.o \
eangle.o \
eangle1.o \
eangle1gpu.o \
eangle3.o \
eangle3gpu.o  \
ebond.o \
ebond1.o \
ebond1gpu.o \
ebond3.o \
ebond3gpu.o \
echarge.o \
echarge1.o \
echarge1vec.o \
echarge1gpu.o \
echarge3.o \
echarge3vec.o \
echarge3gpu.o \
efld0_direct.o  \
efld0_directvec.o  \
efld0_directgpu.o  \
egeom.o \
egeom1.o \
egeom1gpu.o \
egeom3.o \
egeom3gpu.o \
ehal.o \
ehal1.o \
ehal1vec.o \
ehal1gpu.o \
ehal3.o \
ehal3vec.o \
ehal3gpu.o \
eimprop.o \
eimprop1.o \
eimprop1gpu.o \
eimprop3.o \
eimptor.o \
eimptor1.o \
eimptor3.o \
elj.o \
elj1.o \
elj1vec.o \
elj1gpu.o \
elj3.o \
elj3vec.o \
elj3gpu.o \
empole.o \
empole0.o \
empole1.o \
empole1vec.o \
empole1gpu.o \
empole3.o \
empole3vec.o \
empole3gpu.o \
energy.o \
eopbend.o \
eopbend1.o \
eopbend1gpu.o \
eopbend3.o \
eopbend3gpu.o \
eopdist.o \
eopdist1.o \
eopdist3.o \
epitors.o \
epitors1.o \
epitors1gpu.o \
epitors3.o \
epolar.o \
epolarvec.o \
epolar1.o \
epolar1vec.o \
epolar1gpu.o \
epolar3.o \
epolar3vec.o \
epolar3gpu.o \
eprecip1vec.o \
esmd1.o \
estrbnd.o \
estrbnd1.o \
estrbnd1gpu.o \
estrbnd3.o \
estrtor.o \
estrtor1.o \
estrtor1gpu.o \
estrtor3.o \
etors.o \
etors1.o \
etors1gpu.o \
etors3.o \
etortor.o \
etortor1.o \
etortor1gpu.o \
etortor3.o \
eurey.o \
eurey1.o \
eurey1gpu.o  \
eurey3.o \
eurey3gpu.o \
evcorr.o \
extra.o \
extra1.o \
extra3.o \
fatal.o \
fft_mpi.o \
field.o \
final.o \
freeunit.o \
geometry.o \
getkey.o \
getnumb.o \
getprm.o \
getstring.o \
gettext.o \
getword.o \
getxyz.o \
gradient.o \
hybrid.o \
image.o \
initatom.o \
initial.o \
initprm.o \
initres.o \
invert.o \
kamd.o \
kangang.o \
kangle.o \
katom.o \
kbond.o \
kcharge.o \
kewald.o \
kgeom.o \
kimprop.o \
kimptor.o \
kinetic.o \
kmpole.o \
kopbend.o \
kopdist.o \
kpitors.o \
kpolar.o \
ksmd.o \
kstrbnd.o \
kstrtor.o \
ktors.o \
ktortor.o \
kurey.o \
kvdw.o \
kscalfactor.o \
lattice.o \
lbfgs.o \
linalg.o \
maxwell.o \
mdinit.o \
mdrest.o \
mdsave.o \
mdstat.o \
mechanic.o \
mpistuff.o \
molecule.o \
mutate.o \
nblist.o \
nblistvec.o \
nblistgpu.o \
newinduce_pme.o \
newinduce_pmevec.o \
newinduce_pmegpu.o \
newinduce_pme2.o \
newinduce_pme2vec.o \
newinduce_pme2gpu.o \
newinduce_shortreal.o \
newinduce_shortrealgpu.o \
nextarg.o \
nexttext.o \
nspline.o \
number.o \
numeral.o \
openend.o \
optsave.o \
pmestuff.o \
pmestuffgpu.o \
precise.o \
pressure.o \
prime.o \
promo.o \
promoamd.o \
promosmd.o \
prmkey.o \
prtdyn.o \
prtxyz.o \
readdyn.o \
readprm.o \
readxyz.o \
respa.o \
respa1.o \
rings.o \
rotpole.o \
rotpolegpu.o  \
search.o \
sort.o \
rattle.o \
shakeup.o \
suffix.o \
switch.o \
temper.o \
tmatxb_pme.o \
tmatxb_pmevec.o \
tmatxb_pmegpu.o \
torphase.o \
torque.o \
torquegpu.o \
torquevec2.o \
torsions.o \
trimtext.o \
unitcell.o \
verlet.o \
version.o \
$@
