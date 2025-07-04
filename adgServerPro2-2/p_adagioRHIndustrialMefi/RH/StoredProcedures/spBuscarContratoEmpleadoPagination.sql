USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [RH].[spBuscarContratoEmpleadoPagination](    
	@IDEmpleado int = null    
	,@IDContratoEmpleado int = null
	,@IDUsuario int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'
) AS    
BEGIN    
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
       ,@ID_TIPO_DOCUMENTO_CONTRATO VARCHAR(10) = '2-'
       ,@LABEL_ESTATUS_PENDIG VARCHAR(25) 
       ,@LABEL_ESTATUS_COMPLETED VARCHAR(25) 
       ,@ESTATUS_PENDING VARCHAR(15) = 'pending'
       ,@ESTATUS_COMPLETED VARCHAR(15) = 'completed'
       ,@IDIdiomaTblIdiomas VARCHAR(5)
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

     SELECT @IDIdiomaTblIdiomas=lower(replace(App.fnGetPreferencia('Idioma',@IDUsuario, 'esmx'), '-',''))

    SET @IDIdiomaTblIdiomas = CASE WHEN @IDIdiomaTblIdiomas='enus' THEN 'en-US' ELSE 'es-MX' END

        
    SELECT
           @LABEL_ESTATUS_PENDIG =  JSON_VALUE(Traduccion, '$.translate.LabelEstatusPendiente') 
          ,@LABEL_ESTATUS_COMPLETED = JSON_VALUE(Traduccion, '$.translate.LabelEstatusCompletado')           
        --   ,@LABEL_REMIND_DIARIO = JSON_VALUE(Traduccion, '$.translate.LabelRemindSemanal') 
        --   ,@LABEL_REMIND_TRES = JSON_VALUE(Traduccion, '$.translate.LabelRemindTresDias') 
        --   ,@LABEL_REMIND_SEMANAL = JSON_VALUE(Traduccion, '$.translate.LabelRemindSemanal') 
    FROM App.tblIdiomas
    WHERE IDIdioma = @IDIdiomaTblIdiomas;
    
	  SELECT     
		   CE.IDContratoEmpleado,    
		   CE.IDEmpleado,    
		   isnull(CE.IDTipoContrato,0) as IDTipoContrato,    
		   TC.Codigo,    
		   TC.Descripcion as TipoContrato,
		   isnull(CE.IDTipoTrabajador,0) as IDTipoTrabajador,     
		   isnull(tt.Descripcion,'') as TipoTrabajador,     
		   isnull(CE.IDDocumento,0) as IDDocumento,    
		   D.Descripcion ,    
		   cast(CE.FechaIni as date) as FechaIni,    
		   cast(CE.FechaFin as date) as FechaFin,    
		   isnull(ce.Duracion,0) as Duracion,    
		   ISNULL(ce.IDTipoDocumento,0) as IDTipoDocumento ,    
		   td.Descripcion as TipoDocumento,  
		   cast(isnull(d.EsContrato,0) as bit) as EsContrato
		   , ISNULL(CE.IDReferencia, 0) AS IDReferencia
		   ,ISNULL(CE.CalificacionEvaluacion, 0.00) AS CalificacionEvaluacion
           , docFd.Id AS IdFirmaDigital           
           ,CASE WHEN docFD.State = @ESTATUS_PENDING THEN @LABEL_ESTATUS_PENDIG 
                  WHEN docFD.state = @ESTATUS_COMPLETED THEN @LABEL_ESTATUS_COMPLETED
                  ELSE 'Sin solicitud de firma' END AS StateFirmaDigital
           , CASE 
                 WHEN (SELECT COUNT(*) FROM FirmaDigital.tblDocumentosFirmantes firmantes WHERE firmantes.ID = docFD.ID) = 0
                 THEN 'Sin firmantes'
                 ELSE CONVERT(VARCHAR(MAX), (SELECT COUNT(*) FROM FirmaDigital.tblDocumentosFirmantes firmantes WHERE firmantes.ID = docFD.ID AND firmantes.Signed = 1))
                + '/' + 
                CONVERT(VARCHAR(MAX), (SELECT COUNT(*) FROM FirmaDigital.tblDocumentosFirmantes firmantes WHERE firmantes.ID = docFD.ID))
             END AS ContadorFirmantes            
	  INTO #tempResponse
	  FROM RH.tblContratoEmpleado CE    
		LEft join Sat.tblCatTiposContrato TC    
			ON CE.IDTipoContrato = TC.IDTipoContrato    
		LEft join RH.tblCatDocumentos D    
			ON CE.IDDocumento = D.IDDocumento    
		LEft join RH.tblCatTipoDocumento td    
			ON td.IDTipoDocumento = ce.IDTipoDocumento    
		LEFT JOIN IMSS.tblCatTipoTrabajador tt
			ON tt.IDTipoTrabajador = ce.IDTipoTrabajador
        LEFT JOIN FirmaDigital.tblDocumentos docFD
            ON CONCAT(@ID_TIPO_DOCUMENTO_CONTRATO, CONVERT(VARCHAR(MAX), CE.IDContratoEmpleado)) = docFD.ExternalId        
	  WHERE CE.IDEmpleado = @IDEmpleado    
	   AND ((ce.IDContratoEmpleado = @IDContratoEmpleado) or (@IDContratoEmpleado = 0 OR @IDContratoEmpleado IS NULL))    
	   AND ((@query = '""' OR contains(d.*, @query)) OR
            (@query = '""' OR contains(td.*, @query)) OR
            (@query = '""' OR contains(tt.*, @query)) OR
            (@query = '""' OR contains(tc.*, @query)) 

       ) 
	ORDER BY CE.FechaIni Desc    

	SELECT @TotalPaginas =CEILING( cast(count(*) AS DECIMAL(20,2))/cast(@PageSize AS DECIMAL(20,2)))
	FROM #tempResponse

	SELECT @TotalRegistros = COUNT(IDContratoEmpleado) FROM #tempResponse		

	SELECT *
		,TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	FROM #tempResponse
	ORDER BY 
		CASE WHEN @orderByColumn = 'Descripcion'			AND @orderDirection = 'asc'		THEN Descripcion END,			
		CASE WHEN @orderByColumn = 'Descripcion'			AND @orderDirection = 'desc'	THEN Descripcion END DESC,	
        CASE WHEN @orderByColumn = 'FechaIni'			    AND @orderDirection = 'asc'		THEN FechaIni END,			
		CASE WHEN @orderByColumn = 'FechaIni'			    AND @orderDirection = 'desc'	THEN FechaIni END DESC,
		Codigo ASC

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
