USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure Reportes.spReporteDocumentosGenerados --@IDPeriodo = 1    
(    
    
 @IDCliente int = 0,     
 @EmpleadoIni Varchar(20) = '0',        
 @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',        
 @FechaInicio Date = Null,  
 @FechaFin Date = Null,
 @IDUsuario int = null  
)    
AS    
BEGIN    
     
   set @FechaInicio = ISNULL(@FechaInicio,getdate());  
   set @FechaFin = ISNULL(@FechaFin,getdate());  
  
   select EM.ClaveEmpleado,  
  EM.NOMBRECOMPLETO as NombreCompleto,  
  EM.Puesto,  
  EM.Departamento,  
  D.Descripcion as Documento,  
  CE.FechaIni as FechaInicio,  
  CE.FechaFin as FechaFin,  
  CE.Duracion,  
  TC.Descripcion as TipoContratacion   
   from RH.tblContratoEmpleado CE  
  inner join RH.tblEmpleadosMaster EM  
   on CE.IDEmpleado = EM.IDEmpleado  
  Inner join RH.tblCatDocumentos D  
   on CE.IDDocumento = D.IDDocumento  
    and ISNULL(D.EsContrato,0) = 1  
  Inner join Sat.tblCatTiposContrato TC  
   on CE.IDTipoContrato = TC.IDTipoContrato  
  left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios feu
	on em.IDEmpleado = feu.IDEmpleado
	and feu.IDUsuario = @IDUsuario
 WHERE ((CE.FechaIni Between @FechaInicio and @FechaFin) OR (CE.FechaGeneracion Between @FechaInicio and @FechaFin))  
  and ((EM.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))  
  and EM.ClaveEmpleado Between @EmpleadoIni and @EmpleadoFin  
   
  
  
END
GO
