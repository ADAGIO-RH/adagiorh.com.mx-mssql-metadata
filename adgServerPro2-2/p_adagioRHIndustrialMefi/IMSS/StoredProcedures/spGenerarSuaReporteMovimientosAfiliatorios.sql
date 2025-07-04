USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarSuaReporteMovimientosAfiliatorios]  
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
	declare 
     @IDRegPatronal int
    ,@dtEmpleados RH.dtEmpleados;

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')

    insert into @dtEmpleados      
   exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario 
  

  
	select  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS  
		+ [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL  
		+ [App].[fnAddString](2,CASE WHEN tm.Codigo = 'B'THEN '02' WHEN tm.Codigo = 'R' then '08' when tm.Codigo='M' then '07' else '00' end,'',2) -- Tipo de Movimiento  
		+ [App].[fnAddString](8,ISNULL(FORMAT(mov.Fecha, 'ddMMyyyy'),''),'0',2) -- FECHA DE MOVIMIENTO  
		+ [App].[fnAddString](8,'','',2) -- FOLIO INCAPACIDAD  
		+ [App].[fnAddString](9,replace(CAST(ISNULL(mov.SalarioIntegrado,0) as decimal(9,2)),'.',''),'0',1) -- SALARIO DIARIO INTEGRADO  
	from IMSS.tblMovAfiliatorios mov  
		INNER join IMSS.tblCatTipoMovimientos tm  
				on mov.IDTipoMovimiento = tm.IDTipoMovimiento  
					and tm.Codigo in ('B','R','M')  
		inner join rh.tblCatRegPatronal rp  
			on mov.IDRegPatronal = rp.IDRegPatronal  
		inner join @dtEmpleados e
			on e.IDEmpleado = mov.IDEmpleado
	where  mov.Fecha BETWEEN @FechaIni and @Fechafin  
			and ((mov.IDRegPatronal = isnull(@IDRegPatronal,0)) OR (isnull(@IDRegPatronal,0) = 0))
		
END
GO
