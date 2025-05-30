










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
! Purpose: Allocate mixture memory for vertex variables.
!
! Description: None.
!
! Input: 
!   pRegion     Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************
!
! $Id: RFLU_AllocateMemoryVert.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2004-2005 by the University of Illinois
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemoryVert(pRegion)

  USE ModDataTypes
  USE ModError
  USE ModGlobal, ONLY: t_global
  USE ModParameters
  USE ModGrid, ONLY: t_grid
  USE ModDataStruct, ONLY: t_region
  USE ModMixture, ONLY: t_mixt_input
  USE ModMPI
      
  IMPLICIT NONE

! ******************************************************************************
! Declarations and definitions
! ******************************************************************************

! ==============================================================================
! Parameters
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================  
! Locals
! ==============================================================================  

  CHARACTER(CHRLEN) :: RCSIdentString
  INTEGER :: errorFlag
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_mixt_input), POINTER :: pMixtInput
  TYPE(t_global), POINTER :: global

! ******************************************************************************
! Start
! ******************************************************************************

  RCSIdentString = & 
    '$RCSfile: RFLU_AllocateMemoryVert.F90,v $ $Revision: 1.1.1.1 $'

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemoryVert', &
                        "../../utilities/post/RFLU_AllocateMemoryVert.F90")

! ******************************************************************************
! Set pointers 
! ******************************************************************************

  pGrid      => pRegion%grid
  pMixtInput => pRegion%mixtInput

! ******************************************************************************
! Allocate memory
! ******************************************************************************

! ==============================================================================  
! Conserved variables
! ==============================================================================  
  
  ALLOCATE(pRegion%mixt%cvVert(CV_MIXT_DENS:CV_MIXT_ENER,pGrid%nVertTot), & 
           STAT=errorFlag)
  global%error = errorFlag           
  IF ( global%error /= ERR_NONE ) THEN 
    CALL ErrorStop(global,ERR_ALLOCATE,138,'pRegion%mixt%cvVert')
  END IF ! global%error  

! ==============================================================================  
! Dependent variables  
! ==============================================================================  

  IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN 
    IF ( pRegion%mixtInput%flowModel == FLOW_NAVST ) THEN
      ALLOCATE(pRegion%mixt%dvVert(DV_MIXT_TEMP:DV_MIXT_TEMP,pGrid%nVertTot), &
               STAT=errorFlag)
      global%error = errorFlag           
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_ALLOCATE,151,'pRegion%mixt%dvVert')
      END IF ! global%error  
    END IF ! pRegion%mixtInput%flowModel 
  ELSE
    ALLOCATE(pRegion%mixt%dvVert(pMixtInput%nDv,pGrid%nVertTot),STAT=errorFlag)
    global%error = errorFlag           
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_ALLOCATE,158,'pRegion%mixt%dvVert')
    END IF ! global%error  
  END IF ! global%solverType
    
! ==============================================================================  
! Gas variables 
! ==============================================================================  

  IF ( pMixtInput%nGvAct == 0 ) THEN
    ALLOCATE(pRegion%mixt%gvVert(pMixtInput%nGv,0:1),STAT=errorFlag)
  ELSE
    ALLOCATE(pRegion%mixt%gvVert(pMixtInput%nGv,pGrid%nVertTot),STAT=errorFlag)
  END IF ! pMixtInput%nGvAct
  global%error = errorFlag           
  IF ( global%error /= ERR_NONE ) THEN 
    CALL ErrorStop(global,ERR_ALLOCATE,173,'pRegion%mixt%gvVert')
  END IF ! global%error   

! ******************************************************************************
! End
! ******************************************************************************

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemoryVert

! ******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_AllocateMemoryVert.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.4  2008/12/06 08:43:57  mtcampbe
! Updated license.
!
! Revision 1.3  2008/11/19 22:17:11  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.2  2007/11/28 23:05:45  mparmar
! Made allocation of dvVert consistent with SOLV_IMPLICIT_HM
!
! Revision 1.1  2007/04/09 18:58:08  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.6  2006/04/07 15:19:26  haselbac
! Removed tabs
!
! Revision 1.5  2006/03/13 15:39:21  haselbac
! Bug fix: Incorrect allocation of gvVert
!
! Revision 1.4  2005/11/14 17:04:43  haselbac
! Generalized to support pseudo-gas model
!
! Revision 1.3  2005/11/10 02:46:22  haselbac
! Cosmetics only
!
! Revision 1.2  2005/10/31 21:09:39  haselbac
! Changed specModel and SPEC_MODEL_NONE
!
! Revision 1.1  2004/02/26 21:01:21  haselbac
! Initial revision
!
! ******************************************************************************

