










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
! ******************************************************************************
!
! Purpose: Suite of routines to allocate memory.
!
! Description: None.
!
! Notes: None.
!
! ******************************************************************************
!
! $Id: RFLU_ModAllocateMemory.F90,v 1.2 2015/12/18 22:58:43 rahul Exp $
!
! Copyright: (c) 2004-2005 by the University of Illinois
!
! ******************************************************************************

MODULE RFLU_ModAllocateMemory

  USE ModDataTypes
  USE ModError
  USE ModGlobal, ONLY: t_global
  USE ModParameters
  USE ModGrid, ONLY: t_grid
  USE ModBndPatch, ONLY: t_patch
  USE ModDataStruct, ONLY: t_region
  USE ModMixture, ONLY: t_mixt_input
  USE ModMPI

  USE ModInterfaces, ONLY: RFLU_DecideNeedBGradFace

  IMPLICIT NONE

  PRIVATE
  PUBLIC :: RFLU_AllocateMemoryAuxVars, &
            RFLU_AllocateMemoryGSpeeds, &
            RFLU_AllocateMemorySol, &
            RFLU_AllocateMemorySolCv, &
            RFLU_AllocateMemorySolDv, &
            RFLU_AllocateMemorySolGv, &
            RFLU_AllocateMemorySolTv, &
            RFLU_AllocateMemoryTStep, & 
            RFLU_AllocateMemoryTStep_C, & 
            RFLU_AllocateMemoryTStep_I

! ******************************************************************************
! Declarations and definitions
! ******************************************************************************

  CHARACTER(CHRLEN) :: RCSIdentString = &
    '$RCSfile: RFLU_ModAllocateMemory.F90,v $ $Revision: 1.2 $'

! ******************************************************************************
! Routines
! ******************************************************************************

  CONTAINS





! ******************************************************************************
!
! Purpose: Allocate memory for auxiliary variables for non-dissipative solver.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemoryAuxVars(pRegion)

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: errorFlag
  TYPE(t_global), POINTER :: global
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_mixt_input), POINTER :: pMixtInput

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemoryAuxVars',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

  ALLOCATE(pRegion%mixt%cvOld(pMixtInput%nCv,pGrid%nCellsTot), &
           STAT=errorFlag)
  global%error = errorFlag
  IF (global%error /= ERR_NONE) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,175,'pRegion%mixt%cvOld')
  END IF ! global%error

  ALLOCATE(pRegion%mixt%cvOld2(pMixtInput%nCvOld2,pGrid%nCellsTot), &
           STAT=errorFlag)
  global%error = errorFlag
  IF (global%error /= ERR_NONE) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,182,'pRegion%mixt%cvOld2')
  END IF ! global%error

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemoryAuxVars





! ******************************************************************************
!
! Purpose: Allocate memory for grid speeds.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemoryGSpeeds(pRegion)

  USE RFLU_ModGridSpeedUtils

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: errorFlag,ifc,iPatch
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_mixt_input), POINTER :: pMixtInput
  TYPE(t_patch), POINTER :: pPatch
  TYPE(t_global), POINTER :: global

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemoryGSpeeds',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

! ==============================================================================
! Require grid speeds
! ==============================================================================

  IF ( RFLU_DecideNeedGridSpeeds(pRegion) .EQV. .TRUE. ) THEN

! ------------------------------------------------------------------------------
!   Interior faces
! ------------------------------------------------------------------------------

    ALLOCATE(pGrid%gs(pGrid%nFaces),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,271,'pGrid%gs')
    END IF ! global%error

    DO ifc = 1,pGrid%nFaces ! Explicit loop to avoid Frost problem
      pGrid%gs(ifc) = 0.0_RFREAL
    END DO ! ifc

! ------------------------------------------------------------------------------
!   Patch faces
! ------------------------------------------------------------------------------

    IF ( pGrid%nPatches > 0 ) THEN
      DO iPatch = 1,pGrid%nPatches
        pPatch => pRegion%patches(iPatch)

        ALLOCATE(pPatch%gs(pPatch%nBFaces),STAT=errorFlag)
        global%error = errorFlag
        IF ( global%error /= ERR_NONE ) THEN
          CALL ErrorStop(global,ERR_ALLOCATE,301,'pPatch%gs')
        END IF ! global%error

        DO ifc = 1,pPatch%nBFaces ! Explicit loop to avoid Frost problem
          pPatch%gs(ifc) = 0.0_RFREAL
        END DO ! ifc
      END DO ! iPatch
    END IF ! pGrid%nPatches

! ==============================================================================
! Do not require grid speeds
! ==============================================================================

  ELSE

! ------------------------------------------------------------------------------
!   Interior faces
! ------------------------------------------------------------------------------

    ALLOCATE(pGrid%gs(0:1),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,338,'pGrid%gs')
    END IF ! global%error

    DO ifc = 0,1 ! Explicit loop to avoid Frost problem
      pGrid%gs(ifc) = 0.0_RFREAL
    END DO ! ifc

! ------------------------------------------------------------------------------
!   Patch faces
! ------------------------------------------------------------------------------

    IF ( pGrid%nPatches > 0 ) THEN
      DO iPatch = 1,pGrid%nPatches
        pPatch => pRegion%patches(iPatch)

        ALLOCATE(pPatch%gs(0:1),STAT=errorFlag)
        global%error = errorFlag
        IF ( global%error /= ERR_NONE ) THEN
          CALL ErrorStop(global,ERR_ALLOCATE,356,'pPatch%gs')
        END IF ! global%error

        DO ifc = 0,1 ! Explicit loop to avoid Frost problem
          pPatch%gs(ifc) = 0.0_RFREAL
        END DO ! ifc
      END DO ! iPatch
    END IF ! pGrid%nPatches
  END IF ! pMixtInput%moveGrid

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemoryGSpeeds






! ******************************************************************************
!
! Purpose: Allocate memory for mixture solution.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemorySol(pRegion)

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  TYPE(t_global), POINTER :: global

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemorySol',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Allocate memory
! ******************************************************************************

  CALL RFLU_AllocateMemorySolCv(pRegion)
  CALL RFLU_AllocateMemorySolDv(pRegion)
  CALL RFLU_AllocateMemorySolGv(pRegion)
  CALL RFLU_AllocateMemorySolTv(pRegion)

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemorySol






! ******************************************************************************
!
! Purpose: Allocate memory for conserved variables of mixture.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemorySolCv(pRegion)

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: errorFlag,i
  TYPE(t_global), POINTER :: global
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_mixt_input), POINTER :: pMixtInput  

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemorySolCv',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

  ALLOCATE(pRegion%mixt%cv(pMixtInput%nCv,pGrid%nCellsTot),STAT=errorFlag)
  global%error = errorFlag
  IF (global%error /= ERR_NONE) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,504,'pRegion%mixt%cv')
  END IF ! global%error

  ALLOCATE(pRegion%mixt%cvInfo(pMixtInput%nCv),STAT=errorFlag)
  global%error = errorFlag
  IF (global%error /= ERR_NONE) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,510,'pRegion%mixt%cvInfo')
  END IF ! global%error

  IF ( global%piclUsed .EQV. .TRUE. ) THEN
     ALLOCATE(pRegion%mixt%piclVF(pGrid%nCellsTot),STAT=errorFlag)
     ! 03/19/2025 - Thierry - begins here
     ALLOCATE(pRegion%mixt%piclVFg(1,pGrid%nCellsTot),STAT=errorFlag)
     ALLOCATE(pRegion%mixt%piclgradRhog(3,1,pGrid%nCellsTot),STAT=errorFlag)
     global%error = errorFlag
     IF (global%error /= ERR_NONE) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,521,'pRegion%mixt%piclfVF')
     END IF ! global%error
     ! 04/01/2025 - TLJ - begins here
     ALLOCATE(pRegion%mixt%piclFeedback(3,pGrid%nCellsTot),STAT=errorFlag)
     ALLOCATE(pRegion%mixt%piclgradFeedback(3,3,pGrid%nCellsTot),STAT=errorFlag)
     global%error = errorFlag
     IF (global%error /= ERR_NONE) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,528,'pRegion%mixt%piclFeedback')
     END IF ! global%error
   END IF

! TEMPORARY: Manoj: 2012-05-16: Allocating mixt%vFracE
! ndef PLAG or if plagUsed = FALSE
! otherwise it gets allocated in PLAG_RFLU_AllocMemSol
  ALLOCATE(pRegion%plag%vFracE(1,0:1),STAT=errorFlag)
  global%error = errorFlag
  IF (global%error /= ERR_NONE) THEN 
    CALL ErrorStop(global,ERR_ALLOCATE,557,'pPlag%vFracE')
  END IF ! global%error 
  
  pRegion%plag%vFracE(1,0:1) = 0.0_RFREAL
! END TEMPORARY

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemorySolCv





! ******************************************************************************
!
! Purpose: Allocate memory for dependent variables of mixture.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemorySolDv(pRegion)

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: errorFlag
  TYPE(t_global), POINTER :: global
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_mixt_input), POINTER :: pMixtInput

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemorySolDv',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

  IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN
    IF ( pMixtInput%nDv /= 0 ) THEN
      ALLOCATE(pRegion%mixt%dv(DV_MIXT_TEMP:DV_MIXT_TEMP,pGrid%nCellsTot), &
               STAT=errorFlag)
      global%error = errorFlag
      IF (global%error /= ERR_NONE) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,639,'pRegion%mixt%dv')
      END IF ! global%error
    END IF ! pMixtInput%nDv 
  ELSE
    IF ( pMixtInput%nDv /= 0 ) THEN
      ALLOCATE(pRegion%mixt%dv(pMixtInput%nDv,pGrid%nCellsTot),STAT=errorFlag)
      global%error = errorFlag
      IF (global%error /= ERR_NONE) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,647,'pRegion%mixt%dv')
      END IF ! global%error
    END IF ! pMixtInput%nDv 
  END IF ! global%solverType

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemorySolDv





! ******************************************************************************
!
! Purpose: Allocate memory for gas variables of mixture.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemorySolGv(pRegion)

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: errorFlag
  TYPE(t_global), POINTER :: global
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_mixt_input), POINTER :: pMixtInput

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemorySolGv',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

  IF ( pMixtInput%gasModel == GAS_MODEL_TCPERF ) THEN
    ALLOCATE(pRegion%mixt%gv(pMixtInput%nGv,0:1),STAT=errorFlag)
  ELSE
    ALLOCATE(pRegion%mixt%gv(pMixtInput%nGv,pGrid%nCellsTot),STAT=errorFlag)
  END IF ! pRegion
  global%error = errorFlag
  IF (global%error /= ERR_NONE) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,728,'pRegion%mixt%gv')
  END IF ! global%error

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemorySolGv





! ******************************************************************************
!
! Purpose: Allocate memory for transport variables of mixture.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemorySolTv(pRegion)

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: errorFlag
  TYPE(t_global), POINTER :: global
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_mixt_input), POINTER :: pMixtInput

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemorySolTv',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

  IF ( pMixtInput%computeTv .EQV. .TRUE. ) THEN
    ALLOCATE(pRegion%mixt%tv(pMixtInput%nTv,pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF (global%error /= ERR_NONE) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,804,'pRegion%mixt%tv')
    END IF ! global%error
  ELSE
    NULLIFY(pRegion%mixt%tv)
  END IF ! pMixtInput%computeTv

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemorySolTv





! ******************************************************************************
!
! Purpose: Allocate memory for mixture time-stepping.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemoryTStep(pRegion)

  USE RFLU_ModOLES

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: arrayLimLow,arrayLimUpp,errorFlag,ic,icmp,ifc,iv,iPatch,nBFaces, &
             nBFacesTot
  TYPE(t_grid), POINTER :: pGrid,pGridOld,pGridOld2
  TYPE(t_patch), POINTER :: pPatch
  TYPE(t_global), POINTER :: global
  TYPE(t_mixt_input), POINTER :: pMixtInput  

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemoryTStep',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pGridOld   => pRegion%gridOld
  pGridOld2  => pRegion%gridOld2
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

! ==============================================================================
! Compute number of boundary faces for later use
! ==============================================================================

  nBFaces    = 0
  nBFacesTot = 0

  DO iPatch = 1,pGrid%nPatches
    pPatch => pRegion%patches(iPatch)

    nBFaces    = nBFaces    + pPatch%nBTris    + pPatch%nBQuads
    nBFacesTot = nBFacesTot + pPatch%nBTrisTot + pPatch%nBQuadsTot
  END DO ! iPatch

! ==============================================================================
! Reference solutions for sponge layer 
! ==============================================================================

  IF ( global%abcFlag .EQV. .TRUE. ) THEN 
    IF ( global%abcKind == 0 ) THEN
      IF (global%abcDistrib == 1 ) THEN
        ALLOCATE(pRegion%mixt%cvRef(pMixtInput%nCv,pGrid%nCellsTot), &
                 STAT=errorFlag)
        global%error = errorFlag
        IF (global%error /= ERR_NONE) THEN
          CALL ErrorStop(global,ERR_ALLOCATE,910,'pRegion%mixt%cvRef')
        END IF ! global%error
      ELSE
        ALLOCATE(pRegion%mixt%cvRef(pMixtInput%nCv,0:1),STAT=errorFlag)
        global%error = errorFlag
        IF (global%error /= ERR_NONE) THEN
          CALL ErrorStop(global,ERR_ALLOCATE,916,'pRegion%mixt%cvRef')
        END IF ! global%error
      END IF ! global%abcDistrib
    END IF ! global%abcKind
  END IF ! global%abcFlag 

! ==============================================================================
! Old solutions
! ==============================================================================

  IF ( global%solverType /= SOLV_IMPLICIT_HM ) THEN
    ALLOCATE(pRegion%mixt%cvOld(pMixtInput%nCv,pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF (global%error /= ERR_NONE) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,930,'pRegion%mixt%cvOld')
    END IF ! global%error
  END IF ! solverType

  SELECT CASE ( global%solverType )
    CASE ( SOLV_IMPLICIT_NK )
      ALLOCATE(pRegion%mixt%cvOld1(pMixtInput%nCv,pGrid%nCellsTot), &
               STAT=errorFlag)
      global%error = errorFlag
      IF (global%error /= ERR_NONE) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,940,'pRegion%mixt%cvOld1')
      END IF ! global%error

      ALLOCATE(pRegion%mixt%cvOld2(pMixtInput%nCv,pGrid%nCellsTot), &
               STAT=errorFlag)
      global%error = errorFlag
      IF (global%error /= ERR_NONE) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,947,'pRegion%mixt%cvOld2')
      END IF ! global%error
    CASE ( SOLV_IMPLICIT_HM )
      CALL RFLU_AllocateMemoryAuxVars(pRegion)
  END SELECT

! ==============================================================================
! Time step
! ==============================================================================

  IF ( global%solverType /= SOLV_IMPLICIT_HM ) THEN
    ALLOCATE(pRegion%dt(pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,961,'pRegion%dt')
    END IF ! global%error
  END IF ! solverType

! ==============================================================================
! Residuals
! ==============================================================================

  IF ( global%solverType /= SOLV_IMPLICIT_HM ) THEN
    ALLOCATE(pRegion%mixt%rhs(pMixtInput%nCv,pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,973,'pRegion%mixt%rhs')
    END IF ! global%error

    ALLOCATE(pRegion%mixt%diss(pMixtInput%nCv,pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,979,'pRegion%mixt%diss')
    END IF ! global%error

    IF ( global%flowType == FLOW_UNSTEADY ) THEN
      ALLOCATE(pRegion%mixt%rhsSum(pMixtInput%nCv,pGrid%nCellsTot), &
               STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,987,'pRegion%mixt%rhsSum')
      END IF ! global%error
    ELSE
      NULLIFY(pRegion%mixt%rhsSum)
    END IF ! global%flowType
  END IF ! solverType

! ==============================================================================
! Gradients
! ==============================================================================

! ------------------------------------------------------------------------------
! Cell gradients
! ------------------------------------------------------------------------------

  IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN
    IF ( pMixtInput%flowModel == FLOW_NAVST ) THEN
      ALLOCATE(pRegion%mixt%gradCell(XCOORD:ZCOORD, &
                                     GRC_MIXT_XVEL:GRC_MIXT_PRES, &
                                     pGrid%nCellsTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1009,'pRegion%mixt%gradCell')
      END IF ! global%error

      ALLOCATE(pRegion%mixt%gradCellOld(XCOORD:ZCOORD, &
                                     GRC_MIXT_XVEL:GRC_MIXT_PRES, &
                                     pGrid%nCellsTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1017, &
                       'pRegion%mixt%gradCellOld')
      END IF ! global%error
    ELSE
      ALLOCATE(pRegion%mixt%gradCell(XCOORD:ZCOORD, &
                                     GRC_MIXT_PRES:GRC_MIXT_PRES, &
                                     pGrid%nCellsTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1026,'pRegion%mixt%gradCell')
      END IF ! global%error

      ALLOCATE(pRegion%mixt%gradCellOld(XCOORD:ZCOORD, &
                                     GRC_MIXT_PRES:GRC_MIXT_PRES, &
                                     pGrid%nCellsTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1034, &
                       'pRegion%mixt%gradCellOld')
      END IF ! global%error
    END IF ! pMixtInput%flowModel 

    ALLOCATE(pRegion%mixt%gradCellOld2(XCOORD:ZCOORD, &
                                   GRC_MIXT_PRES:GRC_MIXT_PRES, &
                                   pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,1044, & 
                     'pRegion%mixt%gradCellOld2')
    END IF ! global%error
  ELSE
    IF ( (pMixtInput%spaceDiscr == DISCR_UPW_ROE     ) .OR. &
         (pMixtInput%spaceDiscr == DISCR_UPW_HLLC    ) .OR. & 
         (pMixtInput%spaceDiscr == DISCR_UPW_AUSMPLUS) .OR. &
         (pMixtInput%spaceDiscr == DISCR_UPW_AUSMPLUSUP) ) THEN
      IF ( pMixtInput%spaceOrder > 1 ) THEN
        ALLOCATE(pRegion%mixt%gradCell(XCOORD:ZCOORD, &
                                       GRC_MIXT_DENS:GRC_MIXT_PRES, &
                                       pGrid%nCellsTot),STAT=errorFlag)
        global%error = errorFlag
        IF ( global%error /= ERR_NONE ) THEN
          CALL ErrorStop(global,ERR_ALLOCATE,1058,'pRegion%mixt%gradCell')
        END IF ! global%error
      ELSE
        NULLIFY(pRegion%mixt%gradCell)
      END IF ! pMixtInput%spaceOrder
    ELSE IF ( pMixtInput%spaceDiscr == DISCR_OPT_LES ) THEN
      ALLOCATE(pRegion%mixt%gradCell(XCOORD:ZCOORD, &
                                     GRC_MIXT_XVEL:GRC_MIXT_ZVEL, &
                                     pGrid%nCellsTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1069,'pRegion%mixt%gradCell')
      END IF ! global%error
    ELSE
      NULLIFY(pRegion%mixt%gradCell)
    END IF ! pMixtInput%spaceDiscr
  END IF ! solverType

! ------------------------------------------------------------------------------
! Face gradients
! ------------------------------------------------------------------------------

  IF ( global%solverType /= SOLV_IMPLICIT_HM ) THEN
    IF ( pMixtInput%flowModel == FLOW_NAVST ) THEN
      ALLOCATE(pRegion%mixt%gradFace(XCOORD:ZCOORD, &
                                     GRF_MIXT_XVEL:GRF_MIXT_TEMP, &
                                     pGrid%nFaces),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1098,'pRegion%mixt%gradFace')
      END IF ! global%error
    ELSE
      NULLIFY(pRegion%mixt%gradFace)
    END IF ! pMixtInput%flowModel
  END IF ! solverType

  IF ( pGrid%nPatches > 0 ) THEN
    DO iPatch = 1,pRegion%grid%nPatches
      pPatch => pRegion%patches(iPatch)

      IF ( RFLU_DecideNeedBGradFace(pRegion,pPatch) .EQV. .TRUE. ) THEN
        ALLOCATE(pPatch%mixt%gradFace(XCOORD:ZCOORD, &
                                      GRBF_MIXT_DENS:GRBF_MIXT_PRES, &
                                      pPatch%nBFaces),STAT=errorFlag)
        global%error = errorFlag
        IF ( global%error /= ERR_NONE ) THEN
          CALL ErrorStop(global,ERR_ALLOCATE,1115,'pPatch%mixt%gradFace')
        END IF ! global%error
      ELSE
        NULLIFY(pPatch%mixt%gradFace)
      END IF ! RFLU_DecideNeedBGradFace
    END DO ! iPatch
  END IF ! pGrid%nPatches

! ==============================================================================
! Grid motion. NOTE grid speeds are allocated separately because they are
! written into grid file, and hence they need to be allocated in pre- and
! postprocessors also.
! ==============================================================================

  IF ( pMixtInput%moveGrid .EQV. .TRUE. ) THEN

! ------------------------------------------------------------------------------
!   Residual
! ------------------------------------------------------------------------------

    ALLOCATE(pGrid%rhs(XCOORD:ZCOORD,pGrid%nVertTot),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,1138,'pGrid%rhs')
    END IF ! global%error

    DO icmp = XCOORD,ZCOORD ! Explicit loop to avoid Frost problem
      DO iv = 1,pGrid%nVertTot
        pGrid%rhs(icmp,iv) = 0.0_RFREAL
      END DO ! iv
    END DO ! icmp

! ------------------------------------------------------------------------------
!   Displacement
! ------------------------------------------------------------------------------

    IF ( pMixtInput%moveGridType /= MOVEGRID_TYPE_XYZ ) THEN
      ALLOCATE(pGrid%disp(XCOORD:ZCOORD,pGrid%nVertTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1155,'pGrid%disp')
      END IF ! global%error

      DO icmp = XCOORD,ZCOORD ! Explicit loop to avoid Frost problem
        DO iv = 1,pGrid%nVertTot
          pGrid%disp(icmp,iv) = 0.0_RFREAL
        END DO ! iv
      END DO ! icmp
    END IF ! pMixtInput%moveGridType

! ------------------------------------------------------------------------------
!   Old coordinates
! ------------------------------------------------------------------------------

    ALLOCATE(pGridOld%xyz(XCOORD:ZCOORD,pGrid%nVertTot),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,1172,'pRegion%gridOld%xyz')
    END IF ! global%error

    DO icmp = XCOORD,ZCOORD ! Explicit loop to avoid Frost problem
      DO iv = 1,pGrid%nVertTot
        pGridOld%xyz(icmp,iv) = 0.0_RFREAL
      END DO ! iv
    END DO ! icmp

    IF ( global%solverType == SOLV_IMPLICIT_NK ) THEN 
      ALLOCATE(pGridOld2%xyz(XCOORD:ZCOORD,pGrid%nVertTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1185,'pRegion%gridOld2%xyz')
      END IF ! global%error
  
      DO icmp = XCOORD,ZCOORD ! Explicit loop to avoid Frost problem
        DO iv = 1,pGrid%nVertTot
          pGridOld2%xyz(icmp,iv) = 0.0_RFREAL
        END DO ! iv
      END DO ! icmp
    END IF ! global%solverType

! ------------------------------------------------------------------------------
!   Old volume
! ------------------------------------------------------------------------------

    ALLOCATE(pGridOld%vol(pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,1202,'pRegion%gridOld%vol')
    END IF ! global%error

    DO ic = 1,pGrid%nCellsTot ! Explicit loop to avoid Frost problem
      pGridOld%vol(ic) = 0.0_RFREAL
    END DO ! ic

    IF ( global%solverType == SOLV_IMPLICIT_NK ) THEN 
      ALLOCATE(pGridOld2%vol(pGrid%nCellsTot),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1213,'pRegion%gridOld2%vol')
      END IF ! global%error
  
      DO ic = 1,pGrid%nCellsTot ! Explicit loop to avoid Frost problem
        pGridOld2%vol(ic) = 0.0_RFREAL
      END DO ! ic
    END IF ! global%solverType

! ------------------------------------------------------------------------------
!   Patch displacements. NOTE allocate here only if not running inside GENX,
!   because when running inside GENX allocate displacements also for virtual
!   vertices.
! ------------------------------------------------------------------------------

    IF ( pGrid%nPatches > 0 ) THEN
      DO iPatch = 1,pGrid%nPatches
        pPatch => pRegion%patches(iPatch)

        ALLOCATE(pPatch%dXyz(XCOORD:ZCOORD,pPatch%nBVert),STAT=errorFlag)
        global%error = errorFlag
        IF ( global%error /= ERR_NONE ) THEN
          CALL ErrorStop(global,ERR_ALLOCATE,1235,'pPatch%dXyz')
        END IF ! global%error

        DO icmp = XCOORD,ZCOORD ! Explicit loop to avoid Frost problem
          DO iv = 1,pPatch%nBVert
            pPatch%dXyz(icmp,iv) = 0.0_RFREAL
          END DO ! iv
        END DO ! icmp
      END DO ! iPatch
    END IF ! pGrid%nPatches
  END IF ! pMixtInput%moveGrid


! ==============================================================================
! Optimal LES
! ==============================================================================

  IF ( pMixtInput%spaceDiscr == DISCR_OPT_LES ) THEN
    CALL RFLU_CreateStencilsWeightsOLES(pRegion)
    CALL RFLU_CreateIntegralsOLES(pRegion)
  END IF ! pMixtInput%spaceDiscr

! ==============================================================================
! Substantial derivative. NOTE only needed for Equilibrium Eulerian method,
! but allocate anyway, because would need IF statement inside loops otherwise.
! ==============================================================================

  SELECT CASE ( pMixtInput%indSd )
    CASE ( 0 )
      arrayLimLow = 0
      arrayLimUpp = 1
    CASE ( 1 )
      arrayLimLow = 1
      arrayLimUpp = pGrid%nCellsTot
    CASE DEFAULT
      CALL ErrorStop(global,ERR_REACHED_DEFAULT,1287)
  END SELECT ! pMixtInput%indSd

  ALLOCATE(pRegion%mixt%sd(SD_XMOM:SD_ZMOM,arrayLimLow:arrayLimUpp), &
                           STAT=errorFlag)
  global%error = errorFlag
  IF ( global%error /= ERR_NONE ) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,1294,'pRegion%mixt%sd')
  END IF ! global%error

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemoryTStep






! ******************************************************************************
!
! Purpose: Allocate memory for mixture time-stepping for compressible fluid.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemoryTStep_C(pRegion)

  USE RFLU_ModOLES

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: arrayLimLow,arrayLimUpp,errorFlag,iPatch
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_patch), POINTER :: pPatch
  TYPE(t_global), POINTER :: global
  TYPE(t_mixt_input), POINTER :: pMixtInput  

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemoryTStep_C',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

! ==============================================================================
! Mass fluxes. NOTE only needed when solving additional scalar transport
! equations, but allocate anyway, because would need IF statement inside flux
! loops otherwise.
! ==============================================================================

  IF ( pMixtInput%indMfMixt == 1 ) THEN
    arrayLimLow = 1
    arrayLimUpp = pGrid%nFaces
  ELSE
    arrayLimLow = 0
    arrayLimUpp = 1
  END IF ! pMixtInput%indMfMixt

  ALLOCATE(pRegion%mixt%mfMixt(arrayLimLow:arrayLimUpp),STAT=errorFlag)
  global%error = errorFlag
  IF ( global%error /= ERR_NONE ) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,1387,'pRegion%mixt%mfMixt')
  END IF ! global%error

  IF ( pRegion%grid%nPatches > 0 ) THEN
    DO iPatch = 1,pRegion%grid%nPatches
      pPatch => pRegion%patches(iPatch)

      IF ( pMixtInput%indMfMixt == 1 ) THEN
        arrayLimLow = 1
        arrayLimUpp = pPatch%nBFaces
      ELSE
        arrayLimLow = 0
        arrayLimUpp = 1
      END IF ! pMixtInput%indMfMixt

      ALLOCATE(pPatch%mfMixt(arrayLimLow:arrayLimUpp),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1405,'pPatch%mfMixt')
      END IF ! global%error
    END DO ! iPatch
  END IF ! pRegion%grid%nPatches

! ==============================================================================
! Pressure correction, needed in non-dissipative implicit scheme of Hou-Mahesh.
! ==============================================================================

  IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN
    ALLOCATE(pRegion%mixt%delP(pGrid%nCellsTot),STAT=errorFlag)
    global%error = errorFlag
    IF (global%error /= ERR_NONE) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,1418,'pRegion%mixt%delP')
    END IF ! global%error
  END IF ! solverType

! ==============================================================================
! Face-normal speeds, needed in non-dissipative implicit scheme of Hou-Mahesh.
! ==============================================================================

  IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN
    ALLOCATE(pRegion%mixt%vfMixt(pGrid%nFaces),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,1430,'pRegion%mixt%vfMixt')
    END IF ! global%error

    ALLOCATE(pRegion%mixt%vfMixtOld(pGrid%nFaces),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,1436,'pRegion%mixt%vfMixtOld')
    END IF ! global%error
  END IF ! solverType

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemoryTStep_C





! ******************************************************************************
!
! Purpose: Allocate memory for mixture time-stepping for incompressible fluid.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemoryTStep_I(pRegion)

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  INTEGER :: errorFlag,iPatch
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_patch), POINTER :: pPatch
  TYPE(t_global), POINTER :: global 

! ******************************************************************************
! Start
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemoryTStep_I',"../modflu/RFLU_ModAllocateMemory.F90")

! ******************************************************************************
! Set pointers
! ******************************************************************************

  pGrid => pRegion%grid

! ******************************************************************************
! Allocate memory
! ******************************************************************************

! ==============================================================================
! Face velocities
! ==============================================================================

  ALLOCATE(pRegion%mixt%vfMixt(pGrid%nFaces),STAT=errorFlag)
  global%error = errorFlag
  IF ( global%error /= ERR_NONE ) THEN
    CALL ErrorStop(global,ERR_ALLOCATE,1515,'pRegion%mixt%vfMixt')
  END IF ! global%error

  IF ( pRegion%grid%nPatches > 0 ) THEN
    DO iPatch = 1,pRegion%grid%nPatches
      pPatch => pRegion%patches(iPatch)

      ALLOCATE(pPatch%vfMixt(pPatch%nBFaces),STAT=errorFlag)
      global%error = errorFlag
      IF ( global%error /= ERR_NONE ) THEN
        CALL ErrorStop(global,ERR_ALLOCATE,1525,'pPatch%vfMixt')
      END IF ! global%error
    END DO ! iPatch
  END IF ! pRegion%grid%nPatches

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemoryTStep_I





! ******************************************************************************
! End
! ******************************************************************************

END MODULE RFLU_ModAllocateMemory


! ******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_ModAllocateMemory.F90,v $
! Revision 1.2  2015/12/18 22:58:43  rahul
! Added AUSM+up in the memory allocation IF statement.
!
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:36  brollin
! New Stable version
!
! Revision 1.5  2009/07/08 19:11:43  mparmar
! Added allocation of cvRef
!
! Revision 1.4  2008/12/06 08:43:39  mtcampbe
! Updated license.
!
! Revision 1.3  2008/11/19 22:16:53  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.2  2007/11/28 23:05:16  mparmar
! Allocating memory for SOLV_IMPLICIT_HM specific arrays
!
! Revision 1.1  2007/04/09 18:49:23  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 18:00:39  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.14  2006/11/01 15:50:00  haselbac
! Changed so implicit-solver arrays dealt with properly
!
! Revision 1.13  2006/10/20 21:17:34  mparmar
! Fixed a bug in allocation of pPatch%mixt%gradFace
!
! Revision 1.12  2006/08/19 15:38:59  mparmar
! Moved region%mixt%bGradFace to patch%mixt%gradFace
!
! Revision 1.11  2006/02/08 21:03:16  hdewey2
! Added old2 quantities
!
! Revision 1.10  2006/01/07 10:16:33  wasistho
! STATS tav allocation to nCellsTot
!
! Revision 1.9  2005/10/31 21:09:36  haselbac
! Changed specModel and SPEC_MODEL_NONE
!
! Revision 1.8  2005/09/22 17:09:21  hdewey2
! Added allocation of cvOld1 and cvOld2 for transient implicit solver.
!
! Revision 1.7  2005/07/14 21:42:17  haselbac
! Added AUSM flux function to memory allocation IF statement
!
! Revision 1.6  2005/03/31 17:00:19  haselbac
! Changed allocation of sd
!
! Revision 1.5  2004/12/19 15:46:56  haselbac
! Added memory allocation for incompressible solver
!
! Revision 1.4  2004/11/02 02:30:22  haselbac
! Removed use of CV_MIXT_NEQS and init of cvInfo
!
! Revision 1.3  2004/10/19 19:27:44  haselbac
! Modified allocation criteria for grid speeds
!
! Revision 1.2  2004/07/30 22:47:36  jferry
! Implemented Equilibrium Eulerian method for Rocflu
!
! Revision 1.1  2004/03/19 21:15:19  haselbac
! Initial revision
!
! ******************************************************************************

