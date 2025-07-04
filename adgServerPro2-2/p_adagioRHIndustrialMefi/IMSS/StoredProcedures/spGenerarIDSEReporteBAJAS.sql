USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarIDSEReporteBAJAS]
(        
	@FechaIni date = '1900-01-01',                      
	@Fechafin date = '9999-12-31',                      
	@AfectaIDSE bit = 0,        
	@FechaIDSE date = '9999-12-31',           
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY,
	@IDUsuario int     
)        
AS        
BEGIN        
        
	declare @IDRegPatronal int
	 , @dtEmpleados RH.dtEmpleados;

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')    
    

    insert into @dtEmpleados      
    exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario    


	IF OBJECT_ID('tempdb..#TempValores') IS NOT NULL DROP TABLE #TempValores;      
        
	select  
		[App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS        
		+ [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL        
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Paterno,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ', 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Materno,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ', 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ', 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))   
		+ [App].[fnAddString](15,'0','0',2) -- FILLER    
		+ [App].[fnAddString](8,ISNULL(FORMAT(mov.Fecha, 'ddMMyyyy'),''),'0',2) -- FECHA DE MOVIMIENTO       
		+ [App].[fnAddString](5,'','',2) -- FILLER    
		+ [App].[fnAddString](2,'02',' ',2) -- Movimiento    
		+ [App].[fnAddString](5,RTRIM(substring(UPPER(COALESCE(rp.SubDelegacionIMSS,'')+''+COALESCE('400','')),1,27 )),'',2) -- DELEGACION    
		+ [App].[fnAddString](10,e.ClaveEmpleado,' ',2) -- ClaveEmpleado    
		+ [App].[fnAddString](1,
			CASE WHEN mov.IDTipoRazonMovimiento IS NOT NULL THEN TRM.Codigo
				ELSE
					CASE WHEN RMA.IDRazonMovimiento IS NOT NULL AND RMA.IDCatTipoRazonMovimiento IS NOT NULL THEN  TRM2.Codigo    
						ELSE 
							CASE WHEN RMA.Descripcion = 'AUSENTISMOS' THEN '7'     
								WHEN RMA.Descripcion = 'RENUNCIA VOLUNTARIA' then '2'    
								WHEN RMA.Descripcion = 'RESCISION DE CONTRATO' then '8'    
								WHEN RMA.Descripcion = 'TERMINO DE CONTRATO' then '1'    
								WHEN RMA.Descripcion = 'SEPARACION VOLUNTARIA' then '2'    
								WHEN RMA.Descripcion = 'DEFUNCION' then '4'    
								ELSE '6' 
							END
                    END
				END
				,'6',2) -- TIPO RAZON DE MOVIMIENTO   
		+ [App].[fnAddString](18,'','',2) -- FILLER    
		+ [App].[fnAddString](1,'9','9',2) as valor -- Identificador    
		, mov.IDMovAfiliatorio    
	into #TempValores    
	from IMSS.tblMovAfiliatorios mov  with(nolock)
		INNER JOIN @dtEmpleados E   on mov.IDEmpleado = e.IDEmpleado
			AND mov.Fecha BETWEEN @FechaIni and @Fechafin        
			AND mov.IDRegPatronal = @IDRegPatronal   
			AND mov.FechaIDSE IS NULL        
		INNER JOIN rh.tblCatRegPatronal rp  with(nolock) on rp.IDRegPatronal = @IDRegPatronal    
		INNER JOIN IMSS.tblCatTipoMovimientos tm  with(nolock) on mov.IDTipoMovimiento = tm.IDTipoMovimiento        
			and tm.Codigo in ('B')   
		LEFT JOIN  IMSS.tblCatRazonesMovAfiliatorios RMA  with(nolock) on Mov.IDRazonMovimiento = RMA.IDRazonMovimiento   
		LEFT JOIN  IMSS.tblCatTiposRazonesMovimientos TRM with(nolock) on TRM.IDCatTipoRazonMovimiento = mov.IDTipoRazonMovimiento
		LEFT JOIN  IMSS.tblCatTiposRazonesMovimientos TRM2 with(nolock) on TRM2.IDCatTipoRazonMovimiento = RMA.IDCatTipoRazonMovimiento
		LEFT JOIN  RH.tblContratoEmpleado CE on CE.IDEmpleado = E.IDEmpleado      
			AND CE.FechaIni<= @Fechafin AND CE.FechaFin >= @Fechafin    
			AND CE.IDTipoDocumento <> 3    
		LEFT JOIN Sat.tblCatTiposContrato  CTC  with(nolock) on CTC.IDTipoContrato = CE.IDTipoContrato    
        
    
	if @AfectaIDSE = 1     
	BEGIN    
		UPDATE IMSS.tblMovAfiliatorios    
			set FechaIDSE = cast(@FechaIDSE as date)     
		where IDMovAfiliatorio in (Select IDMovAfiliatorio from #TempValores)    
	END    
    
	Select valor from #TempValores     
    
END
GO
