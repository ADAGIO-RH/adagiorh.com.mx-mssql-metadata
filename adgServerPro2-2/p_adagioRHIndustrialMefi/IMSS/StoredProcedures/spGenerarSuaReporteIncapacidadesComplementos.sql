USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [IMSS].[spGenerarSuaReporteIncapacidadesComplementos]
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

	select 
	  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS  **
	+ [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL  **
	+ [App].[fnAddString](1,'1','',1) -- Tipo de Movimiento ** 
	+ [App].[fnAddString](8,ISNULL(FORMAT(IE.Fecha, 'ddMMyyyy'),''),'0',2) -- fecha inicio
	+ [App].[fnAddString](8,UPPER(IE.Numero),' ',2) -- FOLIO INCAPACIDAD ***
	+ [App].[fnAddString](3,IE.Duracion,'0',1) -- Días subsidiados **
    + [App].[fnAddString](3,'000','0',1) -- Días subsidiados **
	+ [App].[fnAddString](1,Replace(isnull(TI.Codigo,'0'),'0',''),'0',1) -- RamaSeguro
    + [App].[fnAddString](1,Replace(isnull(TL.Codigo,'0'),'0',''),'0',1) -- TipoRiesgo
    + [App].[fnAddString](1,Replace(isnull(TL.Codigo,'0'),'0',''),'0',1) -- Secuela
    + [App].[fnAddString](1,Replace(isnull(CI.Codigo,'0'),'0',''),'0',1) -- Control
    + [App].[fnAddString](8,ISNULL(FORMAT(DATEADD(day,IE.Duracion-1,IE.Fecha), 'ddMMyyyy'),''),'0',2) -- fecha fin

	from @dtEmpleados e
		inner join rh.tblCatRegPatronal rp
			on e.IDRegPatronal = rp.IDRegPatronal
		inner join Asistencia.tblIncapacidadEmpleado IE
			on e.IDEmpleado = IE.IDEmpleado
			and IE.Fecha BETWEEN @FechaIni and @Fechafin
		left join Sat.tblCatTiposIncapacidad TI
			on IE.IDTipoIncapacidad = TI.IDTIpoIncapacidad
		left join IMSS.tblCatClasificacionesIncapacidad CI
			on IE.IDClasificacionIncapacidad = CI.IDClasificacionIncapacidad
		left join imss.tblCatCausasAccidentes CA
			on IE.IDCausaAccidente = ca.IDCausaAccidente
		left join imss.tblCatCorreccionesAccidentes CCA
			on CCA.IDCorreccionAccidente = IE.IDCorreccionAccidente
		left join IMSS.tblCatTiposLesiones TL
			on TL.IDTipoLesion = IE.IDTipoLesion
		left join imss.tblCatTipoRiesgoIncapacidad RI
			on RI.IDTipoRiesgoIncapacidad = IE.IDTipoRiesgoIncapacidad
	

	

END
GO
