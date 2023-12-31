USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Reportes].[spBuscarPapeletaDescansoMoti]
(
	--@IDIncidenciaEmpleado int = 0,
	 @IDUsuario int
	,@IDPapeleta int
)
AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')





	select 
			ie.IDEmpleado as IDEmpleado,
			STRING_AGG(ie.Fecha,',') as DiasDeDescanso
	from Asistencia.tblIncidenciaEmpleado IE
		left join Asistencia.tblPapeletas pape
			on ie.idempleado = pape.idempleado
	where (ie.Fecha between pape.fecha and DATEADD(DAY,pape.Duracion, pape.Fecha)) and ie.idincidencia = 'D' and pape.IDPapeleta = @IDPapeleta
	group by ie.IDEmpleado



	/*select 
		IE.IDIncidencia
		,JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,IE.Fecha
		,M.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,ISNULL(IE.Comentario,IE.ComentarioTextoPlano) AS Comentario
		,M.Departamento
		,M.Sucursal
		,M.Puesto
		,isnull((select top 1 em.NOMBRECOMPLETO from RH.tblJefesEmpleados JE inner join RH.tblEmpleadosMaster em on je.IDJefe = em.IDEmpleado where JE.IDEmpleado = M.IDEmpleado),'Jefe Supervisor') as Jefe
	from Asistencia.tblIncidenciaEmpleado IE
		inner join Asistencia.tblCatIncidencias I on IE.IDIncidencia = I.IDIncidencia
		Inner join RH.tblEmpleadosMaster m on IE.IDEmpleado = m.IDEmpleado
		left join Asistencia.tblIncapacidadEmpleado IncaEmpleado on IncaEmpleado.IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado
	where IE.IDIncidenciaEmpleado = @IDIncidenciaEmpleado*/
 	
END
GO
