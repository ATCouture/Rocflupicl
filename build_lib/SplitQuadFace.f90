










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
! Purpose: Indicate which way quad face should be split into two triangular 
!   faces.
!
! Description: None.
!
! Input:
!   xyz         Coordinates of the four vertices
!
! Output:
!   splitFlag   Flag indicating whether face should be split along diagonal
!               13 or 24. If splitFlag == FACE_SPLIT_13, face should be split
!               along diagonal 13, giving the two triangular faces 123 and 134.
!               IF splitFlag == FACE_SPLIT_24, face should be split along
!               diagonal 24, giving the two triangular faces 124 and 234.
!
! Notes: None.
!
!******************************************************************************
!
! $Id: SplitQuadFace.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2002 by the University of Illinois
!
!******************************************************************************

SUBROUTINE SplitQuadFace( global,xyz1,xyz2,xyz3,xyz4,splitFlag )

  USE ModDataTypes
  USE ModParameters
  USE ModError
  USE ModGlobal, ONLY     : t_global
  USE ModInterfaces, ONLY : FaceVectorTria
   
  IMPLICIT NONE

! ... parameters
  TYPE(t_global), POINTER :: global

  INTEGER, INTENT(OUT) :: splitFlag

  REAL(RFREAL), DIMENSION(3), INTENT(IN) :: xyz1, xyz2, xyz3, xyz4

! ... local variables
  CHARACTER(CHRLEN) :: RCSIdentString

  REAL(RFREAL) :: fVecX1, fVecX2, fVecY1, fVecY2, fVecZ1, fVecZ2, mag1, mag2, & 
                  prod1, prod2
  REAL(RFREAL) :: xyzNodes(3,3)

!******************************************************************************

  RCSIdentString = '$RCSfile: SplitQuadFace.F90,v $ $Revision: 1.1.1.1 $'

  CALL RegisterFunction( global,'SplitQuadFace',"../libfloflu/SplitQuadFace.F90" )

! Start -----------------------------------------------------------------------
 
! Split along diagonal 13: subdivision 123-134 
 
  xyzNodes(1:3,1) = xyz1(1:3)
  xyzNodes(1:3,2) = xyz2(1:3)
  xyzNodes(1:3,3) = xyz3(1:3)    
 
  CALL FaceVectorTria( xyzNodes,fVecX1,fVecY1,fVecZ1 )

  xyzNodes(1:3,1) = xyz1(1:3)
  xyzNodes(1:3,2) = xyz3(1:3)
  xyzNodes(1:3,3) = xyz4(1:3)    

  CALL FaceVectorTria( xyzNodes,fVecX2,fVecY2,fVecZ2 )

  mag1  = SQRT(fVecX1*fVecX1 + fVecY1*fVecY1 + fVecZ1*fVecZ1)
  mag2  = SQRT(fVecX2*fVecX2 + fVecY2*fVecY2 + fVecZ2*fVecZ2)
  prod1 = (fVecX1*fVecX2 + fVecY1*fVecY2 + fVecZ1*fVecZ2)/(mag1*mag2) 

  IF (prod1 < 0.0_RFREAL) THEN 
    CALL ErrorStop( global,ERR_FACE_SPLIT,131 )
  ENDIF ! prod1

! Split along diagonal 24: subdivision 124-234 
 
  xyzNodes(1:3,1) = xyz1(1:3)
  xyzNodes(1:3,2) = xyz2(1:3)
  xyzNodes(1:3,3) = xyz4(1:3)    
 
  CALL FaceVectorTria( xyzNodes,fVecX1,fVecY1,fVecZ1 )

  xyzNodes(1:3,1) = xyz2(1:3)
  xyzNodes(1:3,2) = xyz3(1:3)
  xyzNodes(1:3,3) = xyz4(1:3)    

  CALL FaceVectorTria( xyzNodes,fVecX2,fVecY2,fVecZ2 )

  mag1  = SQRT(fVecX1*fVecX1 + fVecY1*fVecY1 + fVecZ1*fVecZ1)
  mag2  = SQRT(fVecX2*fVecX2 + fVecY2*fVecY2 + fVecZ2*fVecZ2)
  prod2 = (fVecX1*fVecX2 + fVecY1*fVecY2 + fVecZ1*fVecZ2)/(mag1*mag2)

  IF (prod2 < 0.0_RFREAL) THEN 
    CALL ErrorStop( global,ERR_FACE_SPLIT,153 )
  ENDIF ! prod2

! Better subdivision is that which has smaller dotproduct

  IF (prod1 < prod2) THEN 
    splitFlag = FACE_SPLIT_13
  ELSE 
    splitFlag = FACE_SPLIT_24
  ENDIF ! prod1<prod2

! finalize --------------------------------------------------------------------

  CALL DeregisterFunction( global )

END SUBROUTINE SplitQuadFace

!******************************************************************************
!
! RCS Revision history:
!
! $Log: SplitQuadFace.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.3  2008/12/06 08:43:32  mtcampbe
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
! Revision 1.1  2004/12/01 16:51:33  haselbac
! Initial revision after changing case
!
! Revision 1.3  2002/10/27 18:48:59  haselbac
! Removed tabs
!
! Revision 1.2  2002/09/05 17:40:20  jblazek
! Variable global moved into regions().
!
! Revision 1.1  2002/03/01 17:07:13  haselbac
! Initial revision
!
!******************************************************************************

