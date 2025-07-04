USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarContratoEmpleado](    
	@IDEmpleado int,    
	@IDContratoEmpleado int = 0    
)    
AS    
BEGIN    
	Select     
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
		cast(isnull(d.EsContrato,0) as bit) as EsContrato,
		ISNULL(CE.CalificacionEvaluacion, 0.00) AS CalificacionEvaluacion 
	from RH.tblContratoEmpleado CE    
		LEft join Sat.tblCatTiposContrato TC on CE.IDTipoContrato = TC.IDTipoContrato    
		LEft join RH.tblCatDocumentos D on CE.IDDocumento = D.IDDocumento    
		LEft join RH.tblCatTipoDocumento td on td.IDTipoDocumento = ce.IDTipoDocumento    
		left join IMSS.tblCatTipoTrabajador tt on tt.IDTipoTrabajador = ce.IDTipoTrabajador
	WHERE CE.IDEmpleado = @IDEmpleado    
		and ((ce.IDContratoEmpleado = @IDContratoEmpleado) or (@IDContratoEmpleado = 0 or @IDContratoEmpleado IS NULL))    
	ORDER BY CE.FechaIni Desc    
END
GO
