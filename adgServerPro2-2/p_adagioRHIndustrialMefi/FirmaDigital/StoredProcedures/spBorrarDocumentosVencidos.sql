USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [FirmaDigital].[spBorrarDocumentosVencidos] as
BEGIN
	DECLARE	
         @FechaHoy date = GETDATE()      	        
        ,@IDUsuarioAdmin INT = 1      
        ,@SIGNED INT = 1  
        ,@STATE_COMPLETED VARCHAR(20) = 'completed'
	;

    
    IF object_id('tempdb..#tempDocumentosTrabajables') IS NOT NULL DROP TABLE #tempDocumentosTrabajables;



    SELECT *
    INTO #tempDocumentosTrabajables
    FROM FirmaDigital.tblDocumentos Documentos
    WHERE ExpiresAt IS NOT NULL 
      AND ISNULL(CAST(ExpiresAt AS DATE),'9999-12-31') < @FechaHoy 
      AND Signed <> @SIGNED
      AND [State] <> @STATE_COMPLETED
          



    IF NOT EXISTS(SELECT TOP 1 1 FROM #tempDocumentosTrabajables)
    BEGIN
        PRINT 'No existen documentos trabajables'
        RETURN;
    END

    
    DELETE [FirmaDigital].[tblDocumentosFirmantes]
	WHERE ID IN (SELECT ID FROM #tempDocumentosTrabajables)
	
    DELETE [FirmaDigital].[TblDocumentos]
	WHERE ID IN (SELECT ID FROM #tempDocumentosTrabajables)

    PRINT 'Se han eliminado los documentos vencidos correspondientes'

END
GO
