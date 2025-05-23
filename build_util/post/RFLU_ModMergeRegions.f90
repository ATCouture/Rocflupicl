










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
! Purpose: Suite of routines to merge regions.
!
! Description: None.
!
! Notes: None.
!
! ******************************************************************************
!
! $Id: RFLU_ModMergeRegions.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2004-2005 by the University of Illinois
!
! ******************************************************************************

MODULE RFLU_ModMergeRegions

  USE ModGlobal, ONLY: t_global
  USE ModDataTypes
  USE ModParameters
  USE ModError
  USE ModBndPatch, ONLY: t_patch
  USE ModDataStruct, ONLY: t_level,t_region
  USE ModGrid, ONLY: t_grid
  USE ModMPI

  IMPLICIT NONE
  
  PRIVATE
  PUBLIC :: RFLU_MERG_MergeGrid, & 
            RFLU_MERG_MergePatchCoeffs, & 
            RFLU_MERG_MergeSolWrapper

! ******************************************************************************
! Declarations and definitions
! ******************************************************************************

  CHARACTER(CHRLEN) :: & 
    RCSIdentString = '$RCSfile: RFLU_ModMergeRegions.F90,v $ $Revision: 1.1.1.1 $'


! ******************************************************************************
! Routines
! ******************************************************************************

  CONTAINS








! ******************************************************************************
!
! Purpose: Merge grids.
!
! Description: None.
!
! Input:
!   pRegion             Pointer to region
!   pRegionSerial       Pointer to serial region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

  SUBROUTINE RFLU_MERG_MergeGrid(pRegion,pRegionSerial)

    IMPLICIT NONE
      
! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion,pRegionSerial   

! ==============================================================================
!   Locals
! ==============================================================================

    INTEGER :: icg,icg2,icl,icl2,ict2,ifl,ifl2,iPatch,ivg,ivl,ivg2,offs
    TYPE(t_grid), POINTER :: pGrid,pGridSerial
    TYPE(t_global), POINTER :: global
    TYPE(t_patch), POINTER :: pPatch,pPatchSerial
      
! ******************************************************************************
!   Start
! ******************************************************************************

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_MERG_MergeGrid',"../../utilities/post/RFLU_ModMergeRegions.F90")

    IF ( global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Merging grid...' 
    END IF ! global%verbLevel

    IF ( global%verbLevel > VERBOSE_LOW ) THEN        
      WRITE(STDOUT,'(A,3X,A,1X,I5.5)') SOLVER_NAME,'Global region:', & 
                                       pRegion%iRegionGlobal          
    END IF ! global%verbLevel

! ******************************************************************************
!   Set pointers
! ******************************************************************************

    pGrid       => pRegion%grid
    pGridSerial => pRegionSerial%grid

! ******************************************************************************
!   Vertex coordinates
! ******************************************************************************    

    IF ( global%verbLevel > VERBOSE_LOW ) THEN
      WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Merging vertex coordinates...' 
    END IF ! global%verbLevel

    DO ivg = 1,pGrid%nVertTot
      ivg2 = pGrid%pv2sv(ivg)
      
      pGridSerial%xyz(XCOORD,ivg2) = pGrid%xyz(XCOORD,ivg)
      pGridSerial%xyz(YCOORD,ivg2) = pGrid%xyz(YCOORD,ivg)
      pGridSerial%xyz(ZCOORD,ivg2) = pGrid%xyz(ZCOORD,ivg)            
    END DO ! ivg
    
! ******************************************************************************
!   Cell connectivity
! ******************************************************************************    

    IF ( global%verbLevel > VERBOSE_LOW ) THEN
      WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Merging cell connectivity...' 
    END IF ! global%verbLevel
    
! ==============================================================================
!   Tetrahedra
! ==============================================================================

    IF ( (global%verbLevel > VERBOSE_LOW) .AND. (pGrid%nTetsTot > 0) ) THEN
      WRITE(STDOUT,'(A,5X,A)') SOLVER_NAME,'Tetrahedra...' 
    END IF ! global%verbLevel

    DO icl = 1,pGrid%nTetsTot
      icg  = pGrid%tet2CellGlob(icl)
      icg2 = pGrid%pc2sc(icg)

      ict2 = pGridSerial%cellGlob2Loc(1,icg2)
      icl2 = pGridSerial%cellGlob2Loc(2,icg2)
     
      IF ( ict2 /= CELL_TYPE_TET ) THEN 
        CALL ErrorStop(global,ERR_CELL_TYPE_INVALID,211)          
      END IF ! ict2
          
      DO ivl = 1,4
        ivg  = pGrid%tet2v(ivl,icl)
        ivg2 = pGrid%pv2sv(ivg)
        
        pGridSerial%tet2v(ivl,icl2) = ivg2
      END DO ! ivl
    END DO ! icl

! ==============================================================================
!   Hexahedra
! ==============================================================================
         
    IF ( (global%verbLevel > VERBOSE_LOW) .AND. (pGrid%nHexsTot > 0) ) THEN
      WRITE(STDOUT,'(A,5X,A)') SOLVER_NAME,'Hexahedra...' 
    END IF ! global%verbLevel
  
    DO icl = 1,pGrid%nHexsTot
      icg  = pGrid%hex2CellGlob(icl)
      icg2 = pGrid%pc2sc(icg)

      ict2 = pGridSerial%cellGlob2Loc(1,icg2)
      icl2 = pGridSerial%cellGlob2Loc(2,icg2)
     
      IF ( ict2 /= CELL_TYPE_HEX ) THEN 
        CALL ErrorStop(global,ERR_CELL_TYPE_INVALID,238)           
      END IF ! ict2
          
      DO ivl = 1,8
        ivg  = pGrid%hex2v(ivl,icl)
        ivg2 = pGrid%pv2sv(ivg)
        
        pGridSerial%hex2v(ivl,icl2) = ivg2
      END DO ! ivl
    END DO ! icl  

! ==============================================================================
!   Prisms
! ==============================================================================
    
    IF ( (global%verbLevel > VERBOSE_LOW) .AND. (pGrid%nPrisTot > 0) ) THEN
      WRITE(STDOUT,'(A,5X,A)') SOLVER_NAME,'Prisms...' 
    END IF ! global%verbLevel

    DO icl = 1,pGrid%nPrisTot
      icg  = pGrid%pri2CellGlob(icl)
      icg2 = pGrid%pc2sc(icg)
      
      ict2 = pGridSerial%cellGlob2Loc(1,icg2)
      icl2 = pGridSerial%cellGlob2Loc(2,icg2)
     
      IF ( ict2 /= CELL_TYPE_PRI ) THEN 
        CALL ErrorStop(global,ERR_CELL_TYPE_INVALID,265)            
      END IF ! ict2
    
      DO ivl = 1,6
        ivg  = pGrid%pri2v(ivl,icl)
        ivg2 = pGrid%pv2sv(ivg)
        
        pGridSerial%pri2v(ivl,icl2) = ivg2
      END DO ! ivl
    END DO ! icl

! ==============================================================================
!   Pyramids
! ==============================================================================
    
    IF ( (global%verbLevel > VERBOSE_LOW) .AND. (pGrid%nPyrsTot > 0) ) THEN
      WRITE(STDOUT,'(A,5X,A)') SOLVER_NAME,'Pyramids...' 
    END IF ! global%verbLevel

    DO icl = 1,pGrid%nPyrsTot
      icg  = pGrid%pyr2CellGlob(icl)
      icg2 = pGrid%pc2sc(icg)

      ict2 = pGridSerial%cellGlob2Loc(1,icg2)
      icl2 = pGridSerial%cellGlob2Loc(2,icg2)
     
      IF ( ict2 /= CELL_TYPE_PYR ) THEN 
        CALL ErrorStop(global,ERR_CELL_TYPE_INVALID,292)            
      END IF ! ict2
          
      DO ivl = 1,5
        ivg  = pGrid%pyr2v(ivl,icl)
        ivg2 = pGrid%pv2sv(ivg)
        
        pGridSerial%pyr2v(ivl,icl2) = ivg2
      END DO ! ivl
    END DO ! icl                     

! ******************************************************************************
!   Patch connectivity
! ******************************************************************************    

    IF ( global%myProcid == MASTERPROC .AND. & 
         global%verbLevel > VERBOSE_LOW ) THEN
      WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Merging patch connectivity...' 
    END IF ! global%verbLevel
    
! ==============================================================================
!   Loop over patches
! ==============================================================================

    DO iPatch = 1,pGrid%nPatches
      pPatch => pRegion%patches(iPatch)            
      pPatchSerial => pRegionSerial%patches(pPatch%iPatchGlobal)

      IF ( global%verbLevel > VERBOSE_LOW ) THEN
        WRITE(STDOUT,'(A,5X,A,2(1X,I2))') SOLVER_NAME,'Patch:',iPatch, &
                                          pPatch%iPatchGlobal 
      END IF ! global%verbLevel

! ------------------------------------------------------------------------------
!     Triangles
! ------------------------------------------------------------------------------

      IF ( (global%verbLevel > VERBOSE_LOW) .AND. (pPatch%nBTrisTot > 0) ) THEN
        WRITE(STDOUT,'(A,7X,A)') SOLVER_NAME,'Triangles...' 
      END IF ! global%verbLevel

      offs = pGrid%pbf2sbfCSRInfo(iPatch) - 1 
      
      DO ifl = 1,pPatch%nBTrisTot
        ifl2 = pGrid%pbf2sbfCSR(offs+ifl)
      
        DO ivl = 1,3
          ivg  = pPatch%bTri2v(ivl,ifl)
          ivg2 = pGrid%pv2sv(ivg)
          
          pPatchSerial%bTri2v(ivl,ifl2) = ivg2
        END DO ! ivl
      END DO ! ifl

! ------------------------------------------------------------------------------
!     Quadrilaterals
! ------------------------------------------------------------------------------
      
      IF ( (global%verbLevel > VERBOSE_LOW) .AND. (pPatch%nBQuadsTot > 0) ) THEN
        WRITE(STDOUT,'(A,7X,A)') SOLVER_NAME,'Quadrilaterals...' 
      END IF ! global%verbLevel

      offs = offs + pPatch%nBTrisTot
                
      DO ifl = 1,pPatch%nBQuadsTot
        ifl2 = pGrid%pbf2sbfCSR(offs+ifl) - pPatchSerial%nBTrisTot
     
        DO ivl = 1,4
          ivg  = pPatch%bQuad2v(ivl,ifl)
          ivg2 = pGrid%pv2sv(ivg)
          
          pPatchSerial%bQuad2v(ivl,ifl2) = ivg2          
        END DO ! ivl        
      END DO ! ifl
    END DO ! iPatch
            
! ******************************************************************************
!   End
! ******************************************************************************

    IF ( global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Merging grid done.'
    END IF ! global%verbLevel

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_MERG_MergeGrid








! ******************************************************************************
!
! Purpose: Merge patch coefficients.
!
! Description: None.
!
! Input:
!   pRegion             Pointer to region
!   pRegionSerial       Pointer to serial region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

  SUBROUTINE RFLU_MERG_MergePatchCoeffs(pRegion,pRegionSerial)

    IMPLICIT NONE
      
! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion,pRegionSerial

! ==============================================================================
!   Locals
! ==============================================================================

    INTEGER :: ifl,ifl2,iPatch,offs
    TYPE(t_global), POINTER :: global
    TYPE(t_grid), POINTER :: pGrid,pGridSerial
    TYPE(t_patch), POINTER :: pPatch,pPatchSerial
      
! ******************************************************************************
!   Start
! ******************************************************************************

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_MERG_MergePatchCoeffs',"../../utilities/post/RFLU_ModMergeRegions.F90")

    IF ( global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Merging patch coefficients...' 
    END IF ! global%verbLevel

    IF ( global%verbLevel > VERBOSE_LOW ) THEN        
      WRITE(STDOUT,'(A,3X,A,1X,I5.5)') SOLVER_NAME,'Global region:', & 
                                       pRegion%iRegionGlobal          
    END IF ! global%verbLevel

! ******************************************************************************
!   Set pointers
! ******************************************************************************

    pGrid       => pRegion%grid
    pGridSerial => pRegionSerial%grid

! ******************************************************************************
!   Merge patch coefficients 
! ******************************************************************************    
    
    DO iPatch = 1,pGrid%nPatches
      pPatch => pRegion%patches(iPatch)

      pPatchSerial => pRegionSerial%patches(pPatch%iPatchGlobal)

      offs = pGrid%pbf2sbfCSRInfo(iPatch) - 1

      DO ifl = 1,pPatch%nBTris
        ifl2 = pGrid%pbf2sbfCSR(offs+ifl)

        pPatchSerial%cp(       ifl2) = pPatch%cp(       ifl)
        pPatchSerial%cf(XCOORD,ifl2) = pPatch%cf(XCOORD,ifl)
        pPatchSerial%cf(YCOORD,ifl2) = pPatch%cf(YCOORD,ifl)
        pPatchSerial%cf(ZCOORD,ifl2) = pPatch%cf(ZCOORD,ifl)
        pPatchSerial%ch(       ifl2) = pPatch%ch(       ifl)
      END DO ! ifl

      offs = offs + pPatch%nBTrisTot

      DO ifl = 1,pPatch%nBQuads
        ifl2 = pGrid%pbf2sbfCSR(offs+ifl)

        pPatchSerial%cp(       ifl2) = pPatch%cp(       ifl)
        pPatchSerial%cf(XCOORD,ifl2) = pPatch%cf(XCOORD,ifl)
        pPatchSerial%cf(YCOORD,ifl2) = pPatch%cf(YCOORD,ifl)
        pPatchSerial%cf(ZCOORD,ifl2) = pPatch%cf(ZCOORD,ifl)
        pPatchSerial%ch(       ifl2) = pPatch%ch(       ifl)
      END DO ! ifl
    END DO ! iPatch

! ******************************************************************************
!   End
! ******************************************************************************

    IF ( global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Merging patch coefficients done.'
    END IF ! global%verbLevel

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_MERG_MergePatchCoeffs









! ******************************************************************************
!
! Purpose: Merge solution
!
! Description: None.
!
! Input:
!   pRegion             Pointer to region
!   pRegionSerial       Pointer to serial region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

  SUBROUTINE RFLU_MERG_MergeSolWrapper(pRegion,pRegionSerial)

    USE RFLU_ModCopyData, ONLY: RFLU_COPY_CellDataP2S_R2D, & 
                                RFLU_COPY_CellDataP2S_R3D


    IMPLICIT NONE
      
! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion,pRegionSerial

! ==============================================================================
!   Locals
! ==============================================================================

    INTEGER :: icg,icg2
    REAL(RFREAL), DIMENSION(:,:), POINTER :: pCv,pCvSerial
    TYPE(t_grid), POINTER :: pGrid
    TYPE(t_global), POINTER :: global
      
! ******************************************************************************
!   Start
! ******************************************************************************

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_MERG_MergeSolWrapper',"../../utilities/post/RFLU_ModMergeRegions.F90")

    IF ( global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Merging solution...' 
    END IF ! global%verbLevel

    IF ( global%verbLevel > VERBOSE_LOW ) THEN        
      WRITE(STDOUT,'(A,3X,A,1X,I5.5)') SOLVER_NAME,'Global region:', & 
                                       pRegion%iRegionGlobal          
    END IF ! global%verbLevel

! ******************************************************************************
!   Set pointers
! ******************************************************************************

    pGrid => pRegion%grid

! ******************************************************************************
!   Merge solutions
! ******************************************************************************    
    
! ==============================================================================
!   Mixture 
! ==============================================================================

    IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN
      pRegionSerial%mixt%cvState = CV_MIXT_STATE_DUVWP
    ELSE
      pRegionSerial%mixt%cvState = CV_MIXT_STATE_CONS
    END IF ! global%solverType    

    CALL RFLU_COPY_CellDataP2S_R2D(global,pGrid,pRegion%mixt%cv, & 
                                   pRegionSerial%mixt%cv)

    IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN
      CALL RFLU_COPY_CellDataP2S_R2D(global,pGrid,pRegion%mixt%cvOld, & 
                                     pRegionSerial%mixt%cvOld)
    END IF ! global%solverType

! ==============================================================================
!   Physical modules
! ==============================================================================

! ------------------------------------------------------------------------------
!   Species
! ------------------------------------------------------------------------------

    IF ( global%specUsed .EQV. .TRUE. ) THEN
      pRegionSerial%spec%cvState = CV_MIXT_STATE_CONS    
     
      CALL RFLU_COPY_CellDataP2S_R2D(global,pGrid,pRegion%spec%cv, &
                                     pRegionSerial%spec%cv)

      IF ( pRegion%specInput%nSpeciesEE > 0 ) THEN 
        CALL RFLU_COPY_CellDataP2S_R3D(global,pGrid,pRegion%spec%eev, &
                                       pRegionSerial%spec%eev)
      END IF ! pRegion%specInput%nSpeciesEE
    END IF ! global%specUsed


! ******************************************************************************
!   End
! ******************************************************************************

    IF ( global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Merging solution done.'
    END IF ! global%verbLevel

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_MERG_MergeSolWrapper










! ******************************************************************************
! End
! ******************************************************************************
  
END MODULE RFLU_ModMergeRegions


! ******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_ModMergeRegions.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.5  2010/03/15 01:04:18  mparmar
! Added support for auxiliary data
!
! Revision 1.4  2008/12/06 08:43:58  mtcampbe
! Updated license.
!
! Revision 1.3  2008/11/19 22:17:12  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.2  2007/11/28 23:05:51  mparmar
! Added reading of aux vars and dimensionalization of cv,dv
!
! Revision 1.1  2007/04/09 18:58:09  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.8  2007/03/12 23:33:02  haselbac
! Prepared code for merging of particles
!
! Revision 1.7  2006/12/18 02:32:34  haselbac
! Bug fixes: Needed nXTots to get merging to work with SYPE
!
! Revision 1.6  2006/04/07 15:19:26  haselbac
! Removed tabs
!
! Revision 1.5  2005/11/27 02:00:57  haselbac
! Bug fix: Missing cvState, added merging for EEv
!
! Revision 1.4  2005/08/19 02:36:02  haselbac
! Adapted to changes in RFLU_ModCopyData
!
! Revision 1.3  2005/04/15 15:08:33  haselbac
! Added routine to merge patch coeffs, general clean-up
!
! Revision 1.2  2005/01/17 19:52:07  haselbac
! Removed debug statements
!
! Revision 1.1  2004/12/29 20:58:54  haselbac
! Initial revision
!
! ******************************************************************************

