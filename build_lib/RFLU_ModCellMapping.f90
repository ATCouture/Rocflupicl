










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
! Purpose: Suite of routines to map cells.
!
! Description: None.
!
! Notes: None.
!
! ******************************************************************************
!
! $Id: RFLU_ModCellMapping.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2002-2005 by the University of Illinois
!
! ******************************************************************************

MODULE RFLU_ModCellMapping

  USE ModGlobal, ONLY: t_global
  USE ModDataTypes
  USE ModParameters
  USE ModError
  USE ModDataStruct, ONLY: t_region
  USE ModGrid, ONLY: t_grid
  USE ModMPI

  IMPLICIT NONE
  
  PRIVATE
  PUBLIC :: RFLU_BuildGlob2LocCellMapping, &
            RFLU_BuildLoc2GlobCellMapping, &              
            RFLU_CreateCellMapping, &
            RFLU_DestroyCellMapping, & 
            RFLU_NullifyCellMapping, & 
            RFLU_ReadLoc2GlobCellMapping, & 
            RFLU_WriteLoc2GlobCellMapping
  
! ******************************************************************************
! Declarations and definitions
! ******************************************************************************  
     
  CHARACTER(CHRLEN) :: & 
    RCSIdentString = '$RCSfile: RFLU_ModCellMapping.F90,v $ $Revision: 1.1.1.1 $' 
              
! ******************************************************************************
! Procedures
! ******************************************************************************

  CONTAINS
  









! ******************************************************************************
!
! Purpose: Build global-to-local cell mapping.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************
  
  SUBROUTINE RFLU_BuildGlob2LocCellMapping(pRegion)

    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************  

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion 

! ==============================================================================
!   Locals
! ==============================================================================

    CHARACTER(CHRLEN) :: errorString
    INTEGER :: icl,icg
    TYPE(t_grid), POINTER :: pGrid
    TYPE(t_global), POINTER :: global      

! ******************************************************************************  
!   Start
! ******************************************************************************  

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_BuildGlob2LocCellMapping',"../modflu/RFLU_ModCellMapping.F90")

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, & 
                               'Building global-to-local cell mapping...' 
    END IF ! global%verbLevel

! ******************************************************************************  
!   Set grid pointer
! ******************************************************************************  

    pGrid => pRegion%grid

! ******************************************************************************  
!   Build global-to-local cell mapping
! ******************************************************************************  

! ==============================================================================
!   Tetrahedra
! ==============================================================================

    IF ( pGrid%nTetsTot > 0 ) THEN 
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Tetrahedra...' 
      END IF ! global%myProcid     
    END IF ! pGrid%nTetsTot

    DO icl = 1,pGrid%nTetsTot       
      icg = pGrid%tet2CellGlob(icl)

      pGrid%cellGlob2Loc(1,icg) = CELL_TYPE_TET
      pGrid%cellGlob2Loc(2,icg) = icl
    END DO ! icl   

! ==============================================================================
!   Hexahedra
! ==============================================================================

    IF ( pGrid%nHexsTot > 0 ) THEN       
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Hexahedra...' 
      END IF ! global%myProcid    
    END IF ! pGrid%nHexsTot 

    DO icl = 1,pGrid%nHexsTot
      icg = pGrid%hex2CellGlob(icl)

      pGrid%cellGlob2Loc(1,icg) = CELL_TYPE_HEX
      pGrid%cellGlob2Loc(2,icg) = icl
    END DO ! icl

! ==============================================================================
!   Prisms
! ==============================================================================

    IF ( pGrid%nPrisTot > 0 ) THEN       
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Prisms...' 
      END IF ! global%myProcid 
    END IF ! pGrid%nPrisTot

    DO icl = 1,pGrid%nPrisTot
      icg = pGrid%pri2CellGlob(icl)

      pGrid%cellGlob2Loc(1,icg) = CELL_TYPE_PRI
      pGrid%cellGlob2Loc(2,icg) = icl
    END DO ! icl

! ==============================================================================
!   Pyramids
! ==============================================================================
      
    IF ( pGrid%nPyrsTot > 0 ) THEN
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Pyramids...' 
      END IF ! global%myProcid     
    END IF ! pGrid%nPyrsTot

    DO icl = 1,pGrid%nPyrsTot
      icg = pGrid%pyr2CellGlob(icl)

      pGrid%cellGlob2Loc(1,icg) = CELL_TYPE_PYR
      pGrid%cellGlob2Loc(2,icg) = icl
    END DO ! icl
     
! ******************************************************************************  
!   End
! ******************************************************************************  

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, & 
                               'Building global-to-local cell mapping done.'
    END IF ! global%myProcid

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_BuildGlob2LocCellMapping








! ******************************************************************************
!
! Purpose: Build local-to-global cell mapping.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************
  
  SUBROUTINE RFLU_BuildLoc2GlobCellMapping(pRegion)

    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************  

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion 

! ==============================================================================
!   Locals
! ==============================================================================

    CHARACTER(CHRLEN) :: errorString
    INTEGER :: icl,iclSumActual,iclSumVirtual,icg
    TYPE(t_grid), POINTER :: pGrid
    TYPE(t_global), POINTER :: global      

! ******************************************************************************  
!   Start
! ******************************************************************************  

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_BuildLoc2GlobCellMapping',"../modflu/RFLU_ModCellMapping.F90")

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, & 
                               'Building local-to-global cell mapping...' 
    END IF ! global%verbLevel

! ******************************************************************************  
!   Set grid pointer
! ******************************************************************************  

    pGrid => pRegion%grid

! ******************************************************************************  
!   Build local-to-global cell mapping
! ******************************************************************************  

    iclSumActual  = 0
    iclSumVirtual = pGrid%nCells

! ==============================================================================
!   Tetrahedra
! ==============================================================================

    IF ( pGrid%nTetsTot > 0 ) THEN 
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Tetrahedra...' 
      END IF ! global%myProcid     
    END IF ! pGrid%nTetsTot

    DO icl = 1,pGrid%nTets       
      iclSumActual = iclSumActual + 1
      icg = iclSumActual

      pGrid%tet2CellGlob(icl) = icg
    END DO ! icl

    DO icl = pGrid%nTets+1,pGrid%nTetsTot        
      iclSumVirtual = iclSumVirtual + 1
      icg = iclSumVirtual

      pGrid%tet2CellGlob(icl) = icg
    END DO ! icl      

! ==============================================================================
!   Hexahedra
! ==============================================================================

    IF ( pGrid%nHexsTot > 0 ) THEN       
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Hexahedra...' 
      END IF ! global%myProcid  
    END IF ! pGrid%nHexsTot

    DO icl = 1,pGrid%nHexs
      iclSumActual = iclSumActual + 1
      icg = iclSumActual

      pGrid%hex2CellGlob(icl) = icg
    END DO ! icl

    DO icl = pGrid%nHexs+1,pGrid%nHexsTot
      iclSumVirtual = iclSumVirtual + 1
      icg = iclSumVirtual

      pGrid%hex2CellGlob(icl) = icg
    END DO ! icl

! ==============================================================================
!   Prisms
! ==============================================================================

    IF ( pGrid%nPrisTot > 0 ) THEN       
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Prisms...' 
      END IF ! global%myProcid  
    END IF ! pGrid%nPrisTot

    DO icl = 1,pGrid%nPris
      iclSumActual = iclSumActual + 1
      icg = iclSumActual

      pGrid%pri2CellGlob(icl) = icg
    END DO ! icl

    DO icl = pGrid%nPris+1,pGrid%nPrisTot
      iclSumVirtual = iclSumVirtual + 1
      icg = iclSumVirtual

      pGrid%pri2CellGlob(icl) = icg
    END DO ! icl      

! ==============================================================================
!   Pyramids
! ==============================================================================

    IF ( pGrid%nPyrsTot > 0 ) THEN
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_NONE ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Pyramids...' 
      END IF ! global%myProcid      
    END IF ! pGrid%nPyrsTot

    DO icl = 1,pGrid%nPyrs
      iclSumActual = iclSumActual + 1
      icg = iclSumActual

      pGrid%pyr2CellGlob(icl) = icg
    END DO ! icl

    DO icl = pGrid%nPyrs+1,pGrid%nPyrsTot
      iclSumVirtual = iclSumVirtual + 1
      icg = iclSumVirtual

      pGrid%pyr2CellGlob(icl) = icg
    END DO ! icl      

! ******************************************************************************  
!   End
! ******************************************************************************  

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, & 
                               'Building local-to-global cell mapping done.'
    END IF ! global%myProcid

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_BuildLoc2GlobCellMapping


  
  
  
! ******************************************************************************
!
! Purpose: Create cell mapping.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

  SUBROUTINE RFLU_CreateCellMapping(pRegion)

    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************  

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion 

! ==============================================================================
!   Locals
! ==============================================================================

    INTEGER :: errorFlag
    TYPE(t_grid), POINTER :: pGrid
    TYPE(t_global), POINTER :: global

! ******************************************************************************  
!   Start
! ******************************************************************************  

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_CreateCellMapping',"../modflu/RFLU_ModCellMapping.F90")

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN             
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Creating cell mapping...' 
    END IF ! global%myProcid

! ******************************************************************************  
!   Nullify
! ******************************************************************************  

    CALL RFLU_NullifyCellMapping(pRegion)

! ******************************************************************************  
!   Set grid pointer
! ******************************************************************************  

    pGrid => pRegion%grid

! ******************************************************************************  
!   Allocate memory
! ******************************************************************************  

    ALLOCATE(pGrid%cellGlob2Loc(2,pGrid%nCellsMax),STAT=errorFlag)      
    global%error = errorFlag   
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_ALLOCATE,519,'pGrid%cellGlob2Loc')
    END IF ! global%error

    IF ( pGrid%nTetsMax > 0 ) THEN             
      ALLOCATE(pGrid%tet2CellGlob(pGrid%nTetsMax),STAT=errorFlag)
      global%error = errorFlag   
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_ALLOCATE,526,'pGrid%tet2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nTetsMax

    IF ( pGrid%nHexsMax > 0 ) THEN       
      ALLOCATE(pGrid%hex2CellGlob(pGrid%nHexsMax),STAT=errorFlag)
      global%error = errorFlag   
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_ALLOCATE,534,'pGrid%hex2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nHexsMax

    IF ( pGrid%nPrisMax > 0 ) THEN       
      ALLOCATE(pGrid%pri2CellGlob(pGrid%nPrisMax),STAT=errorFlag)
      global%error = errorFlag   
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_ALLOCATE,542,'pGrid%pri2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nPrisMax

    IF ( pGrid%nPyrsMax > 0 ) THEN
      ALLOCATE(pGrid%pyr2CellGlob(pGrid%nPyrsMax),STAT=errorFlag)
      global%error = errorFlag   
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_ALLOCATE,550,'pGrid%pyr2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nPyrsMax

! ******************************************************************************  
!   End
! ******************************************************************************  

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Creating cell mappings done.'        
    END IF ! global%myProcid

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_CreateCellMapping   
  
  
  
  
  
  
! ******************************************************************************
!
! Purpose: Destroy cell mappings.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************
    
  SUBROUTINE RFLU_DestroyCellMapping(pRegion)

    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************  

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion 

! ==============================================================================
!   Locals
! ==============================================================================

    INTEGER :: errorFlag
    TYPE(t_grid), POINTER :: pGrid
    TYPE(t_global), POINTER :: global

! ******************************************************************************  
!   Start
! ******************************************************************************  

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_DestroyCellMapping',"../modflu/RFLU_ModCellMapping.F90")

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Destroying cell mapping...' 
    END IF ! global%myProcid

! ******************************************************************************  
!   Set grid pointer
! ******************************************************************************  

    pGrid => pRegion%grid

! ******************************************************************************  
!   Deallocate memory
! ******************************************************************************  

    DEALLOCATE(pGrid%cellGlob2Loc,STAT=errorFlag)
    global%error = errorFlag   
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_DEALLOCATE,635,'pGrid%cellGlob2Loc')
    END IF ! global%error

    IF ( pGrid%nTetsMax > 0 ) THEN             
      DEALLOCATE(pGrid%tet2CellGlob,STAT=errorFlag)
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_DEALLOCATE,641,'pGrid%tet2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nTetsMax 

    IF ( pGrid%nHexsMax > 0 ) THEN       
      DEALLOCATE(pGrid%hex2CellGlob,STAT=errorFlag)
      global%error = errorFlag   
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_DEALLOCATE,649,'pGrid%hex2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nHexsMax

    IF ( pGrid%nPrisMax > 0 ) THEN       
      DEALLOCATE(pGrid%pri2CellGlob,STAT=errorFlag)
      global%error = errorFlag   
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_DEALLOCATE,657,'pGrid%pri2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nPrisMax

    IF ( pGrid%nPyrsMax > 0 ) THEN
      DEALLOCATE(pGrid%pyr2CellGlob,STAT=errorFlag)
      global%error = errorFlag   
      IF ( global%error /= ERR_NONE ) THEN 
        CALL ErrorStop(global,ERR_DEALLOCATE,665,'pGrid%pyr2CellGlob')
      END IF ! global%error
    END IF ! pGrid%nPyrsMax

! ******************************************************************************  
!   Nullify cell mapping
! ******************************************************************************  

    CALL RFLU_NullifyCellMapping(pRegion)

! ******************************************************************************  
!   End
! ******************************************************************************  

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Destroying cell mapping done.'
    END IF ! global%myProcid

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_DestroyCellMapping






! ******************************************************************************
!
! Purpose: Nullify cell mapping.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

  SUBROUTINE RFLU_NullifyCellMapping(pRegion)

    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************  

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion 

! ==============================================================================
!   Locals
! ==============================================================================

    TYPE(t_grid), POINTER :: pGrid
    TYPE(t_global), POINTER :: global

! ******************************************************************************  
!   Start
! ******************************************************************************  

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_NullifyCellMapping',"../modflu/RFLU_ModCellMapping.F90")

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN             
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Nullifying cell mapping...' 
    END IF ! global%verbLevel

! ******************************************************************************  
!   Set grid pointer
! ******************************************************************************  

    pGrid => pRegion%grid

! ******************************************************************************  
!   Nullify memory
! ******************************************************************************  

    NULLIFY(pGrid%cellGlob2Loc)

    NULLIFY(pGrid%tet2CellGlob)
    NULLIFY(pGrid%hex2CellGlob)
    NULLIFY(pGrid%pri2CellGlob)
    NULLIFY(pGrid%pyr2CellGlob)

! ******************************************************************************  
!   End
! ******************************************************************************  

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN   
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Nullifying cell mapping done.'        
    END IF ! global%verbLevel

    CALL DeregisterFunction(global)

  END SUBROUTINE RFLU_NullifyCellMapping 






! ******************************************************************************
!
! Purpose: Read local-to-global cell mapping.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

  SUBROUTINE RFLU_ReadLoc2GlobCellMapping(pRegion)

    USE ModBuildFileNames, ONLY: BuildFileNameBasic

    IMPLICIT NONE
  
! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************  

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion  
   
! ==============================================================================
!   Local variables
! ==============================================================================

    INTEGER :: errorFlag,icg,iFile,loopCounter,nHexsTot,nPrisTot,nPyrsTot, & 
               nTetsTot
    CHARACTER(CHRLEN) :: iFileName,sectionString
    TYPE(t_grid), POINTER :: pGrid  
    TYPE(t_global), POINTER :: global
    
! ******************************************************************************
!   Start
! ******************************************************************************

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_ReadLoc2GlobCellMapping',"../modflu/RFLU_ModCellMapping.F90")

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, & 
                               'Reading local-to-global cell mapping...'
      WRITE(STDOUT,'(A,3X,A,1X,I5.5)') SOLVER_NAME,'Global region:', & 
                                       pRegion%iRegionGlobal 
    END IF ! global%myProcid

    iFile = IF_CELL_MAPS

    CALL BuildFileNameBasic(global,FILEDEST_INDIR,'.cmp', & 
                            pRegion%iRegionGlobal,iFileName) 

    OPEN(iFile,FILE=iFileName,FORM="FORMATTED",STATUS="OLD",IOSTAT=errorFlag)   
    global%error = errorFlag        
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_FILE_OPEN,842,iFileName)
    END IF ! global%error

! ******************************************************************************
!   Header and general information
! ******************************************************************************

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_LOW ) THEN
      WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Header information...'
    END IF ! global%myProcid

    READ(iFile,'(A)') sectionString 
    IF ( TRIM(sectionString) /= '# ROCFLU cell mapping file' ) THEN 
      CALL ErrorStop(global,ERR_INVALID_MARKER,856,sectionString) 
    END IF ! TRIM

! ******************************************************************************
!   Dimensions
! ******************************************************************************
  
    pGrid => pRegion%grid  

    READ(iFile,'(A)') sectionString 
    IF ( TRIM(sectionString) /= '# Dimensions' ) THEN 
      CALL ErrorStop(global,ERR_INVALID_MARKER,867,sectionString)
    END IF ! TRIM

    READ(iFile,'(4(I16))') nTetsTot,nHexsTot,nPrisTot,nPyrsTot

! ******************************************************************************
!   Check dimensions (against those read from dimensions file)
! ******************************************************************************

    IF ( nTetsTot /= pGrid%nTetsTot ) THEN 
      CALL ErrorStop(global,ERR_DIMENS_INVALID,877)
    END IF ! nTetsTot
    
    IF ( nHexsTot /= pGrid%nHexsTot ) THEN 
      CALL ErrorStop(global,ERR_DIMENS_INVALID,881)
    END IF ! nHexsTot    

    IF ( nPrisTot /= pGrid%nPrisTot ) THEN 
      CALL ErrorStop(global,ERR_DIMENS_INVALID,885)
    END IF ! nPrisTot
    
    IF ( nPyrsTot /= pGrid%nPyrsTot ) THEN 
      CALL ErrorStop(global,ERR_DIMENS_INVALID,889)
    END IF ! nPyrsTot        
    
! ******************************************************************************
!   Rest of file
! ==============================================================================

    loopCounter = 0

    DO ! set up infinite loop
      loopCounter = loopCounter + 1
    
      READ(iFile,'(A)') sectionString
    
      SELECT CASE ( TRIM(sectionString) ) 

! ==============================================================================
!       Tetrahedra
! ==============================================================================

        CASE ( '# Tetrahedra' ) 
          IF ( global%myProcid == MASTERPROC .AND. &
               global%verbLevel > VERBOSE_LOW ) THEN 
            WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Tetrahedra...'
          END IF ! global%myProcid 
              
          READ(iFile,'(10(I16))') (pGrid%tet2CellGlob(icg),icg=1,pGrid%nTetsTot)
    
! ==============================================================================
!       Hexahedra
! ==============================================================================

        CASE ( '# Hexahedra' ) 
          IF ( global%myProcid == MASTERPROC .AND. &
               global%verbLevel > VERBOSE_LOW ) THEN  
            WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Hexahedra...'
          END IF ! global%myProcid
              
          READ(iFile,'(10(I16))') (pGrid%hex2CellGlob(icg),icg=1,pGrid%nHexsTot)

! ==============================================================================
!       Prisms
! ==============================================================================

        CASE ( '# Prisms' ) 
          IF ( global%myProcid == MASTERPROC .AND. &
               global%verbLevel > VERBOSE_LOW ) THEN  
            WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Prisms...'
          END IF ! global%myProcid
              
          READ(iFile,'(10(I16))') (pGrid%pri2CellGlob(icg),icg=1,pGrid%nPrisTot)

! ==============================================================================
!       Pyramids
! ==============================================================================

        CASE ( '# Pyramids' ) 
          IF ( global%myProcid == MASTERPROC .AND. &
               global%verbLevel > VERBOSE_LOW ) THEN 
            WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Pyramids...'
          END IF ! global%myProcid
              
          READ(iFile,'(10(I16))') (pGrid%pyr2CellGlob(icg),icg=1,pGrid%nPyrsTot)
   
! ==============================================================================
!       End marker
! ==============================================================================
      
        CASE ( '# End' ) 
          IF ( global%myProcid == MASTERPROC .AND. &
               global%verbLevel > VERBOSE_LOW ) THEN  
            WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'End marker...'
          END IF ! global%myProcid   

          EXIT
      
! ==============================================================================
!       Invalid section string
! ==============================================================================
      
        CASE DEFAULT
          IF ( global%myProcid == MASTERPROC .AND. &
               global%verbLevel > VERBOSE_LOW ) THEN  
            WRITE(STDOUT,'(3X,A)') sectionString
          END IF ! global%myProcid        

          CALL ErrorStop(global,ERR_INVALID_MARKER,975,sectionString)
      END SELECT ! TRIM
  
! ==============================================================================
!     Guard against infinite loop - might be unnecessary because of read errors?
! ==============================================================================  

      IF ( loopCounter >= LIMIT_INFINITE_LOOP ) THEN 
        CALL ErrorStop(global,ERR_INFINITE_LOOP,983)
      END IF ! loopCounter  
    END DO ! <empty>
   
! ******************************************************************************
!   Close file
! ******************************************************************************

    CLOSE(iFile,IOSTAT=errorFlag)
    global%error = errorFlag      
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_FILE_CLOSE,994,iFileName)
    END IF ! global%error

! ******************************************************************************
!   End
! ******************************************************************************

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, & 
                               'Reading local-to-global cell mapping done.'
    END IF ! global%myProcid

    CALL DeregisterFunction(global)
  
  END SUBROUTINE RFLU_ReadLoc2GlobCellMapping







! ******************************************************************************
!
! Purpose: Write local-to-global cell mapping.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************

  SUBROUTINE RFLU_WriteLoc2GlobCellMapping(pRegion)

    USE ModBuildFileNames, ONLY: BuildFileNameBasic

    IMPLICIT NONE
  
! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************  

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion  
   
! ==============================================================================
!   Local variables
! ==============================================================================

    INTEGER :: errorFlag,icg,iFile
    CHARACTER(CHRLEN) :: iFileName,sectionString
    TYPE(t_grid), POINTER :: pGrid
    TYPE(t_global), POINTER :: global
    
! ******************************************************************************
!   Start
! ******************************************************************************

    global => pRegion%global

    CALL RegisterFunction(global,'RFLU_WriteLoc2GlobCellMapping',"../modflu/RFLU_ModCellMapping.F90")

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, &
                               'Writing local-to-global cell mapping...'
      WRITE(STDOUT,'(A,3X,A,1X,I5.5)') SOLVER_NAME,'Global region:', & 
                                       pRegion%iRegionGlobal 
    END IF ! global%myProcid

    iFile = IF_CELL_MAPS

    CALL BuildFileNameBasic(global,FILEDEST_INDIR,'.cmp', & 
                            pRegion%iRegionGlobal,iFileName) 

    OPEN(iFile,FILE=iFileName,FORM="FORMATTED",STATUS="UNKNOWN", & 
         IOSTAT=errorFlag)   
    global%error = errorFlag        
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_FILE_OPEN,1082,iFileName)
    END IF ! global%error

! ******************************************************************************
!   Header and general information
! ******************************************************************************

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_LOW ) THEN
      WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Header information...'
    END IF ! global%myProcid

    sectionString = '# ROCFLU cell mapping file'  
    WRITE(iFile,'(A)') TRIM(sectionString)  

! ******************************************************************************
!   Dimensions
! ******************************************************************************
  
    pGrid => pRegion%grid  

    sectionString = '# Dimensions'
    WRITE(iFile,'(A)') TRIM(sectionString) 
    WRITE(iFile,'(4(I16))') pGrid%nTetsTot,pGrid%nHexsTot,pGrid%nPrisTot, & 
                           pGrid%nPyrsTot
    
! ******************************************************************************
!   Tetrahedra
! ******************************************************************************

    IF ( pGrid%nTetsTot > 0 ) THEN 
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_LOW ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Tetrahedra...'
      END IF ! global%myProcid    
    
      sectionString = '# Tetrahedra'  
      WRITE(iFile,'(A)') TRIM(sectionString)      
      WRITE(iFile,'(10(I16))') (pGrid%tet2CellGlob(icg),icg=1,pGrid%nTetsTot)    
    END IF ! pGrid%nTetsTot

! ******************************************************************************
!   Hexahedra
! ******************************************************************************

    IF ( pGrid%nHexsTot > 0 ) THEN 
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_LOW ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Hexahedra...'
      END IF ! global%myProcid       
    
      sectionString = '# Hexahedra'  
      WRITE(iFile,'(A)') TRIM(sectionString)      
      WRITE(iFile,'(10(I16))') (pGrid%hex2CellGlob(icg),icg=1,pGrid%nHexsTot)    
    END IF ! pGrid%nHexsTot
    
! ******************************************************************************
!   Prisms
! ******************************************************************************

    IF ( pGrid%nPrisTot > 0 ) THEN 
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_LOW ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Prisms...'
      END IF ! global%myProcid 

      sectionString = '# Prisms'  
      WRITE(iFile,'(A)') TRIM(sectionString)      
      WRITE(iFile,'(10(I16))') (pGrid%pri2CellGlob(icg),icg=1,pGrid%nPrisTot)    
    END IF ! pGrid%nPrisTot    
    
! ******************************************************************************
!   Pyramids
! ******************************************************************************

    IF ( pGrid%nPyrsTot > 0 ) THEN 
      IF ( global%myProcid == MASTERPROC .AND. &
           global%verbLevel > VERBOSE_LOW ) THEN
        WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Pyramids...'
      END IF ! global%myProcid 

      sectionString = '# Pyramids'  
      WRITE(iFile,'(A)') TRIM(sectionString)      
      WRITE(iFile,'(10(I16))') (pGrid%pyr2CellGlob(icg),icg=1,pGrid%nPyrsTot)    
    END IF ! pGrid%nPyrsTot     
    
! ******************************************************************************
!   End marker
! ******************************************************************************

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_LOW ) THEN  
      WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'End marker...'
    END IF ! global%myProcid

    sectionString = '# End'
    WRITE(iFile,'(A)') TRIM(sectionString) 

! ******************************************************************************
!   Close file
! ******************************************************************************

    CLOSE(iFile,IOSTAT=errorFlag)
    global%error = errorFlag      
    IF ( global%error /= ERR_NONE ) THEN 
      CALL ErrorStop(global,ERR_FILE_CLOSE,1187,iFileName)
    END IF ! global%error

! ******************************************************************************
!   End
! ******************************************************************************

    IF ( global%myProcid == MASTERPROC .AND. &
         global%verbLevel > VERBOSE_NONE ) THEN
      WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME, &
                               'Writing local-to-global cell mapping done.'
    END IF ! global%myProcid

    CALL DeregisterFunction(global)
  
  END SUBROUTINE RFLU_WriteLoc2GlobCellMapping








! ******************************************************************************
! End
! ******************************************************************************
  
END MODULE RFLU_ModCellMapping


! ******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_ModCellMapping.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.4  2008/12/06 08:43:39  mtcampbe
! Updated license.
!
! Revision 1.3  2008/11/19 22:16:54  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.2  2007/08/07 17:18:44  haselbac
! Reordered routines into proper order
!
! Revision 1.1  2007/04/09 18:49:24  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 18:00:39  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.14  2005/04/15 15:06:47  haselbac
! Small bug fix (use Max instead of Tot), cosmetics
!
! Revision 1.13  2004/12/04 03:26:53  haselbac
! Substantial rewrite to maximize code reuse for partitioning
!
! Revision 1.12  2004/11/03 17:01:36  haselbac
! Rewrite because of removal of vertex anc cell flags, cosmetics
!                                                      
! Revision 1.11  2004/01/22 16:03:58  haselbac                                           
! Made contents of modules PRIVATE, only procs PUBLIC, to avoid errors on ALC 
! and titan  
!
! Revision 1.10  2003/11/25 21:03:21  haselbac                                           
! Improved error reporting for invalid cell flags                                        
!
! Revision 1.9  2003/06/04 22:08:30  haselbac                                            
! Added Nullify routines, some cosmetics                                                 
!
! Revision 1.8  2003/03/15 18:03:21  haselbac                                            
! Adaptation for || 1, removed Charm calls to separate routine                        
!
! Revision 1.7  2003/01/28 16:26:03  haselbac                                            
! Cosmetics only                                                                         
!
! Revision 1.6  2002/10/19 16:31:15  haselbac                                            
! Bug fix in output for parallel runs - missing if statement                             
!
! Revision 1.5  2002/10/08 15:49:21  haselbac                                            
! {IO}STAT=global%error replaced by {IO}STAT=errorFlag - SGI problem                     
!
! Revision 1.4  2002/09/10 20:30:27  haselbac                                            
! Corrected bug in RFLU_BuildCellMapping                                                 
!
! Revision 1.3  2002/09/09 15:02:31  haselbac                                            
! global now under regions                                                               
!
! Revision 1.2  2002/07/25 14:59:31  haselbac                                            
! Only write out for MASTERPROC, commented out FEM calls, added RFLU_ModFEM              
!
! Revision 1.1  2002/06/27 15:48:16  haselbac                                            
! Initial revision                                                                       
!
! ******************************************************************************

