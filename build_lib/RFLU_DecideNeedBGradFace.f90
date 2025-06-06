










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
!******************************************************************************
!
! Purpose: Determine whether need boundary face gradients and related functions
!
! Description: None.
!
! Input:
!   pRegion			Pointer to region data
!   pPatch                      Pointer to Patch data
!
! Output: 
!
! Notes: None.
!
!******************************************************************************
!
! $Id: RFLU_DecideNeedBGradFace.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2003-2004 by the University of Illinois
!
!******************************************************************************

LOGICAL FUNCTION RFLU_DecideNeedBGradFace(pRegion,pPatch)

  USE ModDataTypes
  USE ModError
  USE ModParameters
  USE ModGlobal, ONLY: t_global
  USE ModBndPatch, ONLY: t_patch
  USE ModDataStruct, ONLY: t_region
      
  IMPLICIT NONE

! *****************************************************************************
! Declarations and definitions
! *****************************************************************************

! =============================================================================
! Arguments
! =============================================================================

  TYPE(t_patch), POINTER :: pPatch
  TYPE(t_region), POINTER :: pRegion

! =============================================================================
! Locals
! =============================================================================

  CHARACTER(CHRLEN) :: RCSIdentString
  TYPE(t_global), POINTER :: global

! *****************************************************************************
! Start
! *****************************************************************************

  global => pRegion%global

  RCSIdentString = '$RCSfile: RFLU_DecideNeedBGradFace.F90,v $'

  CALL RegisterFunction(global,'RFLU_DecideNeedBGradFace',"../libflu/RFLU_DecideNeedBGradFace.F90")

! *****************************************************************************
! Initialize
! *****************************************************************************

  RFLU_DecideNeedBGradFace = .FALSE.
  
! *****************************************************************************
! Determine whether need boundary face gradients 
! *****************************************************************************

! =============================================================================
! Flow Model - true if Navier Stokes
! =============================================================================

  IF ( pRegion%mixtInput%flowModel == FLOW_NAVST ) THEN
    RFLU_DecideNeedBGradFace = .TRUE.
  END IF ! pRegion%mixtInput%flowModel 

! =============================================================================
! Boundary Condition Kind - true if NSCBC
! =============================================================================

  IF ( pPatch%bcKind == BC_KIND_NSCBC ) THEN
    RFLU_DecideNeedBGradFace = .TRUE.
  END IF ! pPatch%bcKind

! =============================================================================
! Virtual boundary - always false
! =============================================================================

  IF ( pPatch%bcType == BC_VIRTUAL ) THEN
    RFLU_DecideNeedBGradFace = .FALSE.
  END IF ! pPatch%bcType

! *****************************************************************************
! End
! *****************************************************************************

  CALL DeregisterFunction(global)

END FUNCTION RFLU_DecideNeedBGradFace

!******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_DecideNeedBGradFace.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.3  2008/12/06 08:43:35  mtcampbe
! Updated license.
!
! Revision 1.2  2008/11/19 22:16:50  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.1  2007/04/09 18:48:52  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 17:59:49  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2006/08/19 15:37:35  mparmar
! Initial revision
!
!******************************************************************************

