










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
! Purpose: read in user input related to position of a probe.
!
! Description: none.
!
! Input: user input file.
!
! Output: global = location of probe, dump intervall.
!
! Notes: none.
!
!******************************************************************************
!
! $Id: ReadProbeSection.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2001 by the University of Illinois
!
!******************************************************************************

SUBROUTINE ReadProbeSection( global )

  USE ModDataTypes
  USE ModGlobal, ONLY     : t_global
  USE ModInterfaces, ONLY : ReadListSection, ReadSection
  USE ModError
  USE ModParameters
  IMPLICIT NONE

! ... parameters
  TYPE(t_global), POINTER :: global

! ... loop variables
  INTEGER :: ival, n

! ... local variables
  CHARACTER(10) :: keys(3)  
  LOGICAL :: defined(3)
  INTEGER :: errorFlag, nCols, nRows  
  REAL(RFREAL) :: valsDump(3)
  REAL(RFREAL), POINTER :: valsLoc(:,:)

!******************************************************************************

  CALL RegisterFunction( global,'ReadProbeSection',"../libfloflu/ReadProbeSection.F90" )

! do not read probes a second time

! TEMPORARY - Will be fixed properly later, when we will have routines to 
!             create and destroy probes. Error trapping apparently only needed
!             because reading this again will cause allocation to be executed
!             again. This is a problem for rflumap.
!  IF ( global%nProbes > 0 ) THEN 
!    CALL ErrorStop(global,ERR_PROBE_SPECIFIED,106)
!  END IF ! global%nProbes
  
  IF ( global%nProbes == 0 ) THEN 
! END TEMPORARY  

! specify keywords and search for them

  defined = .FALSE.

  keys(1) = 'NUMBER'
  nCols   = 3

  CALL ReadListSection(global,IF_INPUT,keys(1),nCols,nRows,valsLoc,defined(1))

  IF ( defined(1) .EQV. .TRUE. ) THEN
    global%nProbes = nRows

    ALLOCATE(global%probePos(nRows,PROBE_REGION:PROBE_CELL),STAT=errorFlag)
    global%error = errorFlag
    IF (global%error /= 0) THEN 
      CALL ErrorStop(global,ERR_ALLOCATE,127)    
    END IF ! global%error
    
    DO ival = 1,global%nProbes
      DO n = PROBE_REGION,PROBE_CELL
        global%probePos(ival,n) = CRAZY_VALUE_INT
      END DO ! n
    END DO ! ival    
    
    ALLOCATE(global%probeXYZ(nRows,nCols),STAT=errorFlag)
    global%error = errorFlag
    IF (global%error /= 0) THEN 
      CALL ErrorStop(global,ERR_ALLOCATE,139)
    END IF ! global%error

    DO ival = 1,global%nProbes
      DO n = 1,nCols
        global%probeXYZ(ival,n) = valsLoc(ival,n)
      END DO ! n
    END DO ! ival    
  END IF ! defined  

  IF ( defined(1) .EQV. .TRUE. ) THEN
    DEALLOCATE(valsLoc,STAT=errorFlag)
    global%error = errorFlag
    IF (global%error /= 0) THEN 
      CALL ErrorStop(global,ERR_DEALLOCATE,153)
    END IF ! global%error
  END IF ! defined

! get dump interval

  defined(:) = .FALSE.

  keys(1) = 'WRITIME'
  keys(2) = 'WRIITER'
  keys(3) = 'OPENCLOSE'

  CALL ReadSection(global,IF_INPUT,3,keys,valsDump,defined)

  IF ( defined(1) .EQV. .TRUE. ) THEN 
    global%probeSaveTime = ABS(valsDump(1))
  END IF ! defined
  IF ( defined(2) .EQV. .TRUE. ) THEN
    global%probeSaveIter = INT(ABS(valsDump(2))+0.5_RFREAL)
    global%probeSaveIter = MAX(1,global%probeSaveIter)
  END IF ! defined
  IF ( defined(3) .EQV. .TRUE. ) THEN
    IF ( valsDump(3) < 0.5_RFREAL ) THEN
      global%probeOpenClose = .FALSE.
    ELSE
      global%probeOpenClose = .TRUE.
    END IF ! valsDump
  END IF ! defined

! TEMPORARY - See comment above
  END IF ! global%nProbes
! END TEMPORARY

! finalize

  CALL DeregisterFunction( global )

END SUBROUTINE ReadProbeSection

!******************************************************************************
!
! RCS Revision history:
!
! $Log: ReadProbeSection.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.3  2008/12/06 08:43:32  mtcampbe
! Updated license.
!
! Revision 1.2  2008/11/19 22:16:47  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.1  2007/04/09 18:48:33  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 17:59:25  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.2  2006/03/25 02:17:57  wasistho
! added safety when certain params not exist
!
! Revision 1.1  2004/12/01 16:50:44  haselbac
! Initial revision after changing case
!
! Revision 1.17  2004/11/11 14:49:56  haselbac
! Commented out error check for probes, bypass for now
!
! Revision 1.16  2004/08/09 22:14:42  fnajjar
! Changed apostrophe in comment line since SUN compiler breaks
!
! Revision 1.15  2004/07/21 21:11:42  wasistho
! allow probes input by coordinates
!
! Revision 1.14.2.1  2004/07/02 04:09:27  rfiedler
! Allows Rocflo probes to be specified by coordinates.  Use 0 for the block ID.
!
! Revision 1.14  2003/11/20 16:40:35  mdbrandy
! Backing out RocfluidMP changes from 11-17-03
!
! Revision 1.11  2003/05/15 02:57:02  jblazek
! Inlined index function.
!
! Revision 1.10  2003/04/07 14:18:40  haselbac
! Added new options for 1
!
! Revision 1.9  2003/01/23 17:48:53  jblazek
! Changed algorithm to dump convergence, solution and probe data.
!
! Revision 1.8  2002/10/08 15:48:35  haselbac
! {IO}STAT=global%error replaced by {IO}STAT=errorFlag - SGI problem
!
! Revision 1.7  2002/10/05 18:37:11  haselbac
! Added allocation of probeXyz
!
! Revision 1.6  2002/09/05 17:40:20  jblazek
! Variable global moved into regions().
!
! Revision 1.5  2002/03/26 19:07:20  haselbac
! Added ROCFLU functionality
!
! Revision 1.4  2002/02/09 01:47:01  jblazek
! Added multi-probe option, residual smoothing, physical time step.
!
! Revision 1.3  2002/01/11 17:18:31  jblazek
! Updated description of I/O variables.
!
! Revision 1.2  2001/12/22 00:09:38  jblazek
! Added routines to store grid and solution.
!
! Revision 1.1  2001/12/07 16:54:31  jblazek
! Added files to read user input.
!
!******************************************************************************

