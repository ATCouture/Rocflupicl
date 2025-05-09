










!*********************************************************************
!* Illinois Open Source License                                      *
!*                                                                   *
!* University of Illinois/NCSA                                       * 
!* Open Source License                                               *
!*                                                                   *
!* Copyright@2008, University of Illinois.  All rights reserved.     *
!*                                                                   *
!*  Developed by:                                                    *
!*                                                                   *
!*     Center for Simulation of Advanced Rockets                     *
!*                                                                   *
!*     University of Illinois                                        *
!*                                                                   *
!*     www.csar.uiuc.edu                                             *
!*                                                                   *
!* Permission is hereby granted, free of charge, to any person       *
!* obtaining a copy of this software and associated documentation    *
!* files (the "Software"), to deal with the Software without         *
!* restriction, including without limitation the rights to use,      *
!* copy, modify, merge, publish, distribute, sublicense, and/or      *
!* sell copies of the Software, and to permit persons to whom the    *
!* Software is furnished to do so, subject to the following          *
!* conditions:                                                       *
!*                                                                   *
!*                                                                   *
!* @ Redistributions of source code must retain the above copyright  * 
!*   notice, this list of conditions and the following disclaimers.  *
!*                                                                   * 
!* @ Redistributions in binary form must reproduce the above         *
!*   copyright notice, this list of conditions and the following     *
!*   disclaimers in the documentation and/or other materials         *
!*   provided with the distribution.                                 *
!*                                                                   *
!* @ Neither the names of the Center for Simulation of Advanced      *
!*   Rockets, the University of Illinois, nor the names of its       *
!*   contributors may be used to endorse or promote products derived * 
!*   from this Software without specific prior written permission.   *
!*                                                                   *
!* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,   *
!* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   *
!* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          *
!* NONINFRINGEMENT.  IN NO EVENT SHALL THE CONTRIBUTORS OR           *
!* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       * 
!* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *
!* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE    *
!* USE OR OTHER DEALINGS WITH THE SOFTWARE.                          *
!*********************************************************************
!* Please acknowledge The University of Illinois Center for          *
!* Simulation of Advanced Rockets in works and publications          *
!* resulting from this software or its derivatives.                  *
!*********************************************************************
! *****************************************************************************
!
! Purpose: Calculate the viscous fluxes for the RocfluidMP framework.
!
! Description: None.
!
! Input: 
!   region      Data of current region.
!
! Output: None.
!
! Notes: None.
!
! *****************************************************************************
!
! $Id: ViscousFluxesMP.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2003-2006 by the University of Illinois
!
! *****************************************************************************

SUBROUTINE ViscousFluxesMP(region)

  USE ModDataTypes
  USE ModError
  USE ModParameters  
  USE ModBndPatch, ONLY: t_patch
  USE ModDataStruct, ONLY: t_region
  USE ModGlobal, ONLY: t_global
  USE ModError
  USE ModParameters

  USE RFLU_ModConvertCv, ONLY: RFLU_ScalarConvertCvCons2Prim, &
                               RFLU_ScalarConvertCvPrim2Cons
  USE RFLU_ModDifferentiationBFaces
  USE RFLU_ModDifferentiationFaces
  USE ModInterfaces, ONLY : RFLU_DecideNeedBGradFace 

  USE ModInterfaces, ONLY: RFLU_ScalarViscousFluxes

  IMPLICIT NONE

! *****************************************************************************
! Definitions and declarations
! *****************************************************************************

! =============================================================================
! Arguments
! =============================================================================

  TYPE(t_region), TARGET :: region

! =============================================================================
! Locals
! =============================================================================

  TYPE(t_global), POINTER :: global
  TYPE(t_patch), POINTER :: pPatch
  INTEGER :: errorFlag,iPatch,iSpec  
  INTEGER, DIMENSION(:), ALLOCATABLE :: varInfoSpec    
  TYPE(t_region), POINTER :: pRegion

! *****************************************************************************
! Start
! *****************************************************************************

  global => region%global

  CALL RegisterFunction( global,'ViscousFluxesMP',"../libfloflu/ViscousFluxesMP.F90" )

! *****************************************************************************
! Compute viscous fluxes for conserved equations (r,ru,rv,rw,rE,rY_i)
! *****************************************************************************

! =============================================================================
! Mixture- viscous flux for (u,v,w,T)
! =============================================================================

  CALL ViscousFluxes( region )

! =============================================================================
! Species - viscous flux for (rY_i) species equations and
!           energy flux = r*sum(D_i h_i grad(Y_i))
! =============================================================================

  IF ( global%specUsed .EQV. .TRUE. ) THEN
    pRegion => region

    CALL RFLU_ScalarConvertCvCons2Prim(pRegion,pRegion%spec%cv, &
                                       pRegion%spec%cvState)

    ALLOCATE(varInfoSpec(pRegion%specInput%nSpecies),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_ALLOCATE,152,'varInfoSpec')
    END IF ! global%error

    DO iSpec = 1,pRegion%specInput%nSpecies
      varInfoSpec(iSpec) = V_SPEC_VAR1 + iSpec - 1
    END DO ! iSpec

    CALL RFLU_ComputeGradFacesWrapper(pRegion,1,pRegion%specInput%nSpecies, & 
                                      1,pRegion%specInput%nSpecies, &
                                      pRegion%spec%cv,pRegion%spec%gradFace)

    IF ( pRegion%grid%nFacesConstr > 0 ) THEN                              
      CALL RFLU_ComputeGradFacesConstr(pRegion,1,pRegion%specInput%nSpecies, & 
                                       1,pRegion%specInput%nSpecies, &
                                       varInfoSpec,pRegion%spec%cv, &
                                       pRegion%spec%gradFace)                              
    END IF ! pRegion%grid%nFacesConstr      

    DO iPatch = 1,pRegion%grid%nPatches
      pPatch => pRegion%patches(iPatch)

      IF ( RFLU_DecideNeedBGradFace(pRegion,pPatch) .EQV. .TRUE. ) THEN

        CALL RFLU_ComputeGradBFacesWrapper(pRegion,pPatch,1, &
                                           pRegion%specInput%nSpecies,1, &
                                           pRegion%specInput%nSpecies, &
                                           pRegion%spec%cv, &
                                           pPatch%spec%gradFace)
        IF ( pPatch%cReconst /= CONSTR_NONE ) THEN                                          
          CALL RFLU_ComputeBFGradConstrWrapper(pRegion,pPatch,1, &
                                               pRegion%specInput%nSpecies,1, &
                                               pRegion%specInput%nSpecies, &
                                               varInfoSpec,pRegion%spec%cv, &
                                               pPatch%spec%gradFace)
        END IF ! pPatch%cReconst                                             
      END IF ! RFLU_DecideNeedBGradFace
    END DO ! iPatch


    DEALLOCATE(varInfoSpec,STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_DEALLOCATE,194,'varInfoSpec')
    END IF ! global%error

    CALL RFLU_ScalarViscousFluxes(pRegion,pRegion%specInput%nSpecies, &
                                  pRegion%spec%tv,pRegion%spec%gradFace, &
                                  pRegion%spec%diss)
    CALL RFLU_ScalarConvertCvPrim2Cons(pRegion,pRegion%spec%cv, &
                                       pRegion%spec%cvState)
  END IF ! global%specUsed

! *****************************************************************************
! End
! *****************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE ViscousFluxesMP

! *****************************************************************************
!
! RCS Revision history:
!
! $Log: ViscousFluxesMP.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.3  2008/12/06 08:43:33  mtcampbe
! Updated license.
!
! Revision 1.2  2008/11/19 22:16:48  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.1  2007/04/09 18:48:33  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 17:59:26  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.7  2006/08/19 15:38:39  mparmar
! Moved region%spec%bGradFace to patch%spec%gradFace
!
! Revision 1.6  2006/04/15 16:53:50  haselbac
! Added IF on cReconst flag on patch
!
! Revision 1.5  2006/04/07 15:19:15  haselbac
! Removed tabs
!
! Revision 1.4  2006/04/07 14:39:43  haselbac
! Changed calls to bface grad routines, now inside patch loop
!
! Revision 1.3  2005/10/30 21:46:23  haselbac
! Bug fix: Updated calls to CompGrad routines
!
! Revision 1.2  2005/10/05 13:49:37  haselbac
! Adapted to new face grads, cosmetics
!
! Revision 1.1  2004/12/01 16:52:19  haselbac
! Initial revision after changing case
!
! Revision 1.12  2004/07/28 15:29:18  jferry
! created global variable for spec use
!
! Revision 1.11  2004/03/05 22:09:00  jferry
! created global variables for peul, plag, and inrt use
!
! Revision 1.10  2004/01/29 22:52:51  haselbac
! Added viscous fluxes for species, some clean-up
!
! Revision 1.9  2003/12/04 03:23:11  haselbac
! Moved RFLU_Convert calls into viscousFluxes routine
!
! Revision 1.8  2003/11/20 16:40:36  mdbrandy
! Backing out RocfluidMP changes from 11-17-03
!
! Revision 1.5  2003/10/03 20:44:02  haselbac
! Corrected Rocflu code
!
! Revision 1.4  2003/10/01 23:52:10  jblazek
! Corrected bug in moving noslip wall BC and grid speeds.
!
! Revision 1.3  2003/05/15 02:57:02  jblazek
! Inlined index function.
!
! Revision 1.2  2003/04/10 01:22:41  jblazek
! Got rid of pRegion in ViscousFluxesMP.
!
! Revision 1.1  2003/03/28 19:48:26  fnajjar
! Initial import for RocfluidMP
!
! *****************************************************************************

