










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
! Purpose: Flow solver of Rocflu, essentially wrapper around time-stepping
!   routine.
!
! Description: None.
!
! Input: None.
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************
!
! $Id: RFLU_FlowSolver.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2002-2004 by the University of Illinois
!
! ******************************************************************************

SUBROUTINE RFLU_FlowSolver(dTimeSystem,dIterSystem,levels)

  USE ModDataTypes
  USE ModDataStruct, ONLY: t_level,t_region
  USE ModGlobal, ONLY: t_global
  USE ModError
  USE ModMPI
  USE ModParameters
  

  
  USE ModInterfaces, ONLY: RFLU_TimeStepping

  IMPLICIT NONE

! ******************************************************************************
! Arguments
! ******************************************************************************

  INTEGER, INTENT(IN) :: dIterSystem
  REAL(RFREAL), INTENT(IN) :: dTimeSystem
  TYPE(t_level), POINTER :: levels(:)  

! ******************************************************************************
! Locals
! ******************************************************************************

  CHARACTER(CHRLEN) :: RCSIdentString
  TYPE(t_region), POINTER :: pRegion,regions(:)
  TYPE(t_global), POINTER :: global

! ******************************************************************************
! Start
! ******************************************************************************

  RCSIdentString = '$RCSfile: RFLU_FlowSolver.F90,v $ $Revision: 1.1.1.1 $'

  global  => levels(1)%regions(1)%global
  regions => levels(1)%regions  

  global%dTimeSystem = dTimeSystem

  CALL RegisterFunction(global,'RFLU_FlowSolver',"../rocflu/RFLU_FlowSolver.F90")


! ******************************************************************************
! Start time stepping
! ******************************************************************************
                          
! ==============================================================================
! Write header for convergence history
! ==============================================================================

  IF ( global%myProcid==MASTERPROC .AND. global%verbLevel/=VERBOSE_NONE ) THEN
    IF ( global%flowType == FLOW_STEADY ) THEN 
      WRITE(STDOUT,1000) SOLVER_NAME,SOLVER_NAME
    ELSE IF ( global%flowType == FLOW_UNSTEADY ) THEN 
      WRITE(STDOUT,1010) SOLVER_NAME,SOLVER_NAME
    END IF ! global%flowType
  END IF ! global%myProcid


! ******************************************************************************
! Call time-stepping routines
! ******************************************************************************

  IF ( (global%solverType == SOLV_EXPLICIT) .OR. &
       (global%solverType == SOLV_IMPLICIT_HM) ) THEN      
    IF (global%cycleType == MGCYCLE_NO) THEN
      CALL RFLU_TimeStepping(dTimeSystem,dIterSystem,regions)
    ELSE 
      CALL ErrorStop(global,ERR_REACHED_DEFAULT,225)
    END IF ! global%cycleType
  ELSE 
  ENDIF ! global%solverType

! ******************************************************************************
! End
! ****************************************************************************** 
  
  
  CALL DeregisterFunction(global)

1000 FORMAT(A,2X,' iter',4X,'res-norm',5X,'force-x',6X,'force-y',6X,'force-z', &
            6X,'mass-in',6X,'mass-out',/,A,1X,84('-'))
1010 FORMAT(A,2X,' time',10X,'delta-t',6X,'force-x',6X,'force-y',6X,'force-z', &
            6X,'mass-in',6X,'mass-out'/,A,1X,90('-'))

END SUBROUTINE RFLU_FlowSolver

! ******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_FlowSolver.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:38  brollin
! New Stable version
!
! Revision 1.5  2009/08/28 18:29:48  mtcampbe
! RocfluMP integration with Rocstar and some makefile tweaks.  To build
! Rocstar with new Rocflu:
! make ROCFLU=RocfluMP
! To build Rocstar with the new RocfluND:
! make ROCFLU=RocfluMP HYPRE=/the/hypre/install/path
!
! Revision 1.4  2008/12/06 08:43:48  mtcampbe
! Updated license.
!
! Revision 1.3  2008/11/19 22:17:00  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.2  2007/11/28 23:05:30  mparmar
! Adding SOLV_IMPLICIT_HM solver
!
! Revision 1.1  2007/04/09 18:49:57  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 18:01:01  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.21  2005/09/14 15:59:33  haselbac
! Minor clean-up
!
! Revision 1.20  2005/09/13 20:49:39  mtcampbe
! Added profiling calls
!
! Revision 1.19  2005/08/03 18:30:32  hdewey2
! Add IF for solverType
!
! Revision 1.18  2005/08/02 18:26:14  hdewey2
! Added NK capability
!
! Revision 1.17  2004/10/19 19:29:17  haselbac
! Cosmetics only
!
! Revision 1.16  2003/06/20 22:34:58  haselbac
! Cosmetic changes
!
! Revision 1.15  2003/05/09 17:01:03  jiao
! Renamed the COM_call_function_handlers to COM_call_function.
!
! Revision 1.14  2003/03/05 20:39:31  jiao
! ACH: Added calls to get correct data at every time step inside/outside of PC
!
! Revision 1.13  2003/02/24 18:05:38  haselbac
! Bug fix and clean-up
!
! Revision 1.12  2003/02/24 17:25:20  haselbac
! Add geometry computation for PC iterations within GENX
!
! Revision 1.11  2003/02/24 14:50:33  haselbac
! Bug fix: Added missing initialization of timeStamp
!
! Revision 1.10  2002/10/19 22:22:23  haselbac
! Removed RFLU_GetBValues - not needed here with proper calls
!
! Revision 1.9  2002/10/19 16:13:19  haselbac
! Removed include for Roccom, cosmetic changes to output
!
! Revision 1.8  2002/10/17 20:04:52  haselbac
! Added timeSystem to argument list (GENX)
!
! Revision 1.7  2002/10/17 14:12:59  haselbac
! Added RFLU_GetBValues for proper restart (discussion with Jim J.)
!
! Revision 1.6  2002/10/05 19:21:30  haselbac
! GENX integration, some cosmetics
!
! Revision 1.5  2002/09/09 15:49:58  haselbac
! global now under regions
!
! Revision 1.4  2002/06/17 13:34:12  haselbac
! Prefixed SOLVER_NAME to all screen output
!
! Revision 1.3  2002/05/04 17:09:00  haselbac
! Uncommented writing of convergence file
!
! Revision 1.2  2002/04/11 19:02:21  haselbac
! Cosmetic changes and some preparation work
!
! Revision 1.1  2002/03/14 19:12:00  haselbac
! Initial revision
!
! ******************************************************************************

