USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
  
CREATE proc [Asistencia].[spBuscarIncapacidadEmpleado](  
 @IDIncapacidadEmpleado int  
) as  
select   
  ie.IDIncapacidadEmpleado  
 ,ie.IDEmpleado  
 ,ie.Numero  
 ,ie.Fecha  
 ,ie.Duracion  
 ,ie.IDTipoIncapacidad  
 ,tipoInca.Descripcion as TipoIncapacidad  
 ,isnull(ie.IDClasificacionIncapacidad,0) as IDClasificacionIncapacidad  
 ,clasificacion.Nombre as ClasificacionIncapacidad  
 ,isnull(ie.PagoSubsidioEmpresa,cast(0 as bit)) as PagoSubsidioEmpresa  
 ,isnull(ie.IDCausaAccidente,0) as IDCausaAccidente  
 ,causas.Descripcion as CausaAccidente  
 ,isnull(ie.IDTipoLesion,0) as IDTipoLesion  
 ,lesiones.Descripcion as TipoLesion  
 --,ie.Hora  
 --,ie.Dia  
 ,isnull(ie.IDTipoRiesgoIncapacidad,0) as IDTipoRiesgoIncapacidad  
 ,riesgos.Nombre as TipoRiesgoIncapacidad  
 ,isnull(ie.Permanente,cast(0 as bit)) as Permanente  
from Asistencia.tblIncapacidadEmpleado ie  
 join SAT.tblCatTiposIncapacidad as tipoInca on ie.IDTipoIncapacidad = tipoInca.IDTIpoIncapacidad  
 left join IMSS.tblCatClasificacionesIncapacidad clasificacion on ie.IDClasificacionIncapacidad = clasificacion.IDClasificacionIncapacidad  
 left join IMSS.tblCatCausasAccidentes causas on ie.IDCausaAccidente = causas.IDCausaAccidente  
 left join IMSS.tblCatTiposLesiones lesiones on ie.IDTipoLesion = lesiones.IDTipoLesion  
 left join IMSS.tblCatTipoRiesgoIncapacidad riesgos on ie.IDTipoRiesgoIncapacidad = riesgos.IDTipoRiesgoIncapacidad  
where IDIncapacidadEmpleado = @IDIncapacidadEmpleado
GO
