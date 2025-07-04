USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarIDSEReporteREINGRESO](      
	@FechaIni date = '1900-01-01',                    
	@Fechafin date = '9999-12-31',                    
	@AfectaIDSE bit = 0,      
	@FechaIDSE date = '9999-12-31',         
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY,
	@IDUsuario int        
) AS      
BEGIN      
	declare @IDRegPatronal int,
	        @dtEmpleados RH.dtEmpleados			

	insert into @dtEmpleados      
    exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario 

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')      
    
	IF OBJECT_ID('tempdb..#TempValores') IS NOT NULL DROP TABLE #TempValores;    
      
	select  
		[App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS      
		+ [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL      
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Paterno,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ' , 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Materno,'')),1,27 ))) COLLATE Cyrillic_General_CI_AI,' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ' , 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,27 ))) COLLATE Cyrillic_General_CI_AI,' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ' , 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ [App].[fnAddString](6,replace(cast(ISNULL(mov.SalarioIntegrado,0) as decimal(6,2)),'.',''),'0',1) -- Salario Base   
		+ [App].[fnAddString](6,'',' ',2) -- FILLER  
		--+ [App].[fnAddString](1,ISNULL(CASE WHEN CTC.IDTipoContrato = 1 THEN 1  
			--						   WHEN CTC.IDTipoContrato in (2,3,4,5,6)  THEN 2  
			--						   ELSE 2 END,0),' ',2) -- FILLER  
		+  [App].[fnAddString](1,CASE WHEN ISNULL(TTE.IDTipoTrabajador,1) = 1 THEN 2  WHEN ISNULL(TTE.IDTipoTrabajador,1) = 2  THEN 1  else 2 END,'0',2)
		+ [App].[fnAddString](1,ISNULL(TS.Codigo,'2'),'',2) -- TIPO DE SALARIO  
		+ [App].[fnAddString](1,0,'',2) -- TIPO JORNADA  
		+ [App].[fnAddString](8,ISNULL(FORMAT(mov.Fecha, 'ddMMyyyy'),''),'0',2) -- FECHA DE MOVIMIENTO     
		+ [App].[fnAddString](3,ISNULL(e.UMF,''),'',2) -- UMF  
		+ [App].[fnAddString](2,'','',2) -- FILLER  
		+ [App].[fnAddString](2,'08',' ',2) -- Movimiento  
		+ [App].[fnAddString](5,'',' ',2) -- FILLER  
		+ [App].[fnAddString](5,RTRIM(substring(UPPER(COALESCE(rp.SubDelegacionIMSS,'')+''+COALESCE('400','')),1,27 )),'',2) -- DELEGACION    
		-- + [App].[fnAddString](10,e.ClaveEmpleado,' ',2) -- ClaveEmpleado  
		+ [App].[fnAddString](6,'',' ',2) -- FILLER  
		+ [App].[fnAddString](18,UPPER(e.CURP),' ',2) -- CURP  
		+ [App].[fnAddString](1,'9','9',2) as valor -- Identificador  
		, mov.IDMovAfiliatorio  
    into #TempValores  
	from IMSS.tblMovAfiliatorios mov with (nolock)    
		inner join rh.tblCatRegPatronal rp with (nolock) on mov.IDRegPatronal = rp.IDRegPatronal     
			and mov.Fecha BETWEEN @FechaIni and @Fechafin      
			and mov.IDRegPatronal = @IDRegPatronal  
			and mov.FechaIDSE IS NULL      
		inner join @dtEmpleados E  on mov.IDEmpleado = e.IDEmpleado
		inner join IMSS.tblCatTipoMovimientos tm with (nolock) on mov.IDTipoMovimiento = tm.IDTipoMovimiento      
				and tm.Codigo in ('R')   
		LEFT JOIN (
			SELECT CE.IDEmpleado, CE.IDTipoContrato
			FROM RH.tblContratoEmpleado CE WITH (NOLOCK) 
			INNER JOIN RH.tblCatDocumentos docs WITH (NOLOCK) 
				ON CE.IDDocumento = docs.IDDocumento AND isnull(docs.EsContrato,0) = 1
			WHERE CE.FechaIni <= @FechaFin 
			AND CE.FechaFin >= @FechaFin
		) AS documentos 
			ON documentos.IDEmpleado = E.IDEmpleado  
		LEFT JOIN Sat.tblCatTiposContrato CTC WITH (NOLOCK)  
    			ON CTC.IDTipoContrato = documentos.IDTipoContrato  
		left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = e.IDEmpleado and TTE.[Row] = 1 
		 left join IMSS.tblCatTipoSalario TS on TS.IDTipoSalario = TTE.IDTipoSalario
	WHERE   	 
		([App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2)   
	  + [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL      
	  + replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Paterno,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
	  + replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Materno,'')),1,27 ))) COLLATE Cyrillic_General_CI_AI,' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
	  + replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,27 ))) COLLATE Cyrillic_General_CI_AI,' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
	  + [App].[fnAddString](6,replace(cast(ISNULL(mov.SalarioIntegrado,0) as decimal(6,2)),'.',''),'0',1) -- Salario Base   
	  + [App].[fnAddString](6,' ',' ',2) -- FILLER  
	  + [App].[fnAddString](1,ISNULL(CASE WHEN CTC.IDTipoContrato = 1 THEN 1  
			   WHEN CTC.IDTipoContrato = 2 THEN 2  
			   WHEN CTC.IDTipoContrato = 3 THEN 3  
			   WHEN CTC.IDTipoContrato = 4 THEN 4  
			   ELSE 3 END,0),' ',2) -- FILLER  
	  + [App].[fnAddString](1,ISNULL(TS.Codigo,'2'),'',2) -- TIPO DE SALARIO  
	  + [App].[fnAddString](1,0,'',2) -- TIPO JORNADA  
	  + [App].[fnAddString](8,ISNULL(FORMAT(mov.Fecha, 'ddMMyyyy'),''),'0',2) -- FECHA DE MOVIMIENTO     
	  + [App].[fnAddString](3,ISNULL(e.UMF,''),'',2) -- UMF  
	  + [App].[fnAddString](6,' ',' ',2) -- FILLER  
	  + [App].[fnAddString](2,'08',' ',2) -- Movimiento  
	  + [App].[fnAddString](5,RTRIM(substring(UPPER(COALESCE(rp.SubDelegacionIMSS,'')+''+COALESCE('400','')),1,27 )),'',2) -- DELEGACION     
	  + [App].[fnAddString](10,e.ClaveEmpleado,' ',2) -- ClaveEmpleado  
	  + [App].[fnAddString](6,' ',' ',2) -- FILLER  
	  + [App].[fnAddString](18,UPPER(e.CURP),' ',2) -- CURP    
	  + [App].[fnAddString](1,'9','9',2))IS NOT NULL  
      
	if @AfectaIDSE = 1   
	BEGIN  
		UPDATE IMSS.tblMovAfiliatorios  
			set FechaIDSE = @FechaIDSE  
		where IDMovAfiliatorio in (Select IDMovAfiliatorio from #TempValores)  
	END  
  
	Select valor from #TempValores   
  
END
GO
