#include "tinker_cudart.h"
      M_subroutine
     &             charge_couple(r2,xr,yr,zr,ebuffer
     &                          ,fik,aewald,cscale
     &                          ,e,ded,dedc,config)
!$acc routine
        use tinheader ,only: ti_p
        use math      ,only: sqrtpi
        use tintypes  ,only: real3,real3_red
#ifdef TINKER_CUF
        use utilcu ,only: f_erfc
#  if defined(SINGLE)||defined(MIXED)
        use utilcu ,only: f_sqrt,f_exp
#  endif
#endif
        implicit none
        real(t_p)  ,intent(in ):: r2,xr,yr,zr,ebuffer
     &             ,fik,aewald,cscale
        integer    ,intent(in ):: config
        real(t_p)  ,intent(inout):: e
        type(real3),intent(out):: ded
        type(real3_red),intent(out):: dedc
        integer,parameter:: no_scaling=0,correct_scaling=1
        real(t_p) r,rb,rb2,rew,de,erfterm,exp2a

        r   = f_sqrt(r2)
        rb  = r + ebuffer
        rb2 = rb * rb

        if (config.eq.no_scaling) then
           rew = aewald * r
           exp2a   = f_exp(-rew**2)
           erfterm = f_erfc (rew)
           e   = WRITE_C(e) + (fik/rb) * (erfterm)
           de  = -fik * ((erfterm)/rb2
     &                + (2.0*aewald/sqrtpi)*exp2a/r)
        else if (config.eq.correct_scaling) then
           e   = WRITE_C(e) + (fik/rb) * (cscale)
           de  = -fik     * (cscale)/rb2
        end if
c
c     form the chain rule terms for derivative expressions
c
        de     = de / r
        ded%x  = de * xr
        ded%y  = de * yr
        ded%z  = de * zr

        ! Useful with mixed presicion
        dedc%x = WRITE_C(dedc%x -) ded%x
        dedc%y = WRITE_C(dedc%y -) ded%y
        dedc%z = WRITE_C(dedc%z -) ded%z
      end subroutine

      M_subroutine
     &            charge3_couple(r2,xr,yr,zr,ebuffer
     &                          ,fik,aewald,cscale
     &                          ,e,config)
!$acc routine
        use tinheader ,only: ti_p
        use math      ,only: sqrtpi
        use tintypes  ,only: real3,real3_red
#ifdef TINKER_CUF
        use utilcu ,only: f_erfc
#  if defined(SINGLE)||defined(MIXED)
        use utilcu ,only: f_sqrt,f_exp
#  endif
#endif
        implicit none
        real(t_p),intent(in ):: r2,xr,yr,zr,ebuffer
     &           ,fik,aewald,cscale
        integer  ,intent(in ):: config
        real(t_p),intent(inout):: e
        integer  ,parameter:: no_scaling=0,correct_scaling=1
        real(t_p) r,rb,rb2,rew,de,erfterm,exp2a

        r   = f_sqrt(r2)
        rb  = r + ebuffer
        rb2 = rb * rb

        if (config.eq.no_scaling) then
           rew = aewald * r
           exp2a   = f_exp(-rew**2)
           erfterm = f_erfc (rew)
           e   = WRITE_C(e) + (fik/rb) * (erfterm)
           de  = -fik * ((erfterm)/rb2
     &                + (2.0*aewald/sqrtpi)*exp2a/r)
        else if (config.eq.correct_scaling) then
           e   = WRITE_C(e) + (fik/rb) * (cscale)
           de  = -fik     * (cscale)/rb2
        end if
      end subroutine

      M_subroutine
     &             charge_couple_shortlong
     &                          (r2,xr,yr,zr,ebuffer
     &                          ,fik,aewald,cscale,off,shortheal
     &                          ,en,ded,dedc,config,mode)
!$acc routine
        use tinheader ,only: ti_p
        use interfaces,only: long_mode
        use math      ,only: sqrtpi
        use tintypes  ,only: real3,real3_red
#ifdef TINKER_CUF
        use utilcu ,only: f_erfc
#  if defined(SINGLE)||defined(MIXED)
        use utilcu ,only: f_sqrt,f_exp
#  endif
#endif
        implicit none
        real(t_p)  ,intent(in ):: r2,xr,yr,zr,ebuffer
     &             ,fik,aewald,cscale,off,shortheal
        integer    ,intent(in ):: config,mode
        real(t_p)  ,intent(inout):: en
        type(real3),intent(out):: ded
        type(real3_red),intent(out):: dedc
        integer,parameter:: no_scaling=0,correct_scaling=1
        real(t_p) r,rb,rb2,rew,de,e,erfterm,s,ds,exp2a

        r   = f_sqrt(r2)
        rb  = r + ebuffer
        rb2 = rb * rb

        if (config.eq.no_scaling) then
           rew = aewald * r
           exp2a   = f_exp(-rew**2)
           erfterm = f_erfc (rew)
           e   = (fik/rb) * (erfterm)
           de  = -fik * ((erfterm)/rb2
     &                + (2.0*aewald/sqrtpi)*exp2a/r)
        else if (config.eq.correct_scaling) then
           e   = (fik/rb) * (cscale)
           de  = -fik     * (cscale)/rb2
        end if

        call switch_respa_inl(r,off,shortheal,s,ds)
c
c     form the chain rule terms for derivative expressions
c
        if (mode.eq.long_mode) then
           en    = WRITE_C(en) + (1-s)*e
           de    = (-e*ds+(1-s)*de) / r
           ded%x = de * xr
           ded%y = de * yr
           ded%z = de * zr
        else
           en    = WRITE_C(en) + e*s
           de    = de / r
           ded%x = de * xr*s - ds*xr*e/r
           ded%y = de * yr*s - ds*yr*e/r
           ded%z = de * zr*s - ds*zr*e/r
        end if

        ! Useful with mixed presicion
        dedc%x = WRITE_C(dedc%x +) ded%x
        dedc%y = WRITE_C(dedc%y +) ded%y
        dedc%z = WRITE_C(dedc%z +) ded%z
      end subroutine